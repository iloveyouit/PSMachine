"""
Script management routes for CRUD operations.
"""
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime
from models import db, User, Script, ScriptVersion

scripts_bp = Blueprint('scripts', __name__)


@scripts_bp.route('/', methods=['GET'])
@jwt_required()
def list_scripts():
    """List all scripts accessible to user."""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    # Get filter parameters
    category = request.args.get('category')
    search = request.args.get('search')
    tags = request.args.get('tags')

    # Build query
    query = Script.query

    # Non-admin users see only their scripts and public scripts
    if user.role != 'admin':
        query = query.filter(
            db.or_(Script.author_id == user_id, Script.is_public == True)
        )

    # Apply filters
    if category:
        query = query.filter(Script.category == category)

    if search:
        search_pattern = f'%{search}%'
        query = query.filter(
            db.or_(
                Script.name.ilike(search_pattern),
                Script.description.ilike(search_pattern)
            )
        )

    if tags:
        tag_list = tags.split(',')
        for tag in tag_list:
            query = query.filter(Script.tags.contains(tag.strip()))

    scripts = query.order_by(Script.updated_at.desc()).all()

    # Don't include full content in list view
    return jsonify([script.to_dict(include_content=False) for script in scripts]), 200


@scripts_bp.route('/<int:script_id>', methods=['GET'])
@jwt_required()
def get_script(script_id):
    """Get a specific script by ID."""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    script = Script.query.get(script_id)

    if not script:
        return jsonify({'error': 'Script not found'}), 404

    # Check access permissions
    if script.author_id != user_id and not script.is_public and user.role != 'admin':
        return jsonify({'error': 'Access denied'}), 403

    return jsonify(script.to_dict(include_content=True)), 200


@scripts_bp.route('/', methods=['POST'])
@jwt_required()
def create_script():
    """Create a new script."""
    user_id = get_jwt_identity()
    data = request.get_json()

    if not data:
        return jsonify({'error': 'No data provided'}), 400

    name = data.get('name')
    content = data.get('content')

    if not all([name, content]):
        return jsonify({'error': 'Name and content are required'}), 400

    # Create script
    script = Script(
        name=name,
        description=data.get('description', ''),
        content=content,
        category=data.get('category', 'Utilities'),
        tags=','.join(data.get('tags', [])) if data.get('tags') else '',
        parameters=data.get('parameters', []),
        author_id=user_id,
        is_public=data.get('is_public', False)
    )

    db.session.add(script)
    db.session.commit()

    # Create initial version
    version = ScriptVersion(
        script_id=script.id,
        version_number=1,
        content=content,
        change_description='Initial version',
        created_by=user_id
    )
    db.session.add(version)
    db.session.commit()

    return jsonify({
        'message': 'Script created successfully',
        'script': script.to_dict()
    }), 201


@scripts_bp.route('/<int:script_id>', methods=['PUT'])
@jwt_required()
def update_script(script_id):
    """Update an existing script."""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    script = Script.query.get(script_id)

    if not script:
        return jsonify({'error': 'Script not found'}), 404

    # Check permissions
    if script.author_id != user_id and user.role != 'admin':
        return jsonify({'error': 'Access denied'}), 403

    data = request.get_json()

    if not data:
        return jsonify({'error': 'No data provided'}), 400

    # Track if content changed for versioning
    content_changed = False
    old_content = script.content

    # Update fields
    if 'name' in data:
        script.name = data['name']
    if 'description' in data:
        script.description = data['description']
    if 'content' in data and data['content'] != script.content:
        script.content = data['content']
        content_changed = True
    if 'category' in data:
        script.category = data['category']
    if 'tags' in data:
        script.tags = ','.join(data['tags']) if isinstance(data['tags'], list) else data['tags']
    if 'parameters' in data:
        script.parameters = data['parameters']
    if 'is_public' in data:
        script.is_public = data['is_public']

    script.updated_at = datetime.utcnow()
    db.session.commit()

    # Create new version if content changed
    if content_changed:
        latest_version = ScriptVersion.query.filter_by(script_id=script_id).order_by(
            ScriptVersion.version_number.desc()
        ).first()

        version_number = (latest_version.version_number + 1) if latest_version else 1

        version = ScriptVersion(
            script_id=script.id,
            version_number=version_number,
            content=script.content,
            change_description=data.get('change_description', 'Updated script'),
            created_by=user_id
        )
        db.session.add(version)
        db.session.commit()

    return jsonify({
        'message': 'Script updated successfully',
        'script': script.to_dict()
    }), 200


@scripts_bp.route('/<int:script_id>', methods=['DELETE'])
@jwt_required()
def delete_script(script_id):
    """Delete a script."""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    script = Script.query.get(script_id)

    if not script:
        return jsonify({'error': 'Script not found'}), 404

    # Check permissions
    if script.author_id != user_id and user.role != 'admin':
        return jsonify({'error': 'Access denied'}), 403

    db.session.delete(script)
    db.session.commit()

    return jsonify({'message': 'Script deleted successfully'}), 200


@scripts_bp.route('/<int:script_id>/versions', methods=['GET'])
@jwt_required()
def get_script_versions(script_id):
    """Get version history for a script."""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)

    script = Script.query.get(script_id)

    if not script:
        return jsonify({'error': 'Script not found'}), 404

    # Check access permissions
    if script.author_id != user_id and not script.is_public and user.role != 'admin':
        return jsonify({'error': 'Access denied'}), 403

    versions = ScriptVersion.query.filter_by(script_id=script_id).order_by(
        ScriptVersion.version_number.desc()
    ).all()

    return jsonify([version.to_dict() for version in versions]), 200


@scripts_bp.route('/categories', methods=['GET'])
@jwt_required()
def get_categories():
    """Get list of all script categories."""
    categories = db.session.query(Script.category).distinct().all()
    category_list = [cat[0] for cat in categories if cat[0]]

    # Add default categories if not present
    default_categories = ['VMware', 'Azure', 'Active Directory', 'Utilities', 'Network', 'Security']
    for cat in default_categories:
        if cat not in category_list:
            category_list.append(cat)

    return jsonify(sorted(category_list)), 200
