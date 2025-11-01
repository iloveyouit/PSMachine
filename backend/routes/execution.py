"""
Script execution routes with real-time output via SocketIO.
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from flask_socketio import emit, join_room
from datetime import datetime
from models import db, User, Script, Execution
from services.powershell_executor import PowerShellExecutor
from services.security import validate_script_parameters
import threading

execution_bp = Blueprint('execution', __name__)

# Global executor instance
executor = PowerShellExecutor(enable_restrictions=True)


@execution_bp.route('/execute/<int:script_id>', methods=['POST'])
@jwt_required()
def execute_script(script_id):
    """
    Execute a PowerShell script.

    Request body should contain:
    - parameters: dict of parameter values (optional)
    - timeout: execution timeout in seconds (optional, default 300)
    """
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    script = Script.query.get(script_id)

    if not script:
        return jsonify({'error': 'Script not found'}), 404

    # Check access permissions
    if script.author_id != user_id and not script.is_public and user.role != 'admin':
        return jsonify({'error': 'Access denied'}), 403

    data = request.get_json() or {}
    parameters = data.get('parameters', {})
    timeout = data.get('timeout', 300)

    # Validate parameters
    if script.parameters:
        is_valid, errors = validate_script_parameters(parameters, script.parameters)
        if not is_valid:
            return jsonify({
                'error': 'Parameter validation failed',
                'validation_errors': errors
            }), 400

    # Create execution record
    execution = Execution(
        script_id=script_id,
        user_id=user_id,
        parameters=parameters,
        status='running'
    )
    db.session.add(execution)
    db.session.commit()

    execution_id = execution.id

    # Execute script in background thread
    def execute_in_background():
        try:
            # Disable restrictions for admin users
            exec_instance = PowerShellExecutor(enable_restrictions=(user.role != 'admin'))

            result = exec_instance.execute(
                script_content=script.content,
                parameters=parameters,
                timeout=timeout
            )

            # Update execution record
            execution_record = Execution.query.get(execution_id)
            execution_record.status = result['status']
            execution_record.output = result['output']
            execution_record.error_output = result['error_output']
            execution_record.exit_code = result['exit_code']
            execution_record.completed_at = datetime.utcnow()
            execution_record.duration_seconds = result['duration_seconds']

            # Update script execution count
            script_record = Script.query.get(script_id)
            script_record.execution_count += 1

            db.session.commit()

        except Exception as e:
            # Handle execution errors
            execution_record = Execution.query.get(execution_id)
            execution_record.status = 'failed'
            execution_record.error_output = str(e)
            execution_record.completed_at = datetime.utcnow()
            db.session.commit()

    thread = threading.Thread(target=execute_in_background)
    thread.start()

    return jsonify({
        'message': 'Script execution started',
        'execution_id': execution_id
    }), 202


@execution_bp.route('/executions', methods=['GET'])
@jwt_required()
def list_executions():
    """List execution history."""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    # Get query parameters
    script_id = request.args.get('script_id', type=int)
    status = request.args.get('status')
    limit = request.args.get('limit', 50, type=int)

    # Build query
    query = Execution.query

    # Non-admin users see only their executions
    if user.role != 'admin':
        query = query.filter(Execution.user_id == user_id)

    if script_id:
        query = query.filter(Execution.script_id == script_id)

    if status:
        query = query.filter(Execution.status == status)

    executions = query.order_by(Execution.started_at.desc()).limit(limit).all()

    # Don't include full output in list view
    return jsonify([exec.to_dict(include_output=False) for exec in executions]), 200


@execution_bp.route('/executions/<int:execution_id>', methods=['GET'])
@jwt_required()
def get_execution(execution_id):
    """Get execution details with full output."""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    execution = Execution.query.get(execution_id)

    if not execution:
        return jsonify({'error': 'Execution not found'}), 404

    # Check access permissions
    if execution.user_id != user_id and user.role != 'admin':
        return jsonify({'error': 'Access denied'}), 403

    return jsonify(execution.to_dict(include_output=True)), 200


@execution_bp.route('/executions/<int:execution_id>', methods=['DELETE'])
@jwt_required()
def delete_execution(execution_id):
    """Delete an execution record."""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    execution = Execution.query.get(execution_id)

    if not execution:
        return jsonify({'error': 'Execution not found'}), 404

    # Check permissions
    if execution.user_id != user_id and user.role != 'admin':
        return jsonify({'error': 'Access denied'}), 403

    db.session.delete(execution)
    db.session.commit()

    return jsonify({'message': 'Execution deleted successfully'}), 200


@execution_bp.route('/validate/<int:script_id>', methods=['POST'])
@jwt_required()
def validate_script(script_id):
    """Validate script for security issues without executing."""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    script = Script.query.get(script_id)

    if not script:
        return jsonify({'error': 'Script not found'}), 404

    # Check access permissions
    if script.author_id != user_id and not script.is_public and user.role != 'admin':
        return jsonify({'error': 'Access denied'}), 403

    # Validate script (only if restrictions enabled)
    if user.role != 'admin':
        is_valid, issues = executor.validate_script(script.content)
        return jsonify({
            'valid': is_valid,
            'issues': issues,
            'restrictions_enabled': True
        }), 200
    else:
        return jsonify({
            'valid': True,
            'issues': [],
            'restrictions_enabled': False,
            'message': 'Admin users bypass security restrictions'
        }), 200


@execution_bp.route('/system/info', methods=['GET'])
@jwt_required()
def get_system_info():
    """Get PowerShell system information."""
    return jsonify({
        'powershell_version': executor.get_powershell_version(),
        'restrictions_enabled': executor.enable_restrictions
    }), 200
