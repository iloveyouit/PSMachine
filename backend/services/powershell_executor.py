"""
PowerShell execution service with security controls and output streaming.
"""
import subprocess
import threading
import re
from datetime import datetime
from typing import Dict, List, Optional, Tuple


class PowerShellExecutor:
    """Secure PowerShell script executor."""

    # Dangerous cmdlets that should be restricted
    RESTRICTED_CMDLETS = [
        'Remove-Item', 'Remove-Computer', 'Remove-ADUser',
        'Format-Volume', 'Clear-Disk', 'Initialize-Disk',
        'Remove-VM', 'Remove-VMHost', 'Remove-Datacenter',
        'Invoke-Expression', 'Invoke-Command',
        'Start-Process', 'New-Service', 'Stop-Service',
        'Disable-WindowsOptionalFeature', 'Uninstall-WindowsFeature',
        'Set-ExecutionPolicy', 'Remove-Module'
    ]

    # Dangerous patterns to detect
    DANGEROUS_PATTERNS = [
        r'rm\s+-rf',
        r'del\s+/[fs]',
        r'\|\s*Out-File\s+.*>',
        r'Invoke-WebRequest.*\|.*Invoke-Expression',
        r'iex\s*\(',
        r'&\s*\(',
    ]

    def __init__(self, enable_restrictions: bool = True):
        """
        Initialize PowerShell executor.

        Args:
            enable_restrictions: Enable security restrictions (disable only for admin users)
        """
        self.enable_restrictions = enable_restrictions
        self.pwsh_path = self._find_powershell()

    def _find_powershell(self) -> str:
        """Find PowerShell Core executable."""
        # Try PowerShell Core first (cross-platform)
        for cmd in ['pwsh', 'powershell']:
            try:
                result = subprocess.run(
                    [cmd, '-Version'],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                if result.returncode == 0:
                    return cmd
            except (subprocess.SubprocessError, FileNotFoundError):
                continue

        raise RuntimeError("PowerShell Core (pwsh) not found. Please install PowerShell 7+")

    def validate_script(self, script_content: str) -> Tuple[bool, List[str]]:
        """
        Validate script for dangerous commands.

        Args:
            script_content: The PowerShell script content

        Returns:
            Tuple of (is_valid, list_of_issues)
        """
        if not self.enable_restrictions:
            return True, []

        issues = []

        # Check for restricted cmdlets
        for cmdlet in self.RESTRICTED_CMDLETS:
            if re.search(rf'\b{re.escape(cmdlet)}\b', script_content, re.IGNORECASE):
                issues.append(f"Restricted cmdlet detected: {cmdlet}")

        # Check for dangerous patterns
        for pattern in self.DANGEROUS_PATTERNS:
            if re.search(pattern, script_content, re.IGNORECASE):
                issues.append(f"Dangerous pattern detected: {pattern}")

        return len(issues) == 0, issues

    def build_script_with_parameters(self, script_content: str, parameters: Dict) -> str:
        """
        Build PowerShell script with parameter injection.

        Args:
            script_content: Original script content
            parameters: Dictionary of parameter names and values

        Returns:
            Modified script with parameters
        """
        if not parameters:
            return script_content

        # Build parameter declarations
        param_declarations = []
        param_assignments = []

        for param_name, param_value in parameters.items():
            # Sanitize parameter name
            safe_param_name = re.sub(r'[^a-zA-Z0-9_]', '', param_name)

            # Escape parameter value for PowerShell
            if isinstance(param_value, str):
                # Escape single quotes and wrap in single quotes
                safe_value = param_value.replace("'", "''")
                param_assignments.append(f"${safe_param_name} = '{safe_value}'")
            elif isinstance(param_value, bool):
                param_assignments.append(f"${safe_param_name} = ${str(param_value)}")
            elif isinstance(param_value, (int, float)):
                param_assignments.append(f"${safe_param_name} = {param_value}")
            else:
                # Convert to JSON string for complex types
                import json
                safe_value = json.dumps(param_value).replace("'", "''")
                param_assignments.append(f"${safe_param_name} = '{safe_value}' | ConvertFrom-Json")

        # Prepend parameter assignments to script
        if param_assignments:
            parameter_block = '\n'.join(param_assignments)
            return f"# Auto-generated parameters\n{parameter_block}\n\n{script_content}"

        return script_content

    def execute(
        self,
        script_content: str,
        parameters: Optional[Dict] = None,
        timeout: int = 300,
        callback: Optional[callable] = None
    ) -> Dict:
        """
        Execute PowerShell script with security controls.

        Args:
            script_content: PowerShell script to execute
            parameters: Dictionary of parameters to pass to script
            timeout: Execution timeout in seconds
            callback: Optional callback function for real-time output (receives line string)

        Returns:
            Dictionary with execution results
        """
        start_time = datetime.utcnow()

        # Validate script
        is_valid, issues = self.validate_script(script_content)
        if not is_valid:
            return {
                'status': 'failed',
                'output': '',
                'error_output': 'Security validation failed:\n' + '\n'.join(issues),
                'exit_code': -1,
                'duration_seconds': 0
            }

        # Build script with parameters
        if parameters:
            script_content = self.build_script_with_parameters(script_content, parameters)

        # Execute PowerShell script
        try:
            process = subprocess.Popen(
                [self.pwsh_path, '-NoProfile', '-NonInteractive', '-Command', '-'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1  # Line buffered
            )

            # Write script to stdin
            process.stdin.write(script_content)
            process.stdin.close()

            # Collect output
            output_lines = []
            error_lines = []

            def read_stdout():
                for line in iter(process.stdout.readline, ''):
                    if line:
                        output_lines.append(line.rstrip())
                        if callback:
                            callback(line.rstrip())
                process.stdout.close()

            def read_stderr():
                for line in iter(process.stderr.readline, ''):
                    if line:
                        error_lines.append(line.rstrip())
                process.stderr.close()

            # Start reader threads
            stdout_thread = threading.Thread(target=read_stdout)
            stderr_thread = threading.Thread(target=read_stderr)
            stdout_thread.start()
            stderr_thread.start()

            # Wait for completion with timeout
            try:
                exit_code = process.wait(timeout=timeout)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
                exit_code = -2
                error_lines.append(f"Execution timeout after {timeout} seconds")

            # Wait for threads to finish
            stdout_thread.join(timeout=5)
            stderr_thread.join(timeout=5)

            end_time = datetime.utcnow()
            duration = (end_time - start_time).total_seconds()

            status = 'completed' if exit_code == 0 else 'failed'

            return {
                'status': status,
                'output': '\n'.join(output_lines),
                'error_output': '\n'.join(error_lines),
                'exit_code': exit_code,
                'duration_seconds': duration
            }

        except Exception as e:
            end_time = datetime.utcnow()
            duration = (end_time - start_time).total_seconds()

            return {
                'status': 'failed',
                'output': '',
                'error_output': f"Execution error: {str(e)}",
                'exit_code': -1,
                'duration_seconds': duration
            }

    def execute_async(
        self,
        script_content: str,
        parameters: Optional[Dict] = None,
        timeout: int = 300
    ) -> threading.Thread:
        """
        Execute script asynchronously in a separate thread.

        Args:
            script_content: PowerShell script to execute
            parameters: Dictionary of parameters
            timeout: Execution timeout in seconds

        Returns:
            Thread object
        """
        thread = threading.Thread(
            target=self.execute,
            args=(script_content, parameters, timeout)
        )
        thread.start()
        return thread

    def get_powershell_version(self) -> str:
        """Get PowerShell version information."""
        try:
            result = subprocess.run(
                [self.pwsh_path, '-Command', '$PSVersionTable.PSVersion.ToString()'],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0:
                return result.stdout.strip()
            return "Unknown"
        except Exception:
            return "Unknown"
