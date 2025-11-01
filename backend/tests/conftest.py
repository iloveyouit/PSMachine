"""
Pytest configuration and fixtures for PSMachine tests.
"""
import pytest
import os
import tempfile
from app import app as flask_app
from models import db, User, Script, Execution


@pytest.fixture(scope='session')
def app():
    """Create application for testing."""
    # Set testing configuration
    flask_app.config.update({
        'TESTING': True,
        'SQLALCHEMY_DATABASE_URI': 'sqlite:///:memory:',
        'SQLALCHEMY_TRACK_MODIFICATIONS': False,
        'SECRET_KEY': 'test-secret-key',
        'JWT_SECRET_KEY': 'test-jwt-secret',
    })

    # Set testing environment variable
    os.environ['FLASK_ENV'] = 'development'
    os.environ['ENCRYPTION_KEY'] = 'test-encryption-key-for-testing-only-12345='

    yield flask_app


@pytest.fixture(scope='function')
def client(app):
    """Create test client."""
    return app.test_client()


@pytest.fixture(scope='function')
def app_context(app):
    """Create application context."""
    with app.app_context():
        yield app


@pytest.fixture(scope='function')
def init_database(app_context):
    """Initialize clean database for each test."""
    db.create_all()

    yield db

    db.session.remove()
    db.drop_all()


@pytest.fixture
def test_user(init_database):
    """Create a test user."""
    user = User(
        username='testuser',
        email='test@example.com',
        role='user'
    )
    user.set_password('testpass123')
    db.session.add(user)
    db.session.commit()
    return user


@pytest.fixture
def test_admin(init_database):
    """Create a test admin user."""
    admin = User(
        username='admin',
        email='admin@example.com',
        role='admin'
    )
    admin.set_password('adminpass123')
    db.session.add(admin)
    db.session.commit()
    return admin


@pytest.fixture
def test_script(init_database, test_user):
    """Create a test script."""
    script = Script(
        name='Test Script',
        description='A test PowerShell script',
        content='Write-Host "Hello, World!"',
        category='Utilities',
        tags='test,sample',
        author_id=test_user.id,
        is_public=False
    )
    db.session.add(script)
    db.session.commit()
    return script


@pytest.fixture
def auth_headers(client, test_user):
    """Get authentication headers for test user."""
    response = client.post('/api/auth/login', json={
        'username': 'testuser',
        'password': 'testpass123'
    })
    token = response.get_json()['access_token']
    return {'Authorization': f'Bearer {token}'}


@pytest.fixture
def admin_headers(client, test_admin):
    """Get authentication headers for admin user."""
    response = client.post('/api/auth/login', json={
        'username': 'admin',
        'password': 'adminpass123'
    })
    token = response.get_json()['access_token']
    return {'Authorization': f'Bearer {token}'}
