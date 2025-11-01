"""
Database models for PowerShell Script Manager.
"""
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import bcrypt

db = SQLAlchemy()


class User(db.Model):
    """User model for authentication and authorization."""
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False, index=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), default='user')  # 'admin' or 'user'
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)

    # Relationships
    scripts = db.relationship('Script', backref='author', lazy=True, cascade='all, delete-orphan')
    executions = db.relationship('Execution', backref='user', lazy=True, cascade='all, delete-orphan')

    def set_password(self, password):
        """Hash and set password."""
        self.password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    def check_password(self, password):
        """Verify password against hash."""
        return bcrypt.checkpw(password.encode('utf-8'), self.password_hash.encode('utf-8'))

    def to_dict(self):
        """Convert user to dictionary."""
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'role': self.role,
            'created_at': self.created_at.isoformat(),
            'is_active': self.is_active
        }


class Script(db.Model):
    """PowerShell script model."""
    __tablename__ = 'scripts'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False, index=True)
    description = db.Column(db.Text)
    content = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(50), index=True)  # VMware, Azure, AD, Utilities, etc.
    tags = db.Column(db.String(500))  # Comma-separated tags
    parameters = db.Column(db.JSON)  # JSON array of parameter definitions
    author_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_public = db.Column(db.Boolean, default=False)
    execution_count = db.Column(db.Integer, default=0)

    # Relationships
    executions = db.relationship('Execution', backref='script', lazy=True, cascade='all, delete-orphan')
    versions = db.relationship('ScriptVersion', backref='script', lazy=True, cascade='all, delete-orphan')

    def to_dict(self, include_content=True):
        """Convert script to dictionary."""
        data = {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'category': self.category,
            'tags': self.tags.split(',') if self.tags else [],
            'parameters': self.parameters or [],
            'author_id': self.author_id,
            'author_username': self.author.username if self.author else None,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
            'is_public': self.is_public,
            'execution_count': self.execution_count
        }
        if include_content:
            data['content'] = self.content
        return data


class ScriptVersion(db.Model):
    """Script version history."""
    __tablename__ = 'script_versions'

    id = db.Column(db.Integer, primary_key=True)
    script_id = db.Column(db.Integer, db.ForeignKey('scripts.id'), nullable=False)
    version_number = db.Column(db.Integer, nullable=False)
    content = db.Column(db.Text, nullable=False)
    change_description = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'))

    def to_dict(self):
        """Convert version to dictionary."""
        return {
            'id': self.id,
            'script_id': self.script_id,
            'version_number': self.version_number,
            'content': self.content,
            'change_description': self.change_description,
            'created_at': self.created_at.isoformat()
        }


class Execution(db.Model):
    """Script execution history and audit trail."""
    __tablename__ = 'executions'

    id = db.Column(db.Integer, primary_key=True)
    script_id = db.Column(db.Integer, db.ForeignKey('scripts.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    parameters = db.Column(db.JSON)  # Parameters passed to script
    status = db.Column(db.String(20), default='pending')  # pending, running, completed, failed
    output = db.Column(db.Text)  # Script output
    error_output = db.Column(db.Text)  # Error messages
    exit_code = db.Column(db.Integer)
    started_at = db.Column(db.DateTime, default=datetime.utcnow)
    completed_at = db.Column(db.DateTime)
    duration_seconds = db.Column(db.Float)

    def to_dict(self, include_output=True):
        """Convert execution to dictionary."""
        data = {
            'id': self.id,
            'script_id': self.script_id,
            'script_name': self.script.name if self.script else None,
            'user_id': self.user_id,
            'username': self.user.username if self.user else None,
            'parameters': self.parameters or {},
            'status': self.status,
            'exit_code': self.exit_code,
            'started_at': self.started_at.isoformat(),
            'completed_at': self.completed_at.isoformat() if self.completed_at else None,
            'duration_seconds': self.duration_seconds
        }
        if include_output:
            data['output'] = self.output
            data['error_output'] = self.error_output
        return data


class Credential(db.Model):
    """Encrypted credential storage for script execution."""
    __tablename__ = 'credentials'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True, index=True)
    description = db.Column(db.Text)
    username = db.Column(db.String(200))
    encrypted_password = db.Column(db.Text)  # Should be encrypted with app secret
    credential_type = db.Column(db.String(50))  # vmware, azure, ad, generic
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self, include_password=False):
        """Convert credential to dictionary."""
        data = {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'username': self.username,
            'credential_type': self.credential_type,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
        if include_password:
            data['encrypted_password'] = self.encrypted_password
        return data
