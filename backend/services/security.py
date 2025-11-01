"""
Security utilities for credential encryption and input validation.
"""
from cryptography.fernet import Fernet
import base64
import os
from typing import Optional


class CredentialEncryption:
    """Encrypt and decrypt credentials using Fernet symmetric encryption."""

    def __init__(self, secret_key: Optional[str] = None):
        """
        Initialize encryption with secret key.

        Args:
            secret_key: Base64-encoded Fernet key (32 url-safe base64-encoded bytes)
                       If not provided, uses ENCRYPTION_KEY from environment
        """
        if secret_key is None:
            secret_key = os.getenv('ENCRYPTION_KEY')
            if not secret_key:
                raise ValueError("ENCRYPTION_KEY environment variable not set")

        self.cipher = Fernet(secret_key.encode() if isinstance(secret_key, str) else secret_key)

    @staticmethod
    def generate_key() -> str:
        """Generate a new encryption key."""
        return Fernet.generate_key().decode()

    def encrypt(self, plaintext: str) -> str:
        """
        Encrypt plaintext string.

        Args:
            plaintext: String to encrypt

        Returns:
            Base64-encoded encrypted string
        """
        if not plaintext:
            return ''
        encrypted = self.cipher.encrypt(plaintext.encode())
        return encrypted.decode()

    def decrypt(self, ciphertext: str) -> str:
        """
        Decrypt ciphertext string.

        Args:
            ciphertext: Base64-encoded encrypted string

        Returns:
            Decrypted plaintext string
        """
        if not ciphertext:
            return ''
        decrypted = self.cipher.decrypt(ciphertext.encode())
        return decrypted.decode()


def validate_script_parameters(parameters: dict, parameter_definitions: list) -> tuple[bool, list]:
    """
    Validate script parameters against their definitions.

    Args:
        parameters: Dictionary of parameter values
        parameter_definitions: List of parameter definition dicts with name, type, required

    Returns:
        Tuple of (is_valid, list_of_errors)
    """
    errors = []

    # Check required parameters
    for param_def in parameter_definitions:
        param_name = param_def.get('name')
        is_required = param_def.get('required', False)
        param_type = param_def.get('type', 'string')

        if is_required and param_name not in parameters:
            errors.append(f"Required parameter '{param_name}' is missing")
            continue

        if param_name in parameters:
            value = parameters[param_name]

            # Type validation
            if param_type == 'string' and not isinstance(value, str):
                errors.append(f"Parameter '{param_name}' must be a string")
            elif param_type == 'int' and not isinstance(value, int):
                errors.append(f"Parameter '{param_name}' must be an integer")
            elif param_type == 'bool' and not isinstance(value, bool):
                errors.append(f"Parameter '{param_name}' must be a boolean")

            # Pattern validation if specified
            if 'pattern' in param_def and isinstance(value, str):
                import re
                if not re.match(param_def['pattern'], value):
                    errors.append(f"Parameter '{param_name}' does not match required pattern")

    return len(errors) == 0, errors
