#!/bin/bash
# Development setup script for PSMachine (local virtual environment)

set -e

echo "================================================"
echo "PSMachine - Development Setup (Virtual Env)"
echo "================================================"
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed. Please install Python 3.11+ first."
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js 16+ first."
    exit 1
fi

echo "✓ Node.js found: $(node --version)"
echo ""

# Check if PowerShell is installed
if command -v pwsh &> /dev/null; then
    echo "✓ PowerShell Core found: $(pwsh -Version)"
else
    echo "⚠ PowerShell Core not found - scripts won't execute"
    echo "  Install with: brew install powershell"
fi
echo ""

# Backend setup
echo "Setting up Backend..."
echo "--------------------"

cd backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi

# Activate virtual environment and install dependencies
echo "Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip setuptools wheel > /dev/null 2>&1
pip install -r requirements.txt

echo "✓ Python dependencies installed"

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo "Creating .env file with secure keys..."

    # Generate SECRET_KEY
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    echo "SECRET_KEY=${SECRET_KEY}" > .env

    # Generate JWT_SECRET_KEY
    JWT_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    echo "JWT_SECRET_KEY=${JWT_SECRET_KEY}" >> .env

    # Generate ENCRYPTION_KEY
    ENCRYPTION_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
    echo "ENCRYPTION_KEY=${ENCRYPTION_KEY}" >> .env

    # Add other config
    echo "FLASK_ENV=development" >> .env
    echo "FLASK_HOST=0.0.0.0" >> .env
    echo "FLASK_PORT=5001" >> .env
    echo "DATABASE_URL=sqlite:///psmachine.db" >> .env
    echo "ENABLE_SECURITY_RESTRICTIONS=true" >> .env

    echo "✓ Created .env file with secure keys"
else
    echo "✓ .env file already exists"
fi

deactivate
cd ..

# Frontend setup
echo ""
echo "Setting up Frontend..."
echo "--------------------"

cd frontend

# Install Node dependencies
echo "Installing Node.js dependencies (this may take a minute)..."
npm install > /dev/null 2>&1

echo "✓ Node.js dependencies installed"

cd ..

echo ""
echo "================================================"
echo "Development Setup Complete!"
echo "================================================"
echo ""
echo "To start the application:"
echo ""
echo "Terminal 1 (Backend):"
echo "  cd backend"
echo "  source venv/bin/activate"
echo "  python app.py"
echo ""
echo "Terminal 2 (Frontend):"
echo "  cd frontend"
echo "  npm run dev"
echo ""
echo "Then open: http://localhost:5173"
echo "Login with: admin / admin"
echo ""
echo "Database: SQLite (backend/psmachine.db)"
echo ""
