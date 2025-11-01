# Database Migrations Guide

PSMachine uses **Flask-Migrate** (Alembic) for database migrations. This provides version-controlled schema changes and rollback capability.

## Quick Start

### First Time Setup

```bash
cd backend

# Initialize migrations (only once - already done)
flask db init

# Create initial migration from current models
flask db migrate -m "Initial migration"

# Apply migrations to database
flask db upgrade
```

### Making Schema Changes

1. **Update your models** in `models.py`

2. **Generate migration**:
   ```bash
   flask db migrate -m "Description of changes"
   ```

3. **Review the generated migration** in `migrations/versions/`

4. **Apply migration**:
   ```bash
   flask db upgrade
   ```

## Common Commands

### Create a Migration
```bash
# Auto-generate migration from model changes
flask db migrate -m "Add new field to User model"

# Create empty migration for manual changes
flask db revision -m "Manual migration"
```

### Apply Migrations
```bash
# Upgrade to latest
flask db upgrade

# Upgrade to specific version
flask db upgrade <revision>

# Upgrade by number of steps
flask db upgrade +2
```

### Rollback Migrations
```bash
# Downgrade one version
flask db downgrade

# Downgrade to specific version
flask db downgrade <revision>

# Downgrade by number of steps
flask db downgrade -2
```

### Migration History
```bash
# Show current version
flask db current

# Show migration history
flask db history

# Show all available commands
flask db --help
```

## Docker Usage

The Docker container automatically runs migrations on startup:

```bash
# In Dockerfile or entrypoint
flask db upgrade
```

This ensures the database is always up-to-date when the container starts.

## Migration Files

Migrations are stored in `migrations/versions/` with filenames like:
```
abc123def456_initial_migration.py
```

Each migration file contains:
- `upgrade()`: Forward migration
- `downgrade()`: Rollback migration

## Best Practices

1. **Always review generated migrations** before applying
   - Auto-detection isn't perfect
   - May miss complex changes

2. **Test migrations on development first**
   - Apply upgrade
   - Test application
   - Test downgrade
   - Test upgrade again

3. **Never edit applied migrations**
   - Create a new migration instead
   - Migrations are a history log

4. **Commit migrations to version control**
   - Migrations are part of your codebase
   - Team members need same migrations

5. **Backup before production migrations**
   - Always have a rollback plan
   - Test the full upgrade/downgrade cycle

## Example Migration Workflow

```bash
# 1. Update model
# Added 'phone' field to User model in models.py

# 2. Generate migration
flask db migrate -m "Add phone field to User"

# Output:
# INFO  [alembic.autogenerate.compare] Detected added column 'users.phone'
# Generating /path/to/migrations/versions/abc123_add_phone_field_to_user.py

# 3. Review the migration file
cat migrations/versions/abc123_add_phone_field_to_user.py

# 4. Apply migration
flask db upgrade

# Output:
# INFO  [alembic.runtime.migration] Running upgrade def456 -> abc123, Add phone field to User

# 5. Verify
flask db current

# Output:
# abc123 (head)
```

## Troubleshooting

### Migration Conflicts
If you have merge conflicts in migrations:
```bash
# Check current heads
flask db heads

# Merge branches
flask db merge -m "Merge migrations" <rev1> <rev2>

# Apply merge
flask db upgrade
```

### Reset Migrations (Development Only)
**WARNING:** This deletes all data!
```bash
# Drop all tables
flask db downgrade base

# Or start fresh
rm -rf migrations/
flask db init
flask db migrate -m "Initial migration"
flask db upgrade
```

### Alembic Version Table Not Found
```bash
# Create alembic version table
flask db stamp head
```

## Migration from db.create_all()

If you have an existing database created with `db.create_all()`:

```bash
# 1. Create initial migration
flask db migrate -m "Initial migration"

# 2. Mark database as migrated (don't apply)
flask db stamp head

# 3. Now you can make changes normally
# ... modify models ...
flask db migrate -m "Add new feature"
flask db upgrade
```

## Environment Variables

Set `DATABASE_URL` in `.env`:

```bash
# PostgreSQL (production)
DATABASE_URL=postgresql://user:pass@localhost:5432/dbname

# SQLite (development)
DATABASE_URL=sqlite:///psmachine.db
```

## Integration with CI/CD

In your CI/CD pipeline:

```yaml
# Example GitHub Actions
- name: Run migrations
  run: |
    cd backend
    flask db upgrade

- name: Run tests
  run: |
    pytest
```

## Additional Resources

- [Flask-Migrate Documentation](https://flask-migrate.readthedocs.io/)
- [Alembic Documentation](https://alembic.sqlalchemy.org/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)

## Support

For migration issues:
1. Check migration history: `flask db history`
2. Check current version: `flask db current`
3. Review migration file in `migrations/versions/`
4. Check Alembic documentation for advanced scenarios
