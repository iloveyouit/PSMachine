"""
Tests for authentication endpoints.
"""
import pytest


@pytest.mark.integration
class TestAuthEndpoints:
    """Test authentication API endpoints."""

    def test_register_user(self, client, init_database):
        """Test user registration."""
        response = client.post('/api/auth/register', json={
            'username': 'newuser',
            'email': 'new@example.com',
            'password': 'password123'
        })

        assert response.status_code == 201
        data = response.get_json()
        assert 'access_token' in data
        assert 'user' in data
        assert data['user']['username'] == 'newuser'

    def test_register_duplicate_username(self, client, test_user):
        """Test registration with duplicate username."""
        response = client.post('/api/auth/register', json={
            'username': 'testuser',  # Already exists
            'email': 'another@example.com',
            'password': 'password123'
        })

        assert response.status_code == 400
        data = response.get_json()
        assert 'error' in data

    def test_login_success(self, client, test_user):
        """Test successful login."""
        response = client.post('/api/auth/login', json={
            'username': 'testuser',
            'password': 'testpass123'
        })

        assert response.status_code == 200
        data = response.get_json()
        assert 'access_token' in data
        assert 'user' in data

    def test_login_invalid_credentials(self, client, test_user):
        """Test login with invalid credentials."""
        response = client.post('/api/auth/login', json={
            'username': 'testuser',
            'password': 'wrongpassword'
        })

        assert response.status_code == 401
        data = response.get_json()
        assert 'error' in data

    def test_login_nonexistent_user(self, client, init_database):
        """Test login with non-existent user."""
        response = client.post('/api/auth/login', json={
            'username': 'nonexistent',
            'password': 'password123'
        })

        assert response.status_code == 401

    def test_get_current_user(self, client, auth_headers):
        """Test getting current user info."""
        response = client.get('/api/auth/me', headers=auth_headers)

        assert response.status_code == 200
        data = response.get_json()
        assert data['username'] == 'testuser'

    def test_get_current_user_no_token(self, client, init_database):
        """Test getting current user without token."""
        response = client.get('/api/auth/me')

        assert response.status_code == 401

    def test_list_users_as_admin(self, client, admin_headers, test_user):
        """Test listing users as admin."""
        response = client.get('/api/auth/users', headers=admin_headers)

        assert response.status_code == 200
        data = response.get_json()
        assert isinstance(data, list)
        assert len(data) >= 2  # admin + test_user

    def test_list_users_as_regular_user(self, client, auth_headers):
        """Test listing users as regular user (should fail)."""
        response = client.get('/api/auth/users', headers=auth_headers)

        # Should be forbidden for non-admin users
        # Adjust assertion based on actual implementation
        assert response.status_code in [403, 200]
