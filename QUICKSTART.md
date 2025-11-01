# Quick Start Guide

Get PSMachine running in under 5 minutes!

## Prerequisites

- Docker Desktop installed and running
- Python 3.11+ (for generating secure keys)

## Installation

### Option 1: Automated Setup (Recommended)

```bash
cd PSMachine
chmod +x setup.sh
./setup.sh
```

This script will:
- Generate secure encryption keys
- Build Docker images
- Start all containers
- Initialize the database

### Option 2: Local Development Setup

1. **Run development setup script**
   ```bash
   chmod +x setup-dev.sh
   ./setup-dev.sh
   ```

2. **Start Backend (Terminal 1)**
   ```bash
   cd backend
   source venv/bin/activate
   python app.py
   # Backend will run on http://localhost:5001
   ```

3. **Start Frontend (Terminal 2)**
   ```bash
   cd frontend
   npm run dev
   # Frontend will run on http://localhost:5173
   ```

### Option 3: Docker Setup

1. **Generate secure keys**
   ```bash
   python3 -c "import secrets; print('SECRET_KEY=' + secrets.token_urlsafe(32))" >> .env
   python3 -c "import secrets; print('JWT_SECRET_KEY=' + secrets.token_urlsafe(32))" >> .env
   python3 -c "from cryptography.fernet import Fernet; print('ENCRYPTION_KEY=' + Fernet.generate_key().decode())" >> .env
   ```

2. **Start Docker containers**
   ```bash
   docker-compose up -d
   ```

3. **Wait for services to start**
   ```bash
   docker-compose ps
   # All services should show "Up" status
   ```

## First Login

1. Open browser to:
   - **Development**: http://localhost:5173
   - **Docker**: http://localhost:3000

2. Login with default credentials:
   - Username: `admin`
   - Password: `admin`

3. **IMPORTANT**: Change your password immediately:
   - This will be added in a future update
   - For now, you can create a new admin user and disable the default one

## Creating Your First Script

1. Click **"New Script"** in the sidebar

2. Fill in the details:
   ```
   Name: Test Script
   Category: Utilities
   Description: My first PowerShell script
   ```

3. Write a simple PowerShell script:
   ```powershell
   Write-Host "Hello from PSMachine!"
   Write-Host "Current date: $(Get-Date)"
   Write-Host "PowerShell version: $($PSVersionTable.PSVersion)"
   ```

4. Click **"Save"**

5. Click **"Execute"** to run it

6. View the output in real-time!

## Example Scripts to Try

### System Information
```powershell
Write-Host "=== System Information ===" -ForegroundColor Cyan
Write-Host "Hostname: $env:COMPUTERNAME"
Write-Host "OS: $(Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption)"
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
```

### With Parameters
Create a script with parameters:

**Name**: Greeting Script
**Parameters**: Add parameter `Name` (type: string, required: true)

**Content**:
```powershell
Write-Host "Hello, $Name!" -ForegroundColor Green
Write-Host "Welcome to PSMachine"
```

When you execute, you'll be prompted for the `Name` parameter.

## Importing Existing Scripts

If you have existing PowerShell scripts:

1. Open the script file on your computer
2. Copy the entire content
3. Create a new script in PSMachine
4. Paste the content
5. Add appropriate category and tags
6. Define parameters if needed
7. Save and execute!

## Common Commands

```bash
# View logs
docker-compose logs -f

# View backend logs only
docker-compose logs -f backend

# Restart all services
docker-compose restart

# Stop all services
docker-compose down

# Stop and remove volumes (full reset)
docker-compose down -v

# Rebuild after code changes
docker-compose up -d --build
```

## Troubleshooting

### Can't access http://localhost:3000
```bash
# Check if containers are running
docker-compose ps

# Check frontend logs
docker-compose logs frontend
```

### Scripts won't execute
```bash
# Check backend logs for errors
docker-compose logs backend

# Verify PowerShell is installed in container
docker-compose exec backend pwsh -Version
```

### Database errors
```bash
# Restart database
docker-compose restart db

# Check database logs
docker-compose logs db
```

## Next Steps

- Explore the Execution History to see past runs
- Try categorizing scripts by VMware, Azure, etc.
- Add tags for better organization
- Set scripts as public to share with team members
- Check out the full README.md for advanced features

## Security Reminders

1. Change default admin password
2. Use strong passwords for new users
3. Keep your `.env` file secure
4. Don't commit `.env` to version control
5. Regularly backup your PostgreSQL database

## Getting Help

Check the full documentation in README.md for:
- Complete API documentation
- Security best practices
- Integration guides
- Architecture details
- Advanced features
