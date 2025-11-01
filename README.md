# PowerShell Script Manager (PSMachine)

A Dockerized web application for storing, executing, and managing PowerShell scripts through a modern graphical interface. Perfect for system administrators who want to centralize and automate their PowerShell workflows.

## Features

### Script Management
- **Web-based Editor**: Monaco editor with PowerShell syntax highlighting
- **Categorization**: Organize scripts by category (VMware, Azure, Active Directory, etc.)
- **Tagging System**: Tag scripts for easy filtering and search
- **Version Control**: Automatic versioning of script changes
- **Public/Private Scripts**: Share scripts with team or keep them private

### Script Execution
- **One-Click Execution**: Run scripts directly from the web interface
- **Parameter Support**: Define and validate script parameters
- **Real-time Output**: View script output as it executes
- **Execution History**: Track all script runs with detailed logs
- **Security Controls**: Restrict dangerous cmdlets for non-admin users

### Security
- **JWT Authentication**: Secure token-based authentication
- **Role-Based Access**: Admin and user roles with different permissions
- **Command Whitelisting**: Prevent execution of dangerous PowerShell cmdlets
- **Encrypted Credentials**: Store credentials securely with Fernet encryption
- **Audit Trail**: Complete execution history for compliance

### User Interface
- **Modern Dashboard**: Clean, dark-themed interface
- **Search & Filter**: Quickly find scripts by name, category, or tags
- **Execution Console**: Terminal-style output display
- **Responsive Design**: Works on desktop and mobile devices

## Technology Stack

**Backend:**
- Flask (Python web framework)
- PostgreSQL (database)
- PowerShell Core 7+ (cross-platform)
- Flask-JWT-Extended (authentication)
- Flask-SocketIO (real-time communication)

**Frontend:**
- React 19 + TypeScript
- Vite (build tool)
- Tailwind CSS (styling)
- Monaco Editor (code editing)
- Lucide React (icons)

**Infrastructure:**
- Docker & Docker Compose
- Nginx (frontend web server)
- PostgreSQL 15

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- PowerShell Core 7+ (for local development)
- Node.js 20+ (for local frontend development)
- Python 3.11+ (for local backend development)

### Docker Deployment (Recommended)

1. **Clone the repository**
   ```bash
   cd PSMachine
   ```

2. **Generate secure keys**
   ```bash
   # Generate Flask secret keys
   python -c "import secrets; print('SECRET_KEY=' + secrets.token_urlsafe(32))" >> .env
   python -c "import secrets; print('JWT_SECRET_KEY=' + secrets.token_urlsafe(32))" >> .env

   # Generate encryption key
   python -c "from cryptography.fernet import Fernet; print('ENCRYPTION_KEY=' + Fernet.generate_key().decode())" >> .env
   ```

3. **Start the application**
   ```bash
   docker-compose up -d
   ```

4. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5001

5. **Login with default credentials**
   - Username: `admin`
   - Password: `admin`
   - **IMPORTANT**: Change the admin password immediately!

### Local Development Setup

#### Backend

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up environment variables for SQLite (easier for development)
cp .env.example .env
# Edit .env and change DATABASE_URL to:
# DATABASE_URL=sqlite:///psmachine.db

# Initialize database (will auto-create on first run)
python app.py

# The backend will run on http://localhost:5001
```

**Note**: For local development, SQLite is recommended. The application will auto-create the database file and default admin user on first run.

#### Frontend

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev

# The frontend will run on http://localhost:5173
```

#### Database Options

**Option 1: SQLite (Recommended for Development)**
- No setup required
- Auto-creates on first run
- Set in `.env`: `DATABASE_URL=sqlite:///psmachine.db`

**Option 2: PostgreSQL (Production)**
```bash
# Install PostgreSQL (macOS)
brew install postgresql@15
brew services start postgresql@15

# Create database and user
psql postgres
CREATE USER psmachine WITH PASSWORD 'psmachine';
CREATE DATABASE psmachine OWNER psmachine;
\q

# Set in .env: DATABASE_URL=postgresql://psmachine:psmachine@localhost:5432/psmachine
# Install psycopg2-binary: pip install psycopg2-binary
```

## Usage Guide

### Creating a Script

1. Click **"New Script"** in the sidebar
2. Fill in script details:
   - Name (required)
   - Description
   - Category
   - Tags
3. Write your PowerShell code in the editor
4. Define parameters (optional):
   - Name, type (string/int/bool), required flag
5. Click **"Save"**

### Executing a Script

1. Find your script in the Scripts list
2. Click **"Execute"**
3. Fill in parameter values (if any)
4. Click **"Execute Script"**
5. View real-time output in the console

### Managing Scripts

- **Edit**: Click the edit icon on any script card
- **Delete**: Click the trash icon (requires confirmation)
- **Search**: Use the search bar to filter by name or description
- **Filter by Category**: Select category from dropdown
- **Version History**: View all previous versions of a script

### Viewing Execution History

1. Click **"Execution History"** in sidebar
2. Select an execution from the list
3. View detailed information:
   - Status, exit code, duration
   - Input parameters
   - Full output and error logs

## Security Best Practices

### Production Deployment

