# GitHub Issues to Create

This file contains all issues to create for PSMachine improvements.
Copy and paste each issue into GitHub's issue creation form.

---

## 🔴 CRITICAL PRIORITY

### Issue 1: Add Backend Testing Infrastructure

**Title:** [CRITICAL] Add Backend Testing Infrastructure with pytest

**Labels:** `critical`, `testing`, `backend`, `infrastructure`

**Description:**
Implement comprehensive testing infrastructure for the Flask backend to ensure code quality and prevent regressions.

**Tasks:**
- [ ] Add pytest dependencies to requirements.txt
- [ ] Create tests directory structure
- [ ] Set up pytest configuration and fixtures
- [ ] Write unit tests for models (User, Script, Execution, Credential)
- [ ] Write integration tests for auth routes
- [ ] Write integration tests for script routes
- [ ] Write integration tests for execution routes
- [ ] Write unit tests for PowerShellExecutor service
- [ ] Write unit tests for security utilities
- [ ] Achieve 80%+ code coverage
- [ ] Add coverage reporting
- [ ] Document testing guidelines

**Dependencies:**
```bash
pytest==7.4.3
pytest-cov==4.1.0
pytest-flask==1.3.0
pytest-mock==3.12.0
factory-boy==3.3.0
```

**Target Structure:**
```
backend/tests/
├── __init__.py
├── conftest.py
├── test_models.py
├── test_auth.py
├── test_scripts.py
├── test_execution.py
├── test_powershell_executor.py
└── test_security.py
```

**Acceptance Criteria:**
- All API endpoints have integration tests
- All models have unit tests
- All services have unit tests
- 80%+ code coverage
- Tests pass in CI/CD

**Estimated Effort:** 40-60 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 1
- Pytest docs: https://docs.pytest.org/

---

### Issue 2: Add Frontend Testing Infrastructure

**Title:** [CRITICAL] Add Frontend Testing Infrastructure with Vitest and React Testing Library

**Labels:** `critical`, `testing`, `frontend`, `infrastructure`

**Description:**
Implement comprehensive testing infrastructure for the React frontend to ensure component reliability and prevent regressions.

**Tasks:**
- [ ] Add testing dependencies (Vitest, React Testing Library, jsdom)
- [ ] Configure Vitest
- [ ] Create test setup file
- [ ] Write tests for AuthContext
- [ ] Write tests for Dashboard component
- [ ] Write tests for ScriptEditor component
- [ ] Write tests for ExecutionConsole component
- [ ] Write tests for ScriptList component
- [ ] Write tests for Login component
- [ ] Write tests for ExecutionHistory component
- [ ] Write tests for API service
- [ ] Achieve 70%+ code coverage
- [ ] Add coverage reporting
- [ ] Document testing guidelines

**Dependencies:**
```json
{
  "@testing-library/react": "^14.1.2",
  "@testing-library/jest-dom": "^6.1.5",
  "@testing-library/user-event": "^14.5.1",
  "vitest": "^1.0.4",
  "@vitest/ui": "^1.0.4",
  "jsdom": "^23.0.1"
}
```

**Acceptance Criteria:**
- All components have unit tests
- All contexts have tests
- API service has tests
- 70%+ code coverage
- Tests pass in CI/CD

**Estimated Effort:** 40-60 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 1
- React Testing Library: https://testing-library.com/react
- Vitest: https://vitest.dev/

---

### Issue 3: Implement Database Migration Management

**Title:** [CRITICAL] Replace db.create_all() with Flask-Migrate for Database Migrations

**Labels:** `critical`, `database`, `backend`, `infrastructure`

**Description:**
Current database initialization uses `db.create_all()` which is not production-safe. Implement proper migration management with Flask-Migrate (Alembic) for version-controlled schema changes and rollback capability.

**Current Problem:**
```python
# In app.py:106-124
def init_db():
    with app.app_context():
        db.create_all()  # ❌ Not production-ready
```

**Tasks:**
- [ ] Add Flask-Migrate to requirements.txt
- [ ] Initialize Flask-Migrate in app.py
- [ ] Create initial migration from current schema
- [ ] Test migration upgrade
- [ ] Test migration downgrade
- [ ] Update Docker initialization to use migrations
- [ ] Update documentation with migration commands
- [ ] Create migration guide for developers

**Dependencies:**
```bash
Flask-Migrate==4.0.5
```

**Commands to Add:**
```bash
flask db init
flask db migrate -m "Initial migration"
flask db upgrade
flask db downgrade
```

**Acceptance Criteria:**
- Flask-Migrate properly configured
- Initial migration created and tested
- Docker containers use migrations on startup
- Documentation updated
- All existing data preserved during migration

**Estimated Effort:** 4-8 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 2
- Flask-Migrate docs: https://flask-migrate.readthedocs.io/

---

### Issue 4: Add Environment Variable Validation

**Title:** [CRITICAL] Validate Required Environment Variables on Startup

**Labels:** `critical`, `security`, `backend`, `configuration`

**Description:**
Add startup validation to ensure required environment variables are set and prevent production deployment with default development secrets.

**Current Problem:**
```python
# Default secrets allowed in production
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'jwt-secret-key-change-in-production')
```

