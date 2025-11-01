# PSMachine Backend Tests

This directory contains the test suite for the PSMachine backend.

## Running Tests

### Run All Tests
```bash
cd backend
pytest
```

### Run with Coverage
```bash
pytest --cov=. --cov-report=html
```

Then open `htmlcov/index.html` in a browser to view coverage report.

### Run Specific Test Files
```bash
# Run model tests only
pytest tests/test_models.py

# Run auth tests only
pytest tests/test_auth.py
```

### Run by Marker
```bash
# Run only unit tests
pytest -m unit

# Run only integration tests
pytest -m integration
```

### Verbose Output
```bash
pytest -v
```

## Test Structure

```
tests/
├── __init__.py           # Package marker
├── conftest.py           # Pytest fixtures and configuration
├── test_models.py        # Database model tests
├── test_auth.py          # Authentication endpoint tests
├── test_scripts.py       # Script management endpoint tests (TODO)
├── test_execution.py     # Execution endpoint tests (TODO)
├── test_powershell_executor.py  # PowerShell service tests (TODO)
└── test_security.py      # Security utility tests (TODO)
```

## Fixtures

Common fixtures available in `conftest.py`:

- `app` - Flask application configured for testing
- `client` - Test client for making HTTP requests
- `app_context` - Application context
- `init_database` - Clean database for each test
- `test_user` - Regular test user
- `test_admin` - Admin test user
- `test_script` - Sample script
- `auth_headers` - Authentication headers for test user
- `admin_headers` - Authentication headers for admin user

## Writing Tests

### Example Unit Test
```python
import pytest

@pytest.mark.unit
def test_user_creation(init_database):
    user = User(username='test', email='test@example.com')
    init_database.session.add(user)
    init_database.session.commit()
    assert user.id is not None
```

### Example Integration Test
```python
import pytest

@pytest.mark.integration
def test_create_script(client, auth_headers):
    response = client.post('/api/scripts/',
        json={'name': 'Test', 'content': 'test'},
        headers=auth_headers
    )
    assert response.status_code == 201
```

## Test Coverage Goals

- **Unit Tests:** 80%+ coverage
- **Integration Tests:** All API endpoints
- **Service Tests:** All business logic

## Continuous Integration

Tests run automatically on:
- Every push to main branch
- Every pull request
- Pre-commit hooks (optional)

## TODO

High priority tests to implement:

1. **test_scripts.py**
   - [ ] Test script creation
   - [ ] Test script listing with filters
   - [ ] Test script update
   - [ ] Test script deletion
   - [ ] Test script versioning
   - [ ] Test permission checks

2. **test_execution.py**
   - [ ] Test script execution
   - [ ] Test execution history
   - [ ] Test execution with parameters
   - [ ] Test execution permissions

3. **test_powershell_executor.py**
   - [ ] Test PowerShell execution (mocked)
   - [ ] Test security validation
   - [ ] Test parameter injection
   - [ ] Test timeout handling
   - [ ] Test restricted cmdlets

4. **test_security.py**
   - [ ] Test credential encryption
   - [ ] Test parameter validation
   - [ ] Test input sanitization

## Best Practices

1. **Isolate tests** - Each test should be independent
2. **Use fixtures** - Reuse setup code via fixtures
3. **Mock external calls** - Don't call real PowerShell in tests
4. **Clear test names** - Use descriptive test function names
5. **Test edge cases** - Not just happy paths
6. **Keep tests fast** - Unit tests should be < 100ms

## Debugging Tests

```bash
# Run single test
pytest tests/test_auth.py::TestAuthEndpoints::test_login_success

# Show print statements
pytest -s

# Drop into debugger on failure
pytest --pdb

# Show local variables on failure
pytest -l
```

## Mocking

For testing PowerShell execution without running actual scripts:

```python
from unittest.mock import patch, MagicMock

def test_script_execution(client, auth_headers, test_script):
    with patch('services.powershell_executor.PowerShellExecutor.execute') as mock_exec:
        mock_exec.return_value = {
            'status': 'completed',
            'output': 'Mocked output',
            'exit_code': 0,
            'duration_seconds': 0.5
        }

        response = client.post(f'/api/execution/execute/{test_script.id}',
            headers=auth_headers
        )
        assert response.status_code == 202
```