1. **Change Default Credentials**: Update admin password immediately
2. **Secure Environment Variables**: Use Docker secrets or secure vault
3. **Enable HTTPS**: Configure reverse proxy with SSL certificates
4. **Database Security**: Use strong PostgreSQL password
5. **Network Isolation**: Place containers on private network
6. **Regular Updates**: Keep dependencies and base images updated

### Restricted Cmdlets

The following PowerShell cmdlets are restricted for non-admin users:
- `Remove-Item`, `Remove-Computer`, `Remove-ADUser`
- `Format-Volume`, `Clear-Disk`, `Initialize-Disk`
- `Remove-VM`, `Remove-VMHost`, `Remove-Datacenter`
- `Invoke-Expression`, `Invoke-Command`
- `Start-Process`, `New-Service`, `Stop-Service`
- And more...

Admin users bypass these restrictions (use with caution).

### Credential Storage

Credentials stored in the app are encrypted using Fernet symmetric encryption. The encryption key must be kept secure and backed up.

## Integration with Existing Scripts

You can import your existing PowerShell scripts from the repository:

```bash
# Example: Import VMware automation scripts
# 1. Navigate to the web interface
# 2. Create a new script
# 3. Copy content from your existing .ps1 files
# 4. Set category to "VMware"
# 5. Define parameters based on script params
```

Example integration with existing VMware scripts:
- `daily_poweron_enhanced.ps1` → Category: VMware, Tags: automation, power-management
- `VMware-DeepDive-Inventory.ps1` → Category: VMware, Tags: reporting, inventory

## API Documentation

### Authentication

**POST /api/auth/login**
```json
{
  "username": "admin",
  "password": "admin"
}
```

**POST /api/auth/register**
```json
{
  "username": "newuser",
  "email": "user@example.com",
  "password": "password123"
}
```

### Scripts

**GET /api/scripts/**
- Query params: `category`, `search`, `tags`

**GET /api/scripts/:id**

**POST /api/scripts/**
```json
{
  "name": "My Script",
  "description": "Script description",
  "content": "Write-Host 'Hello'",
  "category": "Utilities",
  "tags": ["test"],
  "parameters": [],
  "is_public": false
}
```

**PUT /api/scripts/:id**

**DELETE /api/scripts/:id**

### Execution

**POST /api/execution/execute/:scriptId**
```json
{
  "parameters": {
    "param1": "value1"
  },
  "timeout": 300
}
```

**GET /api/execution/executions**
- Query params: `script_id`, `status`, `limit`

**GET /api/execution/executions/:id**

All authenticated endpoints require `Authorization: Bearer <token>` header.

## Troubleshooting

### Common Issues

**React Version Conflicts**
If you see peer dependency errors during `npm install`, the package.json is already configured for React 18.2.0 which is compatible with all dependencies. If issues persist:
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

**PostgreSQL Connection Errors (Development)**
For local development, use SQLite instead:
- Set `DATABASE_URL=sqlite:///psmachine.db` in `backend/.env`
- Remove `psycopg2-binary` from requirements if installed
- Restart backend

**psycopg2-binary Installation Fails**
If you don't need PostgreSQL for development:
- Use SQLite (recommended for dev)
- The base `requirements.txt` now excludes PostgreSQL
- For PostgreSQL: `pip install -r requirements-postgres.txt`

### PowerShell Not Found
Ensure PowerShell Core is installed:
```bash
# macOS
brew install powershell

# Ubuntu/Debian
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
```

### Database Connection Errors
Check PostgreSQL is running:
```bash
docker-compose ps  # For Docker deployment
brew services list  # For macOS local development
```

### Frontend Can't Connect to Backend
Verify backend is running and accessible:
```bash
curl http://localhost:5001/api/health
```

### Script Execution Timeouts
Increase timeout in execution request or modify default in PowerShellExecutor.

## Project Structure

```
PSMachine/
├── backend/
│   ├── routes/          # API route handlers
│   │   ├── auth.py
│   │   ├── scripts.py
│   │   └── execution.py
│   ├── services/        # Business logic
│   │   ├── powershell_executor.py
│   │   └── security.py
│   ├── models.py        # Database models
│   ├── app.py           # Flask application
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── components/  # React components
│   │   ├── contexts/    # React contexts
│   │   ├── services/    # API client
│   │   ├── types/       # TypeScript types
│   │   └── App.tsx
│   ├── package.json
│   ├── Dockerfile
│   └── nginx.conf
├── docker-compose.yml
├── .env.example
└── README.md
```

## Contributing

This is a weekend project for managing PowerShell automation. Feel free to extend and customize for your environment.

## License

MIT License - feel free to use and modify for your needs.

## Future Enhancements

Potential features to add:
- [ ] Scheduled script execution (cron-like)
- [ ] Script sharing between users
- [ ] Import/export script collections
- [ ] WebSocket real-time output streaming
- [ ] Script templates library
- [ ] PowerShell module management
- [ ] Integration with Azure Automation
- [ ] Multi-tenant support
- [ ] Advanced RBAC with custom roles
- [ ] Script approval workflows

## Support

For issues or questions:
1. Check this README
2. Review backend logs: `docker-compose logs backend`
3. Review frontend logs: `docker-compose logs frontend`
4. Check PowerShell execution logs in execution history