**Tasks:**
- [ ] Create validate_config() function
- [ ] Check for production secret keys
- [ ] Validate ENCRYPTION_KEY format
- [ ] Validate database URL format
- [ ] Add environment-specific validations
- [ ] Fail fast on invalid configuration
- [ ] Add helpful error messages
- [ ] Update documentation

**Validation Rules:**
- In production: SECRET_KEY must not be default value
- In production: JWT_SECRET_KEY must not be default value
- ENCRYPTION_KEY must be valid Fernet key
- DATABASE_URL must be valid connection string

**Acceptance Criteria:**
- App refuses to start with invalid config in production
- Clear error messages for each validation failure
- Development mode still works with defaults
- All required env vars documented

**Estimated Effort:** 2-4 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 3

---

## 🟡 HIGH PRIORITY

### Issue 5: Implement Structured Logging and Monitoring

**Title:** [HIGH] Replace Print Statements with Structured Logging

**Labels:** `high`, `logging`, `monitoring`, `backend`, `infrastructure`

**Description:**
Replace print statements with structured JSON logging for better production debugging and monitoring.

**Tasks:**
- [ ] Add python-json-logger dependency
- [ ] Create logging configuration module
- [ ] Configure JSON formatter
- [ ] Replace print statements with logger calls
- [ ] Add contextual logging (user_id, script_id, etc.)
- [ ] Configure log levels by environment
- [ ] Add request logging middleware
- [ ] Document logging best practices

**Optional - Metrics:**
- [ ] Add prometheus-flask-exporter
- [ ] Expose /metrics endpoint
- [ ] Add custom metrics for script execution
- [ ] Document metrics setup

**Dependencies:**
```bash
python-json-logger==2.0.7
prometheus-flask-exporter==0.23.0  # optional
```

**Acceptance Criteria:**
- All print statements replaced with logger calls
- Logs output as JSON in production
- Contextual information included in logs
- Log levels configurable via environment

**Estimated Effort:** 8-16 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 4

---

### Issue 6: Add API Rate Limiting

**Title:** [HIGH] Implement API Rate Limiting to Prevent Abuse

**Labels:** `high`, `security`, `backend`, `api`

**Description:**
Add rate limiting to API endpoints to prevent abuse and protect system resources.

**Tasks:**
- [ ] Add Flask-Limiter dependency
- [ ] Configure rate limiter with Redis or memory storage
- [ ] Apply default rate limits (200/day, 50/hour)
- [ ] Add strict limits to execution endpoint (10/minute)
- [ ] Add limits to auth endpoints
- [ ] Configure rate limit headers
- [ ] Add rate limit error responses
- [ ] Document rate limits in API docs

**Dependencies:**
```bash
Flask-Limiter==3.5.0
```

**Rate Limits:**
- Default: 200 per day, 50 per hour
- Script execution: 10 per minute
- Login: 5 per minute
- Registration: 3 per hour

**Acceptance Criteria:**
- Rate limiting active on all endpoints
- Proper error responses (429 Too Many Requests)
- Rate limit headers in responses
- Configurable via environment variables

**Estimated Effort:** 4-6 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 5

---

### Issue 7: Add Input Validation with Marshmallow

**Title:** [HIGH] Implement Schema-Based Input Validation

**Labels:** `high`, `validation`, `backend`, `security`

**Description:**
Add comprehensive input validation using Marshmallow schemas to prevent invalid data and improve API robustness.

**Tasks:**
- [ ] Add marshmallow and flask-marshmallow dependencies
- [ ] Create schemas directory
- [ ] Create schema for script creation
- [ ] Create schema for script update
- [ ] Create schema for user registration
- [ ] Create schema for script execution
- [ ] Apply schemas to all POST/PUT endpoints
- [ ] Return detailed validation errors
- [ ] Document schema definitions

**Dependencies:**
```bash
marshmallow==3.20.1
flask-marshmallow==0.15.0
```

**Schemas to Create:**
- ScriptCreateSchema
- ScriptUpdateSchema
- UserRegistrationSchema
- UserLoginSchema
- ExecutionRequestSchema
- ParameterSchema

**Acceptance Criteria:**
- All input endpoints use schema validation
- Validation errors return 400 with details
- Invalid data rejected before database access
- Schema documentation available

**Estimated Effort:** 8-12 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 6

---

### Issue 8: Add React Error Boundaries

**Title:** [HIGH] Implement Error Boundaries to Prevent Full App Crashes

**Labels:** `high`, `frontend`, `error-handling`, `ux`

**Description:**
Add React Error Boundaries to catch component errors and prevent the entire app from crashing.

**Tasks:**
- [ ] Create ErrorBoundary component
- [ ] Add error fallback UI
- [ ] Integrate with error reporting (optional)
- [ ] Wrap Dashboard with ErrorBoundary
- [ ] Wrap major components with boundaries
- [ ] Add error recovery actions (reload, go back)
- [ ] Log errors to console
- [ ] Test error scenarios

**Features:**
- Graceful error display
- Error details for debugging
- Recovery actions (reload, navigate)
- Production-safe error messages

**Acceptance Criteria:**
- Component errors don't crash entire app
- User-friendly error messages shown
- Errors logged for debugging
- Recovery actions available

**Estimated Effort:** 2-4 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 7

---

### Issue 9: Enhance PowerShell Security Validation

**Title:** [HIGH] Strengthen PowerShell Script Security Validation

