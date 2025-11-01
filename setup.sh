#!/bin/bash
# Quick setup script for PSMachine

set -e

echo "================================================"
echo "PowerShell Script Manager - Setup Script"
echo "================================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✓ Docker and Docker Compose found"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
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

    echo "✓ Generated secure keys in .env file"
else
    echo "✓ .env file already exists"
fi

echo ""
echo "Building and starting Docker containers..."
echo ""

# Build and start containers
docker-compose up -d --build

echo ""
echo "================================================"
echo "Setup Complete!"
echo "================================================"
echo ""
echo "Application URLs:"
echo "  Frontend: http://localhost:3000"
echo "  Backend API: http://localhost:5001"
echo ""
echo "Default Login Credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "IMPORTANT: Change the admin password immediately after first login!"
echo ""
echo "Useful Commands:"
echo "  View logs:        docker-compose logs -f"
echo "  Stop containers:  docker-compose down"
echo "  Restart:          docker-compose restart"
echo ""
echo "Check container status with: docker-compose ps"
echo ""
