#!/bin/bash
#
# Create GitHub labels for PSMachine issues
#

set -e

echo "Creating GitHub labels..."

# Priority labels
gh label create "critical" --description "Critical priority" --color "d73a4a" --force
gh label create "high" --description "High priority" --color "ff9800" --force
gh label create "medium" --description "Medium priority" --color "ffc107" --force

# Category labels
gh label create "backend" --description "Backend related" --color "0052cc" --force
gh label create "frontend" --description "Frontend related" --color "00bcd4" --force
gh label create "infrastructure" --description "Infrastructure/DevOps" --color "5319e7" --force
gh label create "database" --description "Database related" --color "006b75" --force

# Type labels
gh label create "feature" --description "New feature" --color "a2eeef" --force
gh label create "testing" --description "Testing related" --color "d4c5f9" --force
gh label create "security" --description "Security related" --color "ee0701" --force
gh label create "performance" --description "Performance improvements" --color "fbca04" --force
gh label create "documentation" --description "Documentation" --color "0075ca" --force

# Technical labels
gh label create "api" --description "API related" --color "1d76db" --force
gh label create "authentication" --description "Authentication/Authorization" --color "b60205" --force
gh label create "configuration" --description "Configuration" --color "c5def5" --force
gh label create "logging" --description "Logging/Monitoring" --color "ededed" --force
gh label create "monitoring" --description "Monitoring" --color "ededed" --force
gh label create "validation" --description "Input validation" --color "c2e0c6" --force
gh label create "error-handling" --description "Error handling" --color "f9d0c4" --force
gh label create "powershell" --description "PowerShell related" --color "0e8a16" --force

# Architecture labels
gh label create "architecture" --description "Architecture/Design" --color "5319e7" --force
gh label create "refactoring" --description "Code refactoring" --color "fbca04" --force
gh label create "code-quality" --description "Code quality" --color "bfd4f2" --force

# UX/UI labels
gh label create "ux" --description "User experience" --color "d876e3" --force
gh label create "ui" --description "User interface" --color "d876e3" --force
gh label create "accessibility" --description "Accessibility" --color "0e8a16" --force
gh label create "user-experience" --description "User experience" --color "d876e3" --force

# Other labels
gh label create "devops" --description "DevOps/CI/CD" --color "5319e7" --force
gh label create "governance" --description "Governance/Compliance" --color "0052cc" --force
gh label create "compliance" --description "Compliance" --color "0052cc" --force
gh label create "content" --description "Content management" --color "c5def5" --force
gh label create "optimization" --description "Optimization" --color "fbca04" --force

echo ""
echo "✓ All labels created successfully!"
