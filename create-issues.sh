#!/bin/bash
#
# GitHub Issue Creator Script for PSMachine
#
# This script creates all 39 improvement issues in your GitHub repository.
# Requires GitHub CLI (gh) to be installed and authenticated.
#
# Installation: https://cli.github.com/
# Usage: ./create-issues.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  PSMachine GitHub Issue Creator${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
    echo "Please install from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not authenticated with GitHub CLI.${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✓ GitHub CLI is installed and authenticated${NC}"
echo ""

# Confirm with user
read -p "This will create 39 issues in your repository. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo -e "${YELLOW}Creating issues...${NC}"
echo ""

# Counter for created issues
CREATED=0
FAILED=0

# Function to create an issue
create_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    if gh issue create --title "$title" --body "$body" --label "$labels" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Created: $title"
        ((CREATED++))
    else
        echo -e "${RED}✗${NC} Failed: $title"
        ((FAILED++))
    fi
}

#####################################################
# CRITICAL PRIORITY ISSUES
#####################################################

echo -e "${RED}Creating Critical Priority Issues (4)...${NC}"

create_issue \
"[CRITICAL] Add Backend Testing Infrastructure with pytest" \
"Implement comprehensive testing infrastructure for the Flask backend to ensure code quality and prevent regressions.

## Tasks
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

