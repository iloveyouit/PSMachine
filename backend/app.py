"""
PowerShell Script Manager - Flask Application
"""
from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_socketio import SocketIO
from flask_migrate import Migrate
from dotenv import load_dotenv
import os
import sys

# Load environment variables
load_dotenv()

# Import models and routes
from models import db, User
from routes.auth import auth_bp
from routes.scripts import scripts_bp
from routes.execution import execution_bp

# Create Flask app
app = Flask(__name__)

# Configuration
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'jwt-secret-key-change-in-production')
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
    'DATABASE_URL',
    'postgresql://psmachine:psmachine@localhost:5432/psmachine'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_ECHO'] = os.getenv('FLASK_ENV') == 'development'

# Initialize extensions
db.init_app(app)
migrate = Migrate(app, db)
jwt = JWTManager(app)
socketio = SocketIO(app, cors_allowed_origins='*')

# Enable CORS
CORS(app, resources={
    r"/api/*": {
        "origins": ["http://localhost:5173", "http://localhost:3000"],
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})

# Register blueprints
app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(scripts_bp, url_prefix='/api/scripts')
app.register_blueprint(execution_bp, url_prefix='/api/execution')


# Root route
@app.route('/')
def index():
    """API root endpoint."""
    return jsonify({
        'name': 'PowerShell Script Manager API',
        'version': '1.0.0',
        'status': 'running'
    })


@app.route('/api/health')
def health():
    """Health check endpoint."""
    return jsonify({
        'status': 'healthy',
        'database': 'connected' if db.engine else 'disconnected'
    })


# Error handlers
@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({'error': 'Not found'}), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    return jsonify({'error': 'Internal server error'}), 500


# JWT error handlers
@jwt.expired_token_loader
def expired_token_callback(jwt_header, jwt_payload):
    """Handle expired JWT tokens."""
    return jsonify({'error': 'Token has expired'}), 401


@jwt.invalid_token_loader
def invalid_token_callback(error):
    """Handle invalid JWT tokens."""
    return jsonify({'error': 'Invalid token'}), 401


@jwt.unauthorized_loader
def missing_token_callback(error):
    """Handle missing JWT tokens."""
    return jsonify({'error': 'Authorization token is missing'}), 401


# Configuration validation
def validate_config():
    """
    Validate critical configuration on startup.
    Fail fast if required configuration is missing or invalid.
    """
    errors = []
    warnings = []
    flask_env = os.getenv('FLASK_ENV', 'production')

    # Check production secrets
    if flask_env == 'production':
        secret_key = app.config.get('SECRET_KEY', '')
        jwt_secret = app.config.get('JWT_SECRET_KEY', '')

        if secret_key.startswith('dev-') or secret_key == 'dev-secret-key-change-in-production':
            errors.append("SECRET_KEY must be changed in production (currently using default value)")

        if jwt_secret.startswith('jwt-secret') or jwt_secret == 'jwt-secret-key-change-in-production':
            errors.append("JWT_SECRET_KEY must be changed in production (currently using default value)")

        if not os.getenv('ENCRYPTION_KEY'):
            errors.append("ENCRYPTION_KEY must be set in production")

        # Warn about default database password
        db_url = app.config.get('SQLALCHEMY_DATABASE_URI', '')
        if 'psmachine:psmachine@' in db_url:
            warnings.append("Using default database password - change for production")

    # Check encryption key format
    encryption_key = os.getenv('ENCRYPTION_KEY')
    if encryption_key:
        try:
            from services.security import CredentialEncryption
            CredentialEncryption(encryption_key)
        except Exception as e:
            errors.append(f"Invalid ENCRYPTION_KEY format: {str(e)}")
    elif flask_env == 'development':
        warnings.append("ENCRYPTION_KEY not set - credential encryption will fail")

    # Check database URL format
    db_url = app.config.get('SQLALCHEMY_DATABASE_URI', '')
    if not db_url:
        errors.append("DATABASE_URL not configured")
    elif not (db_url.startswith('postgresql://') or db_url.startswith('sqlite://')):
        errors.append(f"Invalid DATABASE_URL format: {db_url.split('://')[0] if '://' in db_url else 'unknown'}")

    # Print warnings
    if warnings:
        print("\n⚠️  Configuration Warnings:")
        for warning in warnings:
            print(f"   - {warning}")

    # Print errors and exit if any
    if errors:
        print("\n❌ Configuration Errors:")
        for error in errors:
            print(f"   - {error}")
        print("\nApplication cannot start with invalid configuration.")
        print("Please check your environment variables and try again.\n")
        sys.exit(1)

    if flask_env == 'production':
        print("✅ Configuration validation passed")


# Database initialization
def init_db():
    """Initialize database and create tables."""
    with app.app_context():
        db.create_all()
        print("Database tables created successfully")

        # Create default admin user if none exists
        if User.query.count() == 0:
            admin = User(
                username='admin',
                email='admin@psmachine.local',
                role='admin'
            )
            admin.set_password('admin')  # Change this in production!
            db.session.add(admin)
            db.session.commit()
            print("Default admin user created (username: admin, password: admin)")
            print("IMPORTANT: Change the admin password immediately!")


if __name__ == '__main__':
    # Validate configuration first
    validate_config()

    # Initialize database
    init_db()

    # Get configuration from environment
    host = os.getenv('FLASK_HOST', '0.0.0.0')
    port = int(os.getenv('FLASK_PORT', 5001))
    debug = os.getenv('FLASK_ENV') == 'development'

    print(f"Starting PowerShell Script Manager API on {host}:{port}")
    print(f"Debug mode: {debug}")

    # Run with SocketIO
    socketio.run(app, host=host, port=port, debug=debug, allow_unsafe_werkzeug=True)
