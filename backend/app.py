"""
PowerShell Script Manager - Flask Application
"""
from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_socketio import SocketIO
from dotenv import load_dotenv
import os

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