## Dependencies
\`\`\`bash
pytest==7.4.3
pytest-cov==4.1.0
pytest-flask==1.3.0
pytest-mock==3.12.0
factory-boy==3.3.0
\`\`\`

## Target Structure
\`\`\`
backend/tests/
├── __init__.py
├── conftest.py
├── test_models.py
├── test_auth.py
├── test_scripts.py
├── test_execution.py
├── test_powershell_executor.py
└── test_security.py
\`\`\`

## Acceptance Criteria
- All API endpoints have integration tests
- All models have unit tests
- All services have unit tests
- 80%+ code coverage
- Tests pass in CI/CD

**Estimated Effort:** 40-60 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 1" \
"critical,testing,backend,infrastructure"

create_issue \
"[CRITICAL] Add Frontend Testing Infrastructure with Vitest and React Testing Library" \
"Implement comprehensive testing infrastructure for the React frontend to ensure component reliability and prevent regressions.

## Tasks
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

## Dependencies
\`\`\`json
{
  \"@testing-library/react\": \"^14.1.2\",
  \"@testing-library/jest-dom\": \"^6.1.5\",
  \"@testing-library/user-event\": \"^14.5.1\",
  \"vitest\": \"^1.0.4\",
  \"@vitest/ui\": \"^1.0.4\",
  \"jsdom\": \"^23.0.1\"
}
\`\`\`

## Acceptance Criteria
- All components have unit tests
- All contexts have tests
- API service has tests
- 70%+ code coverage
- Tests pass in CI/CD

**Estimated Effort:** 40-60 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 1" \
"critical,testing,frontend,infrastructure"

create_issue \
"[CRITICAL] Replace db.create_all() with Flask-Migrate for Database Migrations" \
"Current database initialization uses db.create_all() which is not production-safe. Implement proper migration management with Flask-Migrate (Alembic) for version-controlled schema changes and rollback capability.

## Current Problem
\`\`\`python
# In app.py:106-124
def init_db():
    with app.app_context():
        db.create_all()  # ❌ Not production-ready
\`\`\`

## Tasks
- [ ] Add Flask-Migrate to requirements.txt ✅ DONE
- [ ] Initialize Flask-Migrate in app.py ✅ DONE
- [ ] Create initial migration from current schema
- [ ] Test migration upgrade
- [ ] Test migration downgrade
- [ ] Update Docker initialization to use migrations
- [ ] Update documentation with migration commands ✅ DONE
- [ ] Create migration guide for developers ✅ DONE

## Commands to Add
\`\`\`bash
flask db init
flask db migrate -m \"Initial migration\"
flask db upgrade
flask db downgrade
\`\`\`

## Acceptance Criteria
- Flask-Migrate properly configured ✅ DONE
- Initial migration created and tested
- Docker containers use migrations on startup
- Documentation updated ✅ DONE
- All existing data preserved during migration

**Estimated Effort:** 4-8 hours (partially complete)

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 2 and backend/MIGRATIONS.md" \
"critical,database,backend,infrastructure"

create_issue \
"[CRITICAL] Validate Required Environment Variables on Startup" \
"Add startup validation to ensure required environment variables are set and prevent production deployment with default development secrets.

## Tasks
- [ ] Create validate_config() function ✅ DONE
- [ ] Check for production secret keys ✅ DONE
- [ ] Validate ENCRYPTION_KEY format ✅ DONE
- [ ] Validate database URL format ✅ DONE
- [ ] Add environment-specific validations ✅ DONE
- [ ] Fail fast on invalid configuration ✅ DONE
- [ ] Add helpful error messages ✅ DONE
- [ ] Update documentation

## Validation Rules
- In production: SECRET_KEY must not be default value ✅
- In production: JWT_SECRET_KEY must not be default value ✅
- ENCRYPTION_KEY must be valid Fernet key ✅
- DATABASE_URL must be valid connection string ✅

## Acceptance Criteria
- App refuses to start with invalid config in production ✅ DONE
- Clear error messages for each validation failure ✅ DONE
- Development mode still works with defaults ✅ DONE
- All required env vars documented

**Estimated Effort:** 2-4 hours (complete - needs documentation)

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 3" \
"critical,security,backend,configuration"

#####################################################
# HIGH PRIORITY ISSUES
#####################################################

echo -e "${YELLOW}Creating High Priority Issues (12)...${NC}"

create_issue \
"[HIGH] Replace Print Statements with Structured Logging" \
"Replace print statements with structured JSON logging for better production debugging and monitoring.

## Tasks
- [ ] Add python-json-logger dependency
- [ ] Create logging configuration module
- [ ] Configure JSON formatter
- [ ] Replace print statements with logger calls
- [ ] Add contextual logging (user_id, script_id, etc.)
- [ ] Configure log levels by environment
- [ ] Add request logging middleware
- [ ] Document logging best practices

## Optional - Metrics
- [ ] Add prometheus-flask-exporter
- [ ] Expose /metrics endpoint
- [ ] Add custom metrics for script execution
- [ ] Document metrics setup

## Dependencies
\`\`\`bash
python-json-logger==2.0.7
prometheus-flask-exporter==0.23.0  # optional
\`\`\`

## Acceptance Criteria
- All print statements replaced with logger calls
- Logs output as JSON in production
- Contextual information included in logs
- Log levels configurable via environment

**Estimated Effort:** 8-16 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 4" \
"high,logging,monitoring,backend,infrastructure"

create_issue \
"[HIGH] Implement API Rate Limiting to Prevent Abuse" \
"Add rate limiting to API endpoints to prevent abuse and protect system resources.

## Tasks
- [ ] Add Flask-Limiter dependency
- [ ] Configure rate limiter with Redis or memory storage
- [ ] Apply default rate limits (200/day, 50/hour)
- [ ] Add strict limits to execution endpoint (10/minute)
- [ ] Add limits to auth endpoints
- [ ] Configure rate limit headers
- [ ] Add rate limit error responses
- [ ] Document rate limits in API docs

## Dependencies
\`\`\`bash
Flask-Limiter==3.5.0
\`\`\`

## Rate Limits
- Default: 200 per day, 50 per hour
- Script execution: 10 per minute
- Login: 5 per minute
- Registration: 3 per hour

## Acceptance Criteria
- Rate limiting active on all endpoints
- Proper error responses (429 Too Many Requests)
- Rate limit headers in responses
- Configurable via environment variables

**Estimated Effort:** 4-6 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 5" \
"high,security,backend,api"

create_issue \
"[HIGH] Implement Schema-Based Input Validation with Marshmallow" \
"Add comprehensive input validation using Marshmallow schemas to prevent invalid data and improve API robustness.

## Tasks
- [ ] Add marshmallow and flask-marshmallow dependencies
- [ ] Create schemas directory
- [ ] Create schema for script creation
- [ ] Create schema for script update
- [ ] Create schema for user registration
- [ ] Create schema for script execution
- [ ] Apply schemas to all POST/PUT endpoints
- [ ] Return detailed validation errors
- [ ] Document schema definitions

## Dependencies
\`\`\`bash
marshmallow==3.20.1
flask-marshmallow==0.15.0
\`\`\`

## Schemas to Create
- ScriptCreateSchema
- ScriptUpdateSchema
- UserRegistrationSchema
- UserLoginSchema
- ExecutionRequestSchema
- ParameterSchema

## Acceptance Criteria
- All input endpoints use schema validation
- Validation errors return 400 with details
- Invalid data rejected before database access
- Schema documentation available

**Estimated Effort:** 8-12 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 6" \
"high,validation,backend,security"

create_issue \
"[HIGH] Implement Error Boundaries to Prevent Full App Crashes" \
"Add React Error Boundaries to catch component errors and prevent the entire app from crashing.

## Tasks
- [ ] Create ErrorBoundary component
- [ ] Add error fallback UI
- [ ] Integrate with error reporting (optional)
- [ ] Wrap Dashboard with ErrorBoundary
- [ ] Wrap major components with boundaries
- [ ] Add error recovery actions (reload, go back)
- [ ] Log errors to console
- [ ] Test error scenarios

## Features
- Graceful error display
- Error details for debugging
- Recovery actions (reload, navigate)
- Production-safe error messages

## Acceptance Criteria
- Component errors don't crash entire app
- User-friendly error messages shown
- Errors logged for debugging
- Recovery actions available

**Estimated Effort:** 2-4 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 7" \
"high,frontend,error-handling,ux"

create_issue \
"[HIGH] Strengthen PowerShell Script Security Validation" \
"Enhance PowerShell security validation to detect more sophisticated attack vectors and bypass attempts.

## Current Gaps
- Regex-based detection can be bypassed
- No module import restrictions
- No base64 encoding detection
- No obfuscation detection

## Tasks
- [ ] Add restricted cmdlets: Add-Type, New-Object, Register-ScheduledTask
- [ ] Add restricted module checking
- [ ] Detect base64 encoded commands
- [ ] Detect script block injection
- [ ] Detect obfuscation techniques (excessive backticks)
- [ ] Add comprehensive dangerous pattern list
- [ ] Write security validation tests
- [ ] Document security restrictions

## New Restricted Cmdlets
- Add-Type (can load C# code)
- New-Object (can create COM objects)
- Register-ScheduledTask (persistence)
- Set-MpPreference (disable AV)
- Set-ItemProperty (registry mods)

## Acceptance Criteria
- Enhanced cmdlet restrictions in place
- Module import restrictions working
- Obfuscation detection functional
- All security checks tested
- Documentation updated

**Estimated Effort:** 6-10 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 8" \
"high,security,backend,powershell"

create_issue \
"[HIGH] Add Real-Time Script Output via WebSockets" \
"Replace polling with WebSocket streaming for real-time script execution output.

## Current State
- SocketIO initialized but unused
- ExecutionConsole polls for updates
- Output only visible after completion

## Tasks - Backend
- [ ] Implement WebSocket room joining
- [ ] Add output callback to PowerShellExecutor
- [ ] Emit output lines via SocketIO
- [ ] Emit execution status updates
- [ ] Handle client disconnections
- [ ] Test concurrent executions

## Tasks - Frontend
- [ ] Connect to WebSocket on execution start
- [ ] Join execution room
- [ ] Listen for output events
- [ ] Append output lines in real-time
- [ ] Handle disconnections
- [ ] Add reconnection logic

## Acceptance Criteria
- Output appears in real-time during execution
- Multiple users can watch same execution
- Clean disconnection handling
- No polling needed
- Works for long-running scripts

**Estimated Effort:** 8-12 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 9" \
"high,feature,backend,frontend,ux"

create_issue \
"[HIGH] Generate Interactive API Documentation with Swagger" \
"Add interactive API documentation using OpenAPI/Swagger for better developer experience.

## Tasks
- [ ] Add flasgger dependency
- [ ] Configure Swagger
- [ ] Add docstrings to all endpoints with Swagger specs
- [ ] Document request/response schemas
- [ ] Add authentication documentation
- [ ] Configure Swagger UI
- [ ] Test API from Swagger interface
- [ ] Add examples for all endpoints

## Dependencies
\`\`\`bash
flasgger==0.9.7.1
\`\`\`

## Endpoints to Document
- All auth endpoints (4)
- All script endpoints (6)
- All execution endpoints (5+)

## Acceptance Criteria
- Swagger UI accessible at /apidocs/
- All endpoints documented
- Request/response schemas defined
- Authentication documented
- Try-it-out functionality works

**Estimated Effort:** 12-16 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 10" \
"high,documentation,backend,api"

create_issue \
"[HIGH] Implement GitHub Actions CI/CD Pipeline" \
"Create automated CI/CD pipeline for testing, building, and deploying the application.

## Tasks - Testing
- [ ] Create GitHub Actions workflow
- [ ] Set up backend test job
- [ ] Set up frontend test job
- [ ] Add code coverage reporting
- [ ] Upload to codecov

## Tasks - Building
- [ ] Add Docker build job
- [ ] Test Docker Compose deployment
- [ ] Add security scanning
- [ ] Add dependency auditing

## Tasks - Deployment (optional)
- [ ] Add deployment to staging
- [ ] Add deployment to production
- [ ] Require manual approval for prod

## Workflow File
\`.github/workflows/ci.yml\`

## Acceptance Criteria
- Tests run on every push and PR
- Docker builds succeed
- Coverage reports generated
- Security scans pass
- Badge in README

**Estimated Effort:** 8-12 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 14" \
"high,infrastructure,devops,testing"

create_issue \
"[HIGH] Implement Security Headers for Production" \
"Add security headers (CSP, HSTS, etc.) to protect against common web vulnerabilities.

## Tasks
- [ ] Add Flask-Talisman dependency
- [ ] Configure Content Security Policy
- [ ] Configure HSTS
- [ ] Configure referrer policy
- [ ] Configure feature policy
- [ ] Test in development
- [ ] Enable HTTPS enforcement in production
- [ ] Document security headers

## Dependencies
\`\`\`bash
flask-talisman==1.1.0
\`\`\`

## Headers to Add
- Content-Security-Policy
- Strict-Transport-Security
- X-Content-Type-Options
- X-Frame-Options
- Referrer-Policy

## Acceptance Criteria
- Security headers present in responses
- CSP configured for Monaco editor
- HTTPS enforced in production
- Security scan passes

**Estimated Effort:** 2-4 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 15" \
"high,security,backend"

create_issue \
"[HIGH] Add JWT Refresh Token Mechanism" \
"Implement refresh token mechanism to allow users to stay logged in without compromising security.

## Current State
- JWTs expire after 24 hours
- No refresh mechanism
- Users must re-login

## Tasks
- [ ] Configure access token expiry (1 hour)
- [ ] Configure refresh token expiry (30 days)
- [ ] Create /auth/refresh endpoint
- [ ] Add refresh token validation
- [ ] Update frontend to use refresh tokens
- [ ] Store refresh token securely
- [ ] Add token rotation
- [ ] Test token refresh flow

## Acceptance Criteria
- Access tokens expire after 1 hour
- Refresh tokens last 30 days
- Frontend auto-refreshes tokens
- Old refresh tokens invalidated after use
- Logout invalidates refresh tokens

**Estimated Effort:** 4-6 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 24" \
"high,security,backend,authentication"

create_issue \
"[HIGH] Enforce Strong Password Requirements" \
"Implement password strength validation to enforce security best practices.

## Current State
- No password complexity requirements
- Any password accepted

## Tasks
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

## Password Requirements
- Minimum 12 characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 number
- At least 1 special character

## Acceptance Criteria
- Weak passwords rejected
- Clear error messages
- Requirements shown in UI
- Existing users not affected

**Estimated Effort:** 3-5 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 27" \
"high,security,backend,authentication"

create_issue \
"[HIGH] Make CORS Origins Configurable via Environment" \
"Move hardcoded CORS origins to environment variables for better deployment flexibility.

## Current Problem
\`\`\`python
CORS(app, resources={
    r\"/api/*\": {
        \"origins\": [\"http://localhost:5173\", \"http://localhost:3000\"],  # Hardcoded
\`\`\`

## Tasks
- [ ] Add ALLOWED_ORIGINS environment variable
- [ ] Parse comma-separated origins
- [ ] Update CORS configuration
- [ ] Update .env.example
- [ ] Update documentation
- [ ] Test with different origins

## Configuration
\`\`\`bash
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000,https://app.example.com
\`\`\`

## Acceptance Criteria
- CORS origins configurable via env var
- Multiple origins supported
- Default localhost origins for development
- Documentation updated

**Estimated Effort:** 1-2 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 26" \
"high,security,backend,configuration"

#####################################################
# MEDIUM PRIORITY ISSUES
#####################################################

echo -e "${BLUE}Creating Medium Priority Issues (10)...${NC}"

create_issue \
"[MEDIUM] Refactor State Management with Zustand" \
"Implement centralized state management to reduce prop drilling and improve code organization.

## Tasks
- [ ] Add zustand dependency
- [ ] Create scriptStore
- [ ] Create executionStore
- [ ] Create userStore
- [ ] Migrate ScriptList to use store
- [ ] Migrate Dashboard to use store
- [ ] Remove unnecessary prop drilling
- [ ] Add store persistence (optional)
- [ ] Document store usage

## Stores to Create
- scriptStore (scripts, loading, CRUD operations)
- executionStore (executions, real-time updates)
- userStore (current user, preferences)

## Acceptance Criteria
- Zustand integrated
- Major components using stores
- Less prop drilling
- State properly synchronized
- Documentation updated

**Estimated Effort:** 12-20 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 11" \
"medium,frontend,refactoring,architecture"

create_issue \
"[MEDIUM] Implement Caching for Frequently Accessed Data" \
"Add Redis caching to improve performance for frequently accessed data like categories and public scripts.

## Tasks
- [ ] Add Flask-Caching dependency
- [ ] Configure Redis connection
- [ ] Add caching to categories endpoint
- [ ] Add caching to public scripts list
- [ ] Implement cache invalidation on updates
- [ ] Configure cache TTL appropriately
- [ ] Add cache statistics endpoint
- [ ] Document caching strategy

## Dependencies
\`\`\`bash
Flask-Caching==2.1.0
\`\`\`

## Endpoints to Cache
- GET /api/scripts/categories (1 hour)
- GET /api/scripts/ (public only, 5 minutes)
- GET /api/execution/system/info (1 hour)

## Acceptance Criteria
- Redis caching configured
- Key endpoints cached
- Cache invalidation working
- Performance improvement measurable

**Estimated Effort:** 6-10 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 12" \
"medium,performance,backend,infrastructure"

create_issue \
"[MEDIUM] Add Version Comparison and Rollback" \
"Enhance script versioning with diff comparison and rollback capabilities.

## Current State
- Versions stored but not fully utilized
- No UI for version history
- No rollback capability

## Tasks - Backend
- [ ] Create version restore endpoint
- [ ] Create version diff endpoint
- [ ] Add version metadata
- [ ] Test rollback functionality

## Tasks - Frontend
- [ ] Create version history component
- [ ] Add diff viewer
- [ ] Add restore button
- [ ] Show version timeline
- [ ] Confirm before restore

## Acceptance Criteria
- Version history visible in UI
- Diff comparison between versions
- Rollback functionality works
- New version created on rollback

**Estimated Effort:** 12-16 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 13" \
"medium,feature,backend,frontend"

create_issue \
"[MEDIUM] Optimize Database Queries with Indexes" \
"Add database indexes on frequently queried fields to improve query performance.

## Tasks
- [ ] Analyze query patterns
- [ ] Add composite index on scripts (category, created_at)
- [ ] Add composite index on scripts (author_id, is_public)
- [ ] Add composite index on executions (user_id, started_at)
- [ ] Add composite index on executions (script_id, status)
- [ ] Create migration for indexes
- [ ] Benchmark query performance
- [ ] Document indexing strategy

## Indexes to Add
\`\`\`python
__table_args__ = (
    db.Index('idx_script_category_created', 'category', 'created_at'),
    db.Index('idx_script_author_public', 'author_id', 'is_public'),
    db.Index('idx_execution_user_started', 'user_id', 'started_at'),
    db.Index('idx_execution_script_status', 'script_id', 'status'),
)
\`\`\`

## Acceptance Criteria
- Indexes added via migration
- Query performance improved
- No breaking changes
- Documentation updated

**Estimated Effort:** 4-8 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 22" \
"medium,performance,database,backend"

create_issue \
"[MEDIUM] Add Pagination to List Endpoints" \
"Add pagination to list endpoints to prevent returning thousands of records in a single response.

## Current Problem
- No pagination on /api/scripts/
- No pagination on /api/execution/executions
- Could return thousands of records

## Tasks
- [ ] Add pagination to scripts list endpoint
- [ ] Add pagination to executions list endpoint
- [ ] Add pagination to users list endpoint
- [ ] Support page and per_page parameters
- [ ] Return pagination metadata
- [ ] Limit max per_page to 100
- [ ] Update frontend to use pagination
- [ ] Add pagination controls to UI

## Response Format
\`\`\`json
{
  \"scripts\": [...],
  \"pagination\": {
    \"page\": 1,
    \"per_page\": 20,
    \"total\": 150,
    \"pages\": 8
  }
}
\`\`\`

## Acceptance Criteria
- All list endpoints paginated
- Frontend shows pagination controls
- Performance improved for large datasets
- API documentation updated

**Estimated Effort:** 6-10 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 23" \
"medium,api,backend,performance"

create_issue \
"[MEDIUM] Implement Automated Dependency Security Scanning" \
"Add automated security scanning for dependencies in CI/CD pipeline and enable Dependabot.

## Tasks
- [ ] Create Dependabot configuration
- [ ] Enable Dependabot alerts
- [ ] Add Safety check to backend CI
- [ ] Add npm audit to frontend CI
- [ ] Configure security scan thresholds
- [ ] Set up security notifications
- [ ] Document security update process

## Files to Create
- .github/dependabot.yml
- Security scanning in CI workflow

## Acceptance Criteria
- Dependabot configured for backend and frontend
- Security scans run in CI
- Critical vulnerabilities block merge
- Notifications configured

**Estimated Effort:** 2-4 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 28" \
"medium,security,devops,infrastructure"

create_issue \
"[MEDIUM] Configure Production Database Connection Pooling" \
"Optimize SQLAlchemy connection pooling for production workloads.

## Tasks
- [ ] Configure pool_size
- [ ] Configure pool_recycle
- [ ] Enable pool_pre_ping
- [ ] Configure max_overflow
- [ ] Test under load
- [ ] Document configuration
- [ ] Add monitoring

## Configuration
\`\`\`python
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 10,
    'pool_recycle': 3600,
    'pool_pre_ping': True,
    'max_overflow': 20
}
\`\`\`

## Acceptance Criteria
- Connection pooling optimized
- No connection leaks
- Performance improved under load
- Documentation updated

**Estimated Effort:** 1-2 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 34" \
"medium,performance,database,backend"

create_issue \
"[MEDIUM] Implement Code Quality Tools and Pre-commit Hooks" \
"Add automated code formatting, linting, and type checking to maintain code quality.

## Tasks
- [ ] Add black, pylint, mypy to dev dependencies
- [ ] Configure black formatting
- [ ] Configure pylint rules
- [ ] Configure mypy type checking
- [ ] Add pre-commit hooks
- [ ] Run on all existing code
- [ ] Add to CI pipeline
- [ ] Document code quality standards

## Dependencies
\`\`\`bash
black==23.12.0
pylint==3.0.3
mypy==1.7.1
pre-commit==3.5.0
\`\`\`

## Acceptance Criteria
- Code formatting automated
- Linting configured
- Type checking enabled
- Pre-commit hooks working
- CI enforces standards

**Estimated Effort:** 4-8 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 39" \
"medium,code-quality,backend,devops"

create_issue \
"[MEDIUM] Add Type Hints Throughout Backend Codebase" \
"Add Python type hints to all functions and methods for better code clarity and IDE support.

## Tasks
- [ ] Add type hints to models.py
- [ ] Add type hints to app.py
- [ ] Add type hints to all route handlers
- [ ] Add type hints to services
- [ ] Configure mypy
- [ ] Fix type checking errors
- [ ] Document type hinting standards

## Example
\`\`\`python
from typing import List, Dict, Optional, Tuple

def execute_script(
    script_id: int,
    parameters: Optional[Dict[str, any]] = None,
    timeout: int = 300
) -> Dict[str, any]:
    ...
\`\`\`

## Acceptance Criteria
- All functions have type hints
- Mypy passes with no errors
- IDE autocomplete improved
- Documentation updated

**Estimated Effort:** 12-16 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 40" \
"medium,code-quality,backend,refactoring"

create_issue \
"[MEDIUM] Analyze and Optimize Frontend Bundle Size" \
"Analyze and optimize frontend bundle size for faster load times.

## Tasks
- [ ] Add rollup-plugin-visualizer
- [ ] Generate bundle analysis
- [ ] Identify large dependencies
- [ ] Implement code splitting
- [ ] Add lazy loading for routes
- [ ] Optimize imports (tree shaking)
- [ ] Measure improvement
- [ ] Document optimization strategies

## Dependencies
\`\`\`bash
npm install --save-dev rollup-plugin-visualizer
\`\`\`

## Techniques
- Code splitting
- Lazy loading components
- Tree shaking
- Import optimization

## Acceptance Criteria
- Bundle size reduced by 20%+
- Initial load time improved
- Lazy loading implemented
- Bundle analysis documented

**Estimated Effort:** 4-6 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 35" \
"medium,performance,frontend,optimization"

#####################################################
# LOW PRIORITY ISSUES
#####################################################

echo -e "${GREEN}Creating Low Priority / Nice-to-Have Issues (13)...${NC}"

create_issue \
"[FEATURE] Add Scheduled Script Execution (Cron-like)" \
"Allow users to schedule scripts to run at specific times or intervals.

## Tasks - Backend
- [ ] Add APScheduler dependency
- [ ] Create Schedule model
- [ ] Create schedule CRUD endpoints
- [ ] Implement job scheduling
- [ ] Handle execution on schedule
- [ ] Add schedule validation
- [ ] Test scheduled executions

## Tasks - Frontend
- [ ] Create schedule editor component
- [ ] Add cron expression builder
- [ ] Show scheduled jobs
- [ ] Add enable/disable toggle
- [ ] Show next run time

## Dependencies
\`\`\`bash
APScheduler==3.10.4
\`\`\`

## Acceptance Criteria
- Scripts can be scheduled
- Multiple schedule types supported (cron, interval)
- Schedules can be enabled/disabled
- Execution history shows scheduled runs

**Estimated Effort:** 20-30 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 16" \
"enhancement,feature,backend,frontend"

create_issue \
"[FEATURE] Add Pre-built Script Templates" \
"Provide a library of pre-built PowerShell script templates for common tasks.

## Tasks
- [ ] Create template scripts for VMware
- [ ] Create template scripts for Azure
- [ ] Create template scripts for Active Directory
- [ ] Create template scripts for utilities
- [ ] Add \"Create from Template\" UI
- [ ] Add template preview
- [ ] Document template usage
- [ ] Allow community templates (optional)

## Template Categories
- VMware (VM management, inventory, backups)
- Azure (resource management, monitoring)
- Active Directory (user management, group policy)
- Utilities (file operations, system info)

## Acceptance Criteria
- 10+ templates available
- Templates categorized
- \"Create from Template\" button works
- Templates are customizable

**Estimated Effort:** 16-24 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 17" \
"enhancement,feature,backend,frontend,content"

create_issue \
"[FEATURE] Implement Theme Toggle (Dark/Light Mode)" \
"Add user preference for light/dark theme with system preference detection.

## Tasks
- [ ] Create theme context
- [ ] Add light mode Tailwind config
- [ ] Store preference in localStorage
- [ ] Add theme toggle button
- [ ] Detect system preference
- [ ] Apply theme on load
- [ ] Update all components for light mode
- [ ] Test both themes

## Features
- Dark mode (current)
- Light mode
- System preference detection
- Toggle in header
- Persistent preference

## Acceptance Criteria
- Theme toggle works
- Preference persisted
- Both themes look good
- System preference respected

**Estimated Effort:** 8-12 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 30" \
"enhancement,frontend,ux,ui"

create_issue \
"[FEATURE] Allow Users to Star/Favorite Scripts" \
"Allow users to mark frequently used scripts as favorites for quick access.

## Tasks - Backend
- [ ] Create Favorite model
- [ ] Create favorite endpoints (add, remove, list)
- [ ] Add favorite count to scripts
- [ ] Filter scripts by favorites

## Tasks - Frontend
- [ ] Add star icon to script cards
- [ ] Add favorites filter
- [ ] Show favorite count
- [ ] Optimize UI for favorites

## Acceptance Criteria
- Users can star/unstar scripts
- Favorites filter works
- Star state persisted
- Quick access to favorite scripts

**Estimated Effort:** 8-12 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 31" \
"enhancement,feature,backend,frontend,ux"

create_issue \
"[FEATURE] Add Power User Keyboard Shortcuts" \
"Add keyboard shortcuts for common actions to improve power user experience.

## Tasks
- [ ] Add react-hotkeys-hook dependency
- [ ] Implement Ctrl/Cmd+K for quick search
- [ ] Implement Ctrl/Cmd+N for new script
- [ ] Implement Ctrl/Cmd+S for save
- [ ] Implement Ctrl/Cmd+Enter for execute
- [ ] Add Esc for close modals
- [ ] Create keyboard shortcuts help modal
- [ ] Show shortcuts on hover

## Shortcuts
- \`Ctrl/Cmd + K\`: Quick search
- \`Ctrl/Cmd + N\`: New script
- \`Ctrl/Cmd + S\`: Save script
- \`Ctrl/Cmd + Enter\`: Execute
- \`Esc\`: Close modal
- \`?\`: Show shortcuts help

## Acceptance Criteria
- All shortcuts work
- No conflicts with browser shortcuts
- Help modal shows all shortcuts
- Accessibility maintained

**Estimated Effort:** 6-10 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 32" \
"enhancement,frontend,ux,accessibility"

create_issue \
"[FEATURE] Implement Multi-tenant Architecture" \
"Add multi-tenancy support to isolate users and scripts by organization.

## Tasks - Backend
- [ ] Create Organization model
- [ ] Link users to organizations
- [ ] Add organization context to all queries
- [ ] Implement organization switching
- [ ] Add organization admin role
- [ ] Isolate data by organization
- [ ] Add organization settings

## Tasks - Frontend
- [ ] Add organization selector
- [ ] Show current organization
- [ ] Add organization management UI
- [ ] Update all queries with org context

## Acceptance Criteria
- Complete data isolation between orgs
- Organization switching works
- Admin can manage organization
- Backward compatible with existing data

**Estimated Effort:** 40-60 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 18" \
"enhancement,feature,backend,frontend,architecture"

create_issue \
"[FEATURE] Add Script Execution Approval System" \
"Require approval before executing certain high-risk scripts.

## Tasks - Backend
- [ ] Add approval_required flag to scripts
- [ ] Create ApprovalRequest model
- [ ] Create approval request endpoints
- [ ] Implement approval logic
- [ ] Add notification system
- [ ] Track approval history

## Tasks - Frontend
- [ ] Add approval required checkbox
- [ ] Create approval request UI
- [ ] Add approver list
- [ ] Show pending approvals
- [ ] Add approval/reject actions
- [ ] Show approval status

## Features
- Require approval for dangerous scripts
- Multiple approvers
- Approval notifications
- Approval history

## Acceptance Criteria
- Approval workflow functional
- Notifications sent to approvers
- History tracked
- UI intuitive

**Estimated Effort:** 24-32 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 19" \
"enhancement,feature,backend,frontend,governance"

create_issue \
"[FEATURE] Implement Full-Text Search and Advanced Filters" \
"Add full-text search and advanced filtering capabilities for scripts.

## Tasks - Backend
- [ ] Implement PostgreSQL full-text search
- [ ] Or integrate Elasticsearch
- [ ] Add search indexing
- [ ] Create advanced filter endpoint
- [ ] Support multiple filter criteria
- [ ] Add search result ranking

## Tasks - Frontend
- [ ] Create advanced search UI
- [ ] Add filter builder
- [ ] Add saved searches
- [ ] Add search suggestions
- [ ] Show search highlights

## Features
- Full-text search in script content
- Filter by multiple criteria
- Saved search filters
- Search suggestions

## Acceptance Criteria
- Fast full-text search
- Multiple filter support
- Saved searches work
- Search results ranked

**Estimated Effort:** 16-24 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 20" \
"enhancement,feature,backend,frontend"

create_issue \
"[FEATURE] Implement Fine-Grained Permission System" \
"Replace simple admin/user roles with granular permissions system.

## Tasks
- [ ] Design permission model
- [ ] Create Permission model
- [ ] Create Role model with permissions
- [ ] Implement permission checking
- [ ] Create permission management UI
- [ ] Add permission decorators
- [ ] Migrate existing users
- [ ] Document permission system

## Permissions
- script.create
- script.edit.own / script.edit.all
- script.execute.own / script.execute.all
- script.delete.own / script.delete.all
- execution.view.own / execution.view.all
- user.manage
- system.configure

## Acceptance Criteria
- Granular permissions work
- Backward compatible
- UI for permission management
- Documentation complete

**Estimated Effort:** 16-24 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 42" \
"enhancement,feature,backend,security"

create_issue \
"[FEATURE] Implement Full Audit Trail System" \
"Add comprehensive audit logging beyond script executions for compliance and security.

## Tasks
- [ ] Create AuditLog model
- [ ] Log user authentication events
- [ ] Log script CRUD operations
- [ ] Log permission changes
- [ ] Log configuration changes
- [ ] Add audit log viewer
- [ ] Add audit log export
- [ ] Add audit log retention policy

## Events to Log
- User login/logout
- Failed login attempts
- Script create/update/delete
- Script execution
- Permission changes
- User management
- Configuration changes

## Acceptance Criteria
- All important events logged
- Audit viewer functional
- Export capability
- Retention policy configurable

**Estimated Effort:** 12-16 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 43" \
"enhancement,feature,backend,security,compliance"

create_issue \
"[DOCS] Write Comprehensive Production Deployment Guide" \
"Create detailed documentation for deploying PSMachine to production environments.

## Tasks
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

## Topics
- Cloud platform deployment
- Kubernetes manifests
- SSL/TLS configuration
- Backup and restore
- Monitoring and alerting
- Scaling strategies
- Security hardening

## Acceptance Criteria
- Comprehensive deployment guide
- Multiple platform examples
- Security best practices
- Troubleshooting section

**Estimated Effort:** 12-16 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 37" \
"documentation,devops"

create_issue \
"[DOCS] Write End-User Documentation and Tutorials" \
"Create comprehensive end-user documentation with tutorials and guides.

## Tasks
- [ ] Write getting started guide
- [ ] Create script creation tutorial
- [ ] Document parameter definitions
- [ ] Create execution tutorial
- [ ] Add troubleshooting guide
- [ ] Create video tutorials (optional)
- [ ] Add screenshots
- [ ] Create FAQ section

## Topics
- Getting started
- Creating scripts
- Defining parameters
- Executing scripts
- Managing versions
- Viewing history
- Troubleshooting

## Acceptance Criteria
- Complete user manual
- Step-by-step tutorials
- Screenshots included
- Easy to follow

**Estimated Effort:** 20-30 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 38" \
"documentation,user-experience"

create_issue \
"[FEATURE] Allow Admins to Manage Script Categories" \
"Replace hardcoded script categories with database-managed categories.

## Current Problem
- Categories hardcoded in backend
- Can't add new categories without code change

## Tasks - Backend
- [ ] Create Category model
- [ ] Create category CRUD endpoints
- [ ] Migrate existing categories
- [ ] Update script model FK
- [ ] Add default categories

## Tasks - Frontend
- [ ] Create category management UI (admin)
- [ ] Update category selector
- [ ] Add category icons/colors
- [ ] Handle category changes

## Acceptance Criteria
- Categories managed in database
- Admin can CRUD categories
- Existing scripts migrated
- UI updated

**Estimated Effort:** 8-12 hours

**References:** See IMPROVEMENT_SUGGESTIONS.md Section 41" \
"enhancement,feature,backend,frontend"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}Issue Creation Complete!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "Created: ${GREEN}${CREATED}${NC} issues"
echo -e "Failed:  ${RED}${FAILED}${NC} issues"
echo ""
echo -e "View your issues at: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues"
echo ""