**Labels:** `high`, `security`, `backend`, `powershell`

**Description:**
Enhance PowerShell security validation to detect more sophisticated attack vectors and bypass attempts.

**Current Gaps:**
- Regex-based detection can be bypassed
- No module import restrictions
- No base64 encoding detection
- No obfuscation detection

**Tasks:**
- [ ] Add restricted cmdlets: Add-Type, New-Object, Register-ScheduledTask
- [ ] Add restricted module checking
- [ ] Detect base64 encoded commands
- [ ] Detect script block injection
- [ ] Detect obfuscation techniques (excessive backticks)
- [ ] Add comprehensive dangerous pattern list
- [ ] Write security validation tests
- [ ] Document security restrictions

**New Restricted Cmdlets:**
- Add-Type (can load C# code)
- New-Object (can create COM objects)
- Register-ScheduledTask (persistence)
- Set-MpPreference (disable AV)
- Set-ItemProperty (registry mods)

**Acceptance Criteria:**
- Enhanced cmdlet restrictions in place
- Module import restrictions working
- Obfuscation detection functional
- All security checks tested
- Documentation updated

**Estimated Effort:** 6-10 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 8

---

### Issue 10: Implement WebSocket Real-Time Script Output

**Title:** [HIGH] Add Real-Time Script Output via WebSockets

**Labels:** `high`, `feature`, `backend`, `frontend`, `ux`

**Description:**
Replace polling with WebSocket streaming for real-time script execution output.

**Current State:**
- SocketIO initialized but unused
- ExecutionConsole polls for updates
- Output only visible after completion

**Tasks:**

**Backend:**
- [ ] Implement WebSocket room joining
- [ ] Add output callback to PowerShellExecutor
- [ ] Emit output lines via SocketIO
- [ ] Emit execution status updates
- [ ] Handle client disconnections
- [ ] Test concurrent executions

**Frontend:**
- [ ] Connect to WebSocket on execution start
- [ ] Join execution room
- [ ] Listen for output events
- [ ] Append output lines in real-time
- [ ] Handle disconnections
- [ ] Add reconnection logic

**Acceptance Criteria:**
- Output appears in real-time during execution
- Multiple users can watch same execution
- Clean disconnection handling
- No polling needed
- Works for long-running scripts

**Estimated Effort:** 8-12 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 9

---

### Issue 11: Add OpenAPI/Swagger Documentation

**Title:** [HIGH] Generate Interactive API Documentation with Swagger

**Labels:** `high`, `documentation`, `backend`, `api`

**Description:**
Add interactive API documentation using OpenAPI/Swagger for better developer experience.

**Tasks:**
- [ ] Add flasgger dependency
- [ ] Configure Swagger
- [ ] Add docstrings to all endpoints with Swagger specs
- [ ] Document request/response schemas
- [ ] Add authentication documentation
- [ ] Configure Swagger UI
- [ ] Test API from Swagger interface
- [ ] Add examples for all endpoints

**Dependencies:**
```bash
flasgger==0.9.7.1
```

**Endpoints to Document:**
- All auth endpoints (4)
- All script endpoints (6)
- All execution endpoints (5+)

**Acceptance Criteria:**
- Swagger UI accessible at /apidocs/
- All endpoints documented
- Request/response schemas defined
- Authentication documented
- Try-it-out functionality works

**Estimated Effort:** 12-16 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 10

---

### Issue 12: Set Up CI/CD Pipeline

**Title:** [HIGH] Implement GitHub Actions CI/CD Pipeline

**Labels:** `high`, `infrastructure`, `devops`, `testing`

**Description:**
Create automated CI/CD pipeline for testing, building, and deploying the application.

**Tasks:**

**Testing:**
- [ ] Create GitHub Actions workflow
- [ ] Set up backend test job
- [ ] Set up frontend test job
- [ ] Add code coverage reporting
- [ ] Upload to codecov

**Building:**
- [ ] Add Docker build job
- [ ] Test Docker Compose deployment
- [ ] Add security scanning
- [ ] Add dependency auditing

**Deployment (optional):**
- [ ] Add deployment to staging
- [ ] Add deployment to production
- [ ] Require manual approval for prod

**Workflow File:** `.github/workflows/ci.yml`

**Acceptance Criteria:**
- Tests run on every push and PR
- Docker builds succeed
- Coverage reports generated
- Security scans pass
- Badge in README

**Estimated Effort:** 8-12 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 14

---

### Issue 13: Add Security Headers with Flask-Talisman

**Title:** [HIGH] Implement Security Headers for Production

**Labels:** `high`, `security`, `backend`

**Description:**
Add security headers (CSP, HSTS, etc.) to protect against common web vulnerabilities.

**Tasks:**
- [ ] Add Flask-Talisman dependency
- [ ] Configure Content Security Policy
- [ ] Configure HSTS
- [ ] Configure referrer policy
- [ ] Configure feature policy
- [ ] Test in development
- [ ] Enable HTTPS enforcement in production
- [ ] Document security headers

**Dependencies:**
```bash
flask-talisman==1.1.0
```

**Headers to Add:**
- Content-Security-Policy
- Strict-Transport-Security
- X-Content-Type-Options
- X-Frame-Options
- Referrer-Policy

**Acceptance Criteria:**
- Security headers present in responses
- CSP configured for Monaco editor
- HTTPS enforced in production
- Security scan passes

**Estimated Effort:** 2-4 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 15

---

### Issue 14: Implement JWT Token Refresh

**Title:** [HIGH] Add JWT Refresh Token Mechanism

**Labels:** `high`, `security`, `backend`, `authentication`

**Description:**
Implement refresh token mechanism to allow users to stay logged in without compromising security.

**Current State:**
- JWTs expire after 24 hours
- No refresh mechanism
- Users must re-login

**Tasks:**
- [ ] Configure access token expiry (1 hour)
- [ ] Configure refresh token expiry (30 days)
- [ ] Create /auth/refresh endpoint
- [ ] Add refresh token validation
- [ ] Update frontend to use refresh tokens
- [ ] Store refresh token securely
- [ ] Add token rotation
- [ ] Test token refresh flow

**Acceptance Criteria:**
- Access tokens expire after 1 hour
- Refresh tokens last 30 days
- Frontend auto-refreshes tokens
- Old refresh tokens invalidated after use
- Logout invalidates refresh tokens

**Estimated Effort:** 4-6 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 24

---

### Issue 15: Add Password Policy Enforcement

**Title:** [HIGH] Enforce Strong Password Requirements

**Labels:** `high`, `security`, `backend`, `authentication`

**Description:**
Implement password strength validation to enforce security best practices.

**Current State:**
- No password complexity requirements
- Any password accepted

**Tasks:**
- [ ] Create password validation function
- [ ] Require minimum 12 characters
- [ ] Require uppercase letter
- [ ] Require lowercase letter
- [ ] Require number
- [ ] Require special character
- [ ] Apply to registration
- [ ] Apply to password changes
- [ ] Return helpful error messages
- [ ] Update frontend with requirements

**Password Requirements:**
- Minimum 12 characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 number
- At least 1 special character

**Acceptance Criteria:**
- Weak passwords rejected
- Clear error messages
- Requirements shown in UI
- Existing users not affected

**Estimated Effort:** 3-5 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 27

---

### Issue 16: Improve CORS Configuration

**Title:** [HIGH] Make CORS Origins Configurable via Environment

**Labels:** `high`, `security`, `backend`, `configuration`

**Description:**
Move hardcoded CORS origins to environment variables for better deployment flexibility.

**Current Problem:**
```python
CORS(app, resources={
    r"/api/*": {
        "origins": ["http://localhost:5173", "http://localhost:3000"],  # Hardcoded
```

**Tasks:**
- [ ] Add ALLOWED_ORIGINS environment variable
- [ ] Parse comma-separated origins
- [ ] Update CORS configuration
- [ ] Update .env.example
- [ ] Update documentation
- [ ] Test with different origins

**Configuration:**
```bash
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000,https://app.example.com
```

**Acceptance Criteria:**
- CORS origins configurable via env var
- Multiple origins supported
- Default localhost origins for development
- Documentation updated

**Estimated Effort:** 1-2 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 26

---

## 🟢 MEDIUM PRIORITY

### Issue 17: Implement Frontend State Management with Zustand

**Title:** [MEDIUM] Refactor State Management with Zustand

**Labels:** `medium`, `frontend`, `refactoring`, `architecture`

**Description:**
Implement centralized state management to reduce prop drilling and improve code organization.

**Tasks:**
- [ ] Add zustand dependency
- [ ] Create scriptStore
- [ ] Create executionStore
- [ ] Create userStore
- [ ] Migrate ScriptList to use store
- [ ] Migrate Dashboard to use store
- [ ] Remove unnecessary prop drilling
- [ ] Add store persistence (optional)
- [ ] Document store usage

**Stores to Create:**
- scriptStore (scripts, loading, CRUD operations)
- executionStore (executions, real-time updates)
- userStore (current user, preferences)

**Acceptance Criteria:**
- Zustand integrated
- Major components using stores
- Less prop drilling
- State properly synchronized
- Documentation updated

**Estimated Effort:** 12-20 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 11

---

### Issue 18: Add Redis Caching Layer

**Title:** [MEDIUM] Implement Caching for Frequently Accessed Data

**Labels:** `medium`, `performance`, `backend`, `infrastructure`

**Description:**
Add Redis caching to improve performance for frequently accessed data like categories and public scripts.

**Tasks:**
- [ ] Add Flask-Caching dependency
- [ ] Configure Redis connection
- [ ] Add caching to categories endpoint
- [ ] Add caching to public scripts list
- [ ] Implement cache invalidation on updates
- [ ] Configure cache TTL appropriately
- [ ] Add cache statistics endpoint
- [ ] Document caching strategy

**Dependencies:**
```bash
Flask-Caching==2.1.0
```

**Endpoints to Cache:**
- GET /api/scripts/categories (1 hour)
- GET /api/scripts/ (public only, 5 minutes)
- GET /api/execution/system/info (1 hour)

**Acceptance Criteria:**
- Redis caching configured
- Key endpoints cached
- Cache invalidation working
- Performance improvement measurable

**Estimated Effort:** 6-10 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 12

---

### Issue 19: Enhance Script Versioning Features

**Title:** [MEDIUM] Add Version Comparison and Rollback

**Labels:** `medium`, `feature`, `backend`, `frontend`

**Description:**
Enhance script versioning with diff comparison and rollback capabilities.

**Current State:**
- Versions stored but not fully utilized
- No UI for version history
- No rollback capability

**Tasks:**

**Backend:**
- [ ] Create version restore endpoint
- [ ] Create version diff endpoint
- [ ] Add version metadata
- [ ] Test rollback functionality

**Frontend:**
- [ ] Create version history component
- [ ] Add diff viewer
- [ ] Add restore button
- [ ] Show version timeline
- [ ] Confirm before restore

**Acceptance Criteria:**
- Version history visible in UI
- Diff comparison between versions
- Rollback functionality works
- New version created on rollback

**Estimated Effort:** 12-16 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 13

---

### Issue 20: Add Database Query Optimization

**Title:** [MEDIUM] Optimize Database Queries with Indexes

**Labels:** `medium`, `performance`, `database`, `backend`

**Description:**
Add database indexes on frequently queried fields to improve query performance.

**Tasks:**
- [ ] Analyze query patterns
- [ ] Add composite index on scripts (category, created_at)
- [ ] Add composite index on scripts (author_id, is_public)
- [ ] Add composite index on executions (user_id, started_at)
- [ ] Add composite index on executions (script_id, status)
- [ ] Create migration for indexes
- [ ] Benchmark query performance
- [ ] Document indexing strategy

**Indexes to Add:**
```python
__table_args__ = (
    db.Index('idx_script_category_created', 'category', 'created_at'),
    db.Index('idx_script_author_public', 'author_id', 'is_public'),
    db.Index('idx_execution_user_started', 'user_id', 'started_at'),
    db.Index('idx_execution_script_status', 'script_id', 'status'),
)
```

**Acceptance Criteria:**
- Indexes added via migration
- Query performance improved
- No breaking changes
- Documentation updated

**Estimated Effort:** 4-8 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 22

---

### Issue 21: Implement API Pagination

**Title:** [MEDIUM] Add Pagination to List Endpoints

**Labels:** `medium`, `api`, `backend`, `performance`

**Description:**
Add pagination to list endpoints to prevent returning thousands of records in a single response.

**Current Problem:**
- No pagination on /api/scripts/
- No pagination on /api/execution/executions
- Could return thousands of records

**Tasks:**
- [ ] Add pagination to scripts list endpoint
- [ ] Add pagination to executions list endpoint
- [ ] Add pagination to users list endpoint
- [ ] Support page and per_page parameters
- [ ] Return pagination metadata
- [ ] Limit max per_page to 100
- [ ] Update frontend to use pagination
- [ ] Add pagination controls to UI

**Response Format:**
```json
{
  "scripts": [...],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "pages": 8
  }
}
```

**Acceptance Criteria:**
- All list endpoints paginated
- Frontend shows pagination controls
- Performance improved for large datasets
- API documentation updated

**Estimated Effort:** 6-10 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 23

---

### Issue 22: Add Dependency Security Scanning

**Title:** [MEDIUM] Implement Automated Dependency Security Scanning

**Labels:** `medium`, `security`, `devops`, `infrastructure`

**Description:**
Add automated security scanning for dependencies in CI/CD pipeline and enable Dependabot.

**Tasks:**
- [ ] Create Dependabot configuration
- [ ] Enable Dependabot alerts
- [ ] Add Safety check to backend CI
- [ ] Add npm audit to frontend CI
- [ ] Configure security scan thresholds
- [ ] Set up security notifications
- [ ] Document security update process

**Files to Create:**
- .github/dependabot.yml
- Security scanning in CI workflow

**Acceptance Criteria:**
- Dependabot configured for backend and frontend
- Security scans run in CI
- Critical vulnerabilities block merge
- Notifications configured

**Estimated Effort:** 2-4 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 28

---

### Issue 23: Optimize Database Connection Pooling

**Title:** [MEDIUM] Configure Production Database Connection Pooling

**Labels:** `medium`, `performance`, `database`, `backend`

**Description:**
Optimize SQLAlchemy connection pooling for production workloads.

**Tasks:**
- [ ] Configure pool_size
- [ ] Configure pool_recycle
- [ ] Enable pool_pre_ping
- [ ] Configure max_overflow
- [ ] Test under load
- [ ] Document configuration
- [ ] Add monitoring

**Configuration:**
```python
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 10,
    'pool_recycle': 3600,
    'pool_pre_ping': True,
    'max_overflow': 20
}
```

**Acceptance Criteria:**
- Connection pooling optimized
- No connection leaks
- Performance improved under load
- Documentation updated

**Estimated Effort:** 1-2 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 34

---

### Issue 24: Add Code Quality Tools (Black, Pylint, Mypy)

**Title:** [MEDIUM] Implement Code Quality Tools and Pre-commit Hooks

**Labels:** `medium`, `code-quality`, `backend`, `devops`

**Description:**
Add automated code formatting, linting, and type checking to maintain code quality.

**Tasks:**
- [ ] Add black, pylint, mypy to dev dependencies
- [ ] Configure black formatting
- [ ] Configure pylint rules
- [ ] Configure mypy type checking
- [ ] Add pre-commit hooks
- [ ] Run on all existing code
- [ ] Add to CI pipeline
- [ ] Document code quality standards

**Dependencies:**
```bash
black==23.12.0
pylint==3.0.3
mypy==1.7.1
pre-commit==3.5.0
```

**Acceptance Criteria:**
- Code formatting automated
- Linting configured
- Type checking enabled
- Pre-commit hooks working
- CI enforces standards

**Estimated Effort:** 4-8 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 39

---

### Issue 25: Add Type Hints to Backend

**Title:** [MEDIUM] Add Type Hints Throughout Backend Codebase

**Labels:** `medium`, `code-quality`, `backend`, `refactoring`

**Description:**
Add Python type hints to all functions and methods for better code clarity and IDE support.

**Tasks:**
- [ ] Add type hints to models.py
- [ ] Add type hints to app.py
- [ ] Add type hints to all route handlers
- [ ] Add type hints to services
- [ ] Configure mypy
- [ ] Fix type checking errors
- [ ] Document type hinting standards

**Example:**
```python
from typing import List, Dict, Optional, Tuple

def execute_script(
    script_id: int,
    parameters: Optional[Dict[str, any]] = None,
    timeout: int = 300
) -> Dict[str, any]:
    ...
```

**Acceptance Criteria:**
- All functions have type hints
- Mypy passes with no errors
- IDE autocomplete improved
- Documentation updated

**Estimated Effort:** 12-16 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 40

---

### Issue 26: Optimize Frontend Bundle Size

**Title:** [MEDIUM] Analyze and Optimize Frontend Bundle Size

**Labels:** `medium`, `performance`, `frontend`, `optimization`

**Description:**
Analyze and optimize frontend bundle size for faster load times.

**Tasks:**
- [ ] Add rollup-plugin-visualizer
- [ ] Generate bundle analysis
- [ ] Identify large dependencies
- [ ] Implement code splitting
- [ ] Add lazy loading for routes
- [ ] Optimize imports (tree shaking)
- [ ] Measure improvement
- [ ] Document optimization strategies

**Dependencies:**
```bash
npm install --save-dev rollup-plugin-visualizer
```

**Techniques:**
- Code splitting
- Lazy loading components
- Tree shaking
- Import optimization

**Acceptance Criteria:**
- Bundle size reduced by 20%+
- Initial load time improved
- Lazy loading implemented
- Bundle analysis documented

**Estimated Effort:** 4-6 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 35

---

## 🔵 LOW PRIORITY / NICE-TO-HAVE

### Issue 27: Implement Script Scheduling

**Title:** [FEATURE] Add Scheduled Script Execution (Cron-like)

**Labels:** `enhancement`, `feature`, `backend`, `frontend`

**Description:**
Allow users to schedule scripts to run at specific times or intervals.

**Tasks:**

**Backend:**
- [ ] Add APScheduler dependency
- [ ] Create Schedule model
- [ ] Create schedule CRUD endpoints
- [ ] Implement job scheduling
- [ ] Handle execution on schedule
- [ ] Add schedule validation
- [ ] Test scheduled executions

**Frontend:**
- [ ] Create schedule editor component
- [ ] Add cron expression builder
- [ ] Show scheduled jobs
- [ ] Add enable/disable toggle
- [ ] Show next run time

**Dependencies:**
```bash
APScheduler==3.10.4
```

**Acceptance Criteria:**
- Scripts can be scheduled
- Multiple schedule types supported (cron, interval)
- Schedules can be enabled/disabled
- Execution history shows scheduled runs

**Estimated Effort:** 20-30 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 16

---

### Issue 28: Create Script Templates Library

**Title:** [FEATURE] Add Pre-built Script Templates

**Labels:** `enhancement`, `feature`, `backend`, `frontend`, `content`

**Description:**
Provide a library of pre-built PowerShell script templates for common tasks.

**Tasks:**
- [ ] Create template scripts for VMware
- [ ] Create template scripts for Azure
- [ ] Create template scripts for Active Directory
- [ ] Create template scripts for utilities
- [ ] Add "Create from Template" UI
- [ ] Add template preview
- [ ] Document template usage
- [ ] Allow community templates (optional)

**Template Categories:**
- VMware (VM management, inventory, backups)
- Azure (resource management, monitoring)
- Active Directory (user management, group policy)
- Utilities (file operations, system info)

**Acceptance Criteria:**
- 10+ templates available
- Templates categorized
- "Create from Template" button works
- Templates are customizable

**Estimated Effort:** 16-24 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 17

---

### Issue 29: Add Dark/Light Mode Toggle

**Title:** [FEATURE] Implement Theme Toggle (Dark/Light Mode)

**Labels:** `enhancement`, `frontend`, `ux`, `ui`

**Description:**
Add user preference for light/dark theme with system preference detection.

**Tasks:**
- [ ] Create theme context
- [ ] Add light mode Tailwind config
- [ ] Store preference in localStorage
- [ ] Add theme toggle button
- [ ] Detect system preference
- [ ] Apply theme on load
- [ ] Update all components for light mode
- [ ] Test both themes

**Features:**
- Dark mode (current)
- Light mode
- System preference detection
- Toggle in header
- Persistent preference

**Acceptance Criteria:**
- Theme toggle works
- Preference persisted
- Both themes look good
- System preference respected

**Estimated Effort:** 8-12 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 30

---

### Issue 30: Add Script Favorites/Bookmarks

**Title:** [FEATURE] Allow Users to Star/Favorite Scripts

**Labels:** `enhancement`, `feature`, `backend`, `frontend`, `ux`

**Description:**
Allow users to mark frequently used scripts as favorites for quick access.

**Tasks:**

**Backend:**
- [ ] Create Favorite model
- [ ] Create favorite endpoints (add, remove, list)
- [ ] Add favorite count to scripts
- [ ] Filter scripts by favorites

**Frontend:**
- [ ] Add star icon to script cards
- [ ] Add favorites filter
- [ ] Show favorite count
- [ ] Optimize UI for favorites

**Acceptance Criteria:**
- Users can star/unstar scripts
- Favorites filter works
- Star state persisted
- Quick access to favorite scripts

**Estimated Effort:** 8-12 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 31

---

### Issue 31: Implement Keyboard Shortcuts

**Title:** [FEATURE] Add Power User Keyboard Shortcuts

**Labels:** `enhancement`, `frontend`, `ux`, `accessibility`

**Description:**
Add keyboard shortcuts for common actions to improve power user experience.

**Tasks:**
- [ ] Add react-hotkeys-hook dependency
- [ ] Implement Ctrl/Cmd+K for quick search
- [ ] Implement Ctrl/Cmd+N for new script
- [ ] Implement Ctrl/Cmd+S for save
- [ ] Implement Ctrl/Cmd+Enter for execute
- [ ] Add Esc for close modals
- [ ] Create keyboard shortcuts help modal
- [ ] Show shortcuts on hover

**Shortcuts:**
- `Ctrl/Cmd + K`: Quick search
- `Ctrl/Cmd + N`: New script
- `Ctrl/Cmd + S`: Save script
- `Ctrl/Cmd + Enter`: Execute
- `Esc`: Close modal
- `?`: Show shortcuts help

**Acceptance Criteria:**
- All shortcuts work
- No conflicts with browser shortcuts
- Help modal shows all shortcuts
- Accessibility maintained

**Estimated Effort:** 6-10 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 32

---

### Issue 32: Add Multi-tenancy Support

**Title:** [FEATURE] Implement Multi-tenant Architecture

**Labels:** `enhancement`, `feature`, `backend`, `frontend`, `architecture`

**Description:**
Add multi-tenancy support to isolate users and scripts by organization.

**Tasks:**

**Backend:**
- [ ] Create Organization model
- [ ] Link users to organizations
- [ ] Add organization context to all queries
- [ ] Implement organization switching
- [ ] Add organization admin role
- [ ] Isolate data by organization
- [ ] Add organization settings

**Frontend:**
- [ ] Add organization selector
- [ ] Show current organization
- [ ] Add organization management UI
- [ ] Update all queries with org context

**Acceptance Criteria:**
- Complete data isolation between orgs
- Organization switching works
- Admin can manage organization
- Backward compatible with existing data

**Estimated Effort:** 40-60 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 18

---

### Issue 33: Implement Approval Workflows

**Title:** [FEATURE] Add Script Execution Approval System

**Labels:** `enhancement`, `feature`, `backend`, `frontend`, `governance`

**Description:**
Require approval before executing certain high-risk scripts.

**Tasks:**

**Backend:**
- [ ] Add approval_required flag to scripts
- [ ] Create ApprovalRequest model
- [ ] Create approval request endpoints
- [ ] Implement approval logic
- [ ] Add notification system
- [ ] Track approval history

**Frontend:**
- [ ] Add approval required checkbox
- [ ] Create approval request UI
- [ ] Add approver list
- [ ] Show pending approvals
- [ ] Add approval/reject actions
- [ ] Show approval status

**Features:**
- Require approval for dangerous scripts
- Multiple approvers
- Approval notifications
- Approval history

**Acceptance Criteria:**
- Approval workflow functional
- Notifications sent to approvers
- History tracked
- UI intuitive

**Estimated Effort:** 24-32 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 19

---

### Issue 34: Add Advanced Search

**Title:** [FEATURE] Implement Full-Text Search and Advanced Filters

**Labels:** `enhancement`, `feature`, `backend`, `frontend`

**Description:**
Add full-text search and advanced filtering capabilities for scripts.

**Tasks:**

**Backend:**
- [ ] Implement PostgreSQL full-text search
- [ ] Or integrate Elasticsearch
- [ ] Add search indexing
- [ ] Create advanced filter endpoint
- [ ] Support multiple filter criteria
- [ ] Add search result ranking

**Frontend:**
- [ ] Create advanced search UI
- [ ] Add filter builder
- [ ] Add saved searches
- [ ] Add search suggestions
- [ ] Show search highlights

**Features:**
- Full-text search in script content
- Filter by multiple criteria
- Saved search filters
- Search suggestions

**Acceptance Criteria:**
- Fast full-text search
- Multiple filter support
- Saved searches work
- Search results ranked

**Estimated Effort:** 16-24 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 20

---

### Issue 35: Add Granular User Permissions

**Title:** [FEATURE] Implement Fine-Grained Permission System

**Labels:** `enhancement`, `feature`, `backend`, `security`

**Description:**
Replace simple admin/user roles with granular permissions system.

**Tasks:**
- [ ] Design permission model
- [ ] Create Permission model
- [ ] Create Role model with permissions
- [ ] Implement permission checking
- [ ] Create permission management UI
- [ ] Add permission decorators
- [ ] Migrate existing users
- [ ] Document permission system

**Permissions:**
- script.create
- script.edit.own / script.edit.all
- script.execute.own / script.execute.all
- script.delete.own / script.delete.all
- execution.view.own / execution.view.all
- user.manage
- system.configure

**Acceptance Criteria:**
- Granular permissions work
- Backward compatible
- UI for permission management
- Documentation complete

**Estimated Effort:** 16-24 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 42

---

### Issue 36: Add Comprehensive Audit Logging

**Title:** [FEATURE] Implement Full Audit Trail System

**Labels:** `enhancement`, `feature`, `backend`, `security`, `compliance`

**Description:**
Add comprehensive audit logging beyond script executions for compliance and security.

**Tasks:**
- [ ] Create AuditLog model
- [ ] Log user authentication events
- [ ] Log script CRUD operations
- [ ] Log permission changes
- [ ] Log configuration changes
- [ ] Add audit log viewer
- [ ] Add audit log export
- [ ] Add audit log retention policy

**Events to Log:**
- User login/logout
- Failed login attempts
- Script create/update/delete
- Script execution
- Permission changes
- User management
- Configuration changes

**Acceptance Criteria:**
- All important events logged
- Audit viewer functional
- Export capability
- Retention policy configurable

**Estimated Effort:** 12-16 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 43

---

### Issue 37: Create Deployment Guide

**Title:** [DOCS] Write Comprehensive Production Deployment Guide

**Labels:** `documentation`, `devops`

**Description:**
Create detailed documentation for deploying PSMachine to production environments.

**Tasks:**
- [ ] Document cloud deployment (AWS)
- [ ] Document cloud deployment (Azure)
- [ ] Document cloud deployment (GCP)
- [ ] Document Kubernetes deployment
- [ ] Document SSL/TLS setup
- [ ] Document backup strategy
- [ ] Document disaster recovery
- [ ] Document monitoring setup
- [ ] Document scaling considerations
- [ ] Add deployment examples

**Topics:**
- Cloud platform deployment
- Kubernetes manifests
- SSL/TLS configuration
- Backup and restore
- Monitoring and alerting
- Scaling strategies
- Security hardening

**Acceptance Criteria:**
- Comprehensive deployment guide
- Multiple platform examples
- Security best practices
- Troubleshooting section

**Estimated Effort:** 12-16 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 37

---

### Issue 38: Create User Manual

**Title:** [DOCS] Write End-User Documentation and Tutorials

**Labels:** `documentation`, `user-experience`

**Description:**
Create comprehensive end-user documentation with tutorials and guides.

**Tasks:**
- [ ] Write getting started guide
- [ ] Create script creation tutorial
- [ ] Document parameter definitions
- [ ] Create execution tutorial
- [ ] Add troubleshooting guide
- [ ] Create video tutorials (optional)
- [ ] Add screenshots
- [ ] Create FAQ section

**Topics:**
- Getting started
- Creating scripts
- Defining parameters
- Executing scripts
- Managing versions
- Viewing history
- Troubleshooting

**Acceptance Criteria:**
- Complete user manual
- Step-by-step tutorials
- Screenshots included
- Easy to follow

**Estimated Effort:** 20-30 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 38

---

### Issue 39: Add Script Categories Management

**Title:** [FEATURE] Allow Admins to Manage Script Categories

**Labels:** `enhancement`, `feature`, `backend`, `frontend`

**Description:**
Replace hardcoded script categories with database-managed categories.

**Current Problem:**
- Categories hardcoded in backend
- Can't add new categories without code change

**Tasks:**

**Backend:**
- [ ] Create Category model
- [ ] Create category CRUD endpoints
- [ ] Migrate existing categories
- [ ] Update script model FK
- [ ] Add default categories

**Frontend:**
- [ ] Create category management UI (admin)
- [ ] Update category selector
- [ ] Add category icons/colors
- [ ] Handle category changes

**Acceptance Criteria:**
- Categories managed in database
- Admin can CRUD categories
- Existing scripts migrated
- UI updated

**Estimated Effort:** 8-12 hours

**References:**
- See IMPROVEMENT_SUGGESTIONS.md Section 41

---

## Issue Creation Summary

**Total Issues:** 39

**By Priority:**
- 🔴 Critical: 4 issues
- 🟡 High: 12 issues
- 🟢 Medium: 10 issues
- 🔵 Low/Nice-to-Have: 13 issues

**By Category:**
- Testing: 2 issues
- Security: 9 issues
- Infrastructure: 8 issues
- Features: 12 issues
- Performance: 5 issues
- Documentation: 3 issues

**Estimated Total Effort:** 400-600 hours

---

## How to Use This File

### Option 1: Manual Creation
Copy each issue section and paste into GitHub's "New Issue" form.

### Option 2: GitHub CLI (if available)
```bash
# Install gh CLI first
# Then use gh issue create --title "..." --body "..."
```

### Option 3: GitHub API Script
Create a script to bulk-create issues using GitHub API.

### Option 4: Issue Templates
The issues above are formatted ready for copy-paste into GitHub.

---

**Next Steps:**
1. Review and prioritize issues
2. Create issues in GitHub
3. Assign to milestones
4. Begin implementation starting with Critical issues

