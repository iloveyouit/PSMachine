"""
Tests for database models.
"""
import pytest
from models import User, Script, Execution, ScriptVersion, Credential


@pytest.mark.unit
class TestUserModel:
    """Test User model."""

    def test_create_user(self, init_database):
        """Test creating a user."""
        user = User(
            username='newuser',
            email='new@example.com',
            role='user'
        )
        user.set_password('password123')
        init_database.session.add(user)
        init_database.session.commit()

        assert user.id is not None
        assert user.username == 'newuser'
        assert user.email == 'new@example.com'
        assert user.role == 'user'
        assert user.is_active is True

    def test_password_hashing(self, init_database):
        """Test password hashing and verification."""
        user = User(username='testuser', email='test@example.com')
        user.set_password('mypassword')

        assert user.password_hash != 'mypassword'
        assert user.check_password('mypassword') is True
        assert user.check_password('wrongpassword') is False

    def test_user_to_dict(self, test_user):
        """Test user serialization."""
        user_dict = test_user.to_dict()

        assert user_dict['id'] == test_user.id
        assert user_dict['username'] == 'testuser'
        assert user_dict['email'] == 'test@example.com'
        assert user_dict['role'] == 'user'
        assert 'password_hash' not in user_dict


@pytest.mark.unit
class TestScriptModel:
    """Test Script model."""

    def test_create_script(self, init_database, test_user):
        """Test creating a script."""
        script = Script(
            name='My Script',
            description='Test script',
            content='Write-Host "Test"',
            category='Utilities',
            tags='test,demo',
            author_id=test_user.id
        )
        init_database.session.add(script)
        init_database.session.commit()

        assert script.id is not None
        assert script.name == 'My Script'
        assert script.execution_count == 0
        assert script.is_public is False

    def test_script_to_dict(self, test_script):
        """Test script serialization."""
        script_dict = test_script.to_dict()

        assert script_dict['id'] == test_script.id
        assert script_dict['name'] == 'Test Script'
        assert script_dict['content'] == 'Write-Host "Hello, World!"'
        assert script_dict['tags'] == ['test', 'sample']
        assert script_dict['author_username'] == 'testuser'

    def test_script_tags_parsing(self, init_database, test_user):
        """Test tag parsing."""
        script = Script(
            name='Test',
            content='test',
            tags='tag1,tag2,tag3',
            author_id=test_user.id
        )
        init_database.session.add(script)
        init_database.session.commit()

        script_dict = script.to_dict()
        assert script_dict['tags'] == ['tag1', 'tag2', 'tag3']


@pytest.mark.unit
class TestExecutionModel:
    """Test Execution model."""

    def test_create_execution(self, init_database, test_script, test_user):
        """Test creating an execution record."""
        execution = Execution(
            script_id=test_script.id,
            user_id=test_user.id,
            parameters={'param1': 'value1'},
            status='pending'
        )
        init_database.session.add(execution)
        init_database.session.commit()

        assert execution.id is not None
        assert execution.status == 'pending'
        assert execution.parameters == {'param1': 'value1'}

    def test_execution_to_dict(self, init_database, test_script, test_user):
        """Test execution serialization."""
        execution = Execution(
            script_id=test_script.id,
            user_id=test_user.id,
            status='completed',
            output='Success!',
            exit_code=0,
            duration_seconds=1.5
        )
        init_database.session.add(execution)
        init_database.session.commit()

        exec_dict = execution.to_dict()

        assert exec_dict['script_name'] == 'Test Script'
        assert exec_dict['username'] == 'testuser'
        assert exec_dict['status'] == 'completed'
        assert exec_dict['output'] == 'Success!'
        assert exec_dict['exit_code'] == 0
        assert exec_dict['duration_seconds'] == 1.5
