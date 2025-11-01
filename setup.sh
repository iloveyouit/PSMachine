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

COMPOSE_CMD=""
if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
else
  echo "Error: Docker Compose (V2 or V1) not found. Enable Compose V2 in Docker Desktop settings or install docker-compose."
  exit 1
fi

echo "✓ Docker and Docker Compose detected (${COMPOSE_CMD})"
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

    # Generate ENCRYPTION_KEY using cryptography if available; otherwise, use a temporary venv to install it
    if python3 - <<'PY'
from importlib.util import find_spec
import sys
if find_spec('cryptography') is None:
    sys.exit(1)
PY
    then
      ENCRYPTION_KEY=$(python3 - <<'PY'
from cryptography.fernet import Fernet
print(Fernet.generate_key().decode())
PY
)
    else
      echo "cryptography not found; creating temporary virtual environment to generate ENCRYPTION_KEY..."
      python3 -m venv .psm-keys-venv >/dev/null 2>&1
      # shellcheck disable=SC1091
      source .psm-keys-venv/bin/activate
      pip install -q cryptography
      ENCRYPTION_KEY=$(python - <<'PY'
from cryptography.fernet import Fernet
print(Fernet.generate_key().decode())
PY
)
      deactivate
      rm -rf .psm-keys-venv
    fi
    echo "ENCRYPTION_KEY=${ENCRYPTION_KEY}" >> .env

    echo "✓ Generated secure keys in .env file"
else
    echo "✓ .env file already exists"
fi

echo ""
echo "Building and starting Docker containers..."
echo ""

# Build and start containers
${COMPOSE_CMD} up -d --build

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
echo "  View logs:        ${COMPOSE_CMD} logs -f"
echo "  Stop containers:  ${COMPOSE_CMD} down"
echo "  Restart:          ${COMPOSE_CMD} restart"
echo ""
echo "Check container status with: ${COMPOSE_CMD} ps"
echo ""
