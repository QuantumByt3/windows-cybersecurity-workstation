# Windows Development Environment

## Overview

This guide configures the development and source-control environment used by the **Windows 11 Cybersecurity Workstation** project.

The environment includes:

- PowerShell 7
- Git for Windows
- Python
- Visual Studio Code
- GitHub SSH authentication
- GitHub CLI
- 7-Zip
- Python virtual environments

The objective is to create a clean development platform without unnecessarily running daily tools with Administrator privileges or storing credentials directly in repositories.

Tested software versions are documented separately in:

[Tool Manifest](tool-manifest.md)

---

# 1. Prerequisites

Before building the development environment, complete the:

[Windows Security Baseline](windows-security-baseline.md)

The Windows host should have:

- Current Windows updates
- Microsoft Defender enabled
- Windows Firewall enabled
- BitLocker or Device Encryption where supported
- TPM enabled
- Secure Boot enabled where supported

Use a normal, non-Administrator terminal for routine development unless a specific installation or system task requires elevation.

---

# 2. Windows Package Manager

This project uses Windows Package Manager (`winget`) where appropriate.

Verify availability:

```powershell
winget --version
```

If the command works, Windows Package Manager is available.

Package versions change over time.

Before installation, packages may be inspected with:

```powershell
winget search <PACKAGE>
```

Use exact package IDs when possible.

---

# 3. Install PowerShell 7

Search:

```powershell
winget search Microsoft.PowerShell
```

Install the current stable release:

```powershell
winget install --id Microsoft.PowerShell -e --source winget
```

Open a new terminal and verify:

```powershell
pwsh --version
```

Tested version:

```text
PowerShell 7.6.5
```

PowerShell 7 does not replace Windows PowerShell 5.1.

Both can coexist.

---

# 4. Configure Windows Terminal

Windows Terminal can use PowerShell 7 as its default shell.

Open:

```text
Windows Terminal > Settings > Startup
```

Set:

```text
Default profile: PowerShell
```

Under the PowerShell profile, a reasonable starting directory is:

```text
%USERPROFILE%
```

Avoid configuring the normal terminal profile to always run as Administrator.

## Verify Privilege Level

Run:

```powershell
$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()

$CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new(
    $CurrentIdentity
)

$CurrentPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
```

For an ordinary development terminal, the expected result is:

```text
False
```

---

# 5. Install Git for Windows

Search:

```powershell
winget search --id Git.Git
```

Install:

```powershell
winget install --id Git.Git -e --source winget
```

Close and reopen the terminal.

Verify:

```powershell
git --version
```

Tested version:

```text
git version 2.55.0.windows.3
```

---

# 6. Configure Git Identity

Git commits contain author information.

Configure a public-facing Git identity:

```powershell
git config --global user.name "YOUR_GITHUB_USERNAME"
```

If GitHub email privacy is enabled, use the GitHub-provided `noreply` address rather than publishing a personal or organizational email address.

Example:

```powershell
git config --global user.email "YOUR_GITHUB_NOREPLY_EMAIL"
```

Configure new repositories to use `main`:

```powershell
git config --global init.defaultBranch main
```

Verify:

```powershell
git config --global --list
```

Do not place passwords or authentication tokens in Git configuration files.

---

# 7. Configure GitHub SSH Authentication

## Why SSH?

SSH allows Git operations such as:

```text
clone
pull
fetch
push
```

to authenticate using a cryptographic key instead of repeatedly entering a GitHub password.

A separate SSH key can be created for each workstation.

Do not copy the same private SSH key between every device unless there is a specific operational reason to do so.

---

## Check Existing SSH Material

Before creating a key:

```powershell
Get-ChildItem "$HOME\.ssh" -Force -ErrorAction SilentlyContinue
```

If existing keys are present, determine their purpose before creating or overwriting anything.

---

## Create the SSH Directory

```powershell
New-Item -ItemType Directory -Force "$HOME\.ssh" | Out-Null
```

---

## Generate an Ed25519 Key

Example:

```powershell
ssh-keygen `
    -t ed25519 `
    -C "Windows Cybersecurity Workstation" `
    -f "$HOME\.ssh\id_ed25519_github_windows"
```

When prompted, use a strong passphrase.

Do not publish:

```text
id_ed25519_github_windows
```

That file is the **private key**.

The corresponding:

```text
id_ed25519_github_windows.pub
```

is the public key and may be registered with GitHub.

---

## Copy the Public Key

```powershell
Get-Content "$HOME\.ssh\id_ed25519_github_windows.pub" |
    Set-Clipboard
```

In GitHub:

```text
Settings
> SSH and GPG keys
> New SSH key
```

Use:

```text
Key type: Authentication Key
```

Paste only the `.pub` key.

---

# 8. Configure OpenSSH for GitHub

Create:

```text
%USERPROFILE%\.ssh\config
```

Example configuration:

```text
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_windows
    IdentitiesOnly yes
```

This tells OpenSSH exactly which private key should be used for GitHub.

---

# 9. Verify GitHub's SSH Host Key

When connecting to GitHub for the first time, OpenSSH may display GitHub's SSH host fingerprint.

Do not blindly accept an unexpected fingerprint.

Compare it against GitHub's current official SSH fingerprint documentation before accepting the connection.

Test authentication with:

```powershell
ssh -T git@github.com
```

Successful authentication produces a message similar to:

```text
Hi YOUR_GITHUB_USERNAME! You've successfully authenticated,
but GitHub does not provide shell access.
```

GitHub intentionally does not provide interactive SSH shell access.

---

# 10. SSH Agent

The Windows OpenSSH Authentication Agent can cache an unlocked SSH key.

This is optional.

Check its current state:

```powershell
Get-Service ssh-agent |
    Select-Object Name, Status, StartType
```

A workstation can safely operate with:

```text
Status:    Stopped
StartType: Disabled
```

if the user prefers to manually enter the SSH-key passphrase when Git requires it.

Enabling `ssh-agent` is a convenience decision, not a requirement for GitHub SSH authentication.

Do not confuse:

```text
ssh-agent
```

with:

```text
sshd
```

`ssh-agent` manages client authentication keys.

`sshd` is the OpenSSH server used to accept inbound SSH connections.

This project does not require enabling an inbound SSH server on the Windows host.

---

# 11. Install Python

Search available Python releases:

```powershell
winget search Python.Python
```

The tested workstation used:

```text
Python 3.14
```

Install:

```powershell
winget install --id Python.Python.3.14 -e --source winget
```

Close and reopen PowerShell.

Verify:

```powershell
python --version
```

```powershell
py --version
```

```powershell
pip --version
```

Verify executable resolution:

```powershell
where.exe python
```

The actual Python installation should appear before the Windows App Execution Alias.

---

# 12. Use Python Virtual Environments

Avoid installing every Python package globally.

Create a project:

```powershell
New-Item -ItemType Directory -Force ".\ExampleProject" |
    Out-Null

Set-Location ".\ExampleProject"
```

Create a virtual environment:

```powershell
python -m venv .venv
```

Activate it:

```powershell
.\.venv\Scripts\Activate.ps1
```

Verify the interpreter:

```powershell
python -c "import sys; print(sys.executable)"
```

The result should point to:

```text
ExampleProject\.venv\Scripts\python.exe
```

Verify `pip`:

```powershell
python -m pip --version
```

Packages installed while the virtual environment is active remain isolated to that project.

Deactivate with:

```powershell
deactivate
```

---

# 13. PowerShell Execution Policy

Check execution policy:

```powershell
Get-ExecutionPolicy -List
```

A common Windows configuration is:

```text
LocalMachine    RemoteSigned
```

Do not globally weaken PowerShell execution policy merely to activate Python virtual environments.

When a temporary process-scoped adjustment is required, understand that:

```powershell
Set-ExecutionPolicy -Scope Process ...
```

affects only the current PowerShell process and does not permanently alter the machine policy.

---

# 14. Install Visual Studio Code

Search:

```powershell
winget search --id Microsoft.VisualStudioCode
```

Install:

```powershell
winget install `
    --id Microsoft.VisualStudioCode `
    -e `
    --source winget
```

Verify:

```powershell
code --version
```

Tested version:

```text
1.134.0
x64
```

---

# 15. Install VS Code Extensions

## Python

```powershell
code --install-extension ms-python.python
```

## Pylance

```powershell
code --install-extension ms-python.vscode-pylance
```

## Markdown

```powershell
code --install-extension yzhang.markdown-all-in-one
```

## PowerShell

The official Microsoft PowerShell extension can be installed from the VS Code Extension Marketplace.

It provides:

- PowerShell syntax support
- IntelliSense
- Script diagnostics
- Debugging
- PowerShell-integrated terminals
- PSScriptAnalyzer integration

Verify installed extensions:

```powershell
code --list-extensions
```

---

# 16. VS Code and Python Virtual Environments

Open a Python project:

```powershell
code .
```

If the project contains:

```text
.venv/
```

the Microsoft Python extension can usually detect the local Python environment.

Create a Python file:

```text
hello.py
```

Example:

```python
import sys

print("Python environment is working.")
print(sys.executable)
```

Run the file from VS Code.

The displayed interpreter path should point to:

```text
.venv\Scripts\python.exe
```

---

# 17. Python `.gitignore`

Never commit Python virtual environments.

Example:

```gitignore
.venv/
venv/

__pycache__/
*.py[cod]

.env
.env.*
```

Before committing:

```powershell
git status --ignored
```

The virtual environment should appear under:

```text
Ignored files:
    .venv/
```

and should not appear as a file Git intends to commit.

---

# 18. Install GitHub CLI

Search:

```powershell
winget search --id GitHub.cli
```

Install:

```powershell
winget install --id GitHub.cli -e --source winget
```

Verify:

```powershell
gh --version
```

Check authentication state:

```powershell
gh auth status
```

If authentication has not been configured:

```powershell
gh auth login
```

A Git-over-SSH workstation can use:

```text
GitHub.com
SSH
Login with a web browser
```

Do not publish:

- Device authorization codes
- OAuth tokens
- GitHub CLI authentication tokens

---

# 19. Git and GitHub CLI Are Different

These two workflows serve different purposes.

## Git

Typical operations:

```text
git clone
git pull
git commit
git push
```

Authentication can use the dedicated SSH key.

## GitHub CLI

Typical operations:

```text
gh repo
gh issue
gh pr
gh auth
```

GitHub CLI may use its own browser-authorized authentication token.

Using GitHub CLI does not require replacing a properly configured Git SSH workflow.

---

# 20. Install 7-Zip

Install:

```powershell
winget install --id 7zip.7zip -e --source winget
```

Verify:

```powershell
& "C:\Program Files\7-Zip\7z.exe" i
```

7-Zip is useful for:

- VM archives
- security-tool archives
- forensic data packages
- compressed coursework
- ISO-related workflows
- general file management

---

# 21. Recommended Workspace

A simple Windows-side cybersecurity workspace may use:

```text
Cybersecurity/
├── GitHub/
├── Notes/
├── Projects/
├── Reports/
├── Scripts/
└── Tools/
```

PowerShell example:

```powershell
$Folders = @(
    "$HOME\Cybersecurity",
    "$HOME\Cybersecurity\GitHub",
    "$HOME\Cybersecurity\Notes",
    "$HOME\Cybersecurity\Projects",
    "$HOME\Cybersecurity\Reports",
    "$HOME\Cybersecurity\Scripts",
    "$HOME\Cybersecurity\Tools"
)

$Folders | ForEach-Object {
    New-Item -ItemType Directory -Force $_ |
        Out-Null
}
```

This structure is only a recommendation.

Users may adapt it to their own workflow.

---

# 22. Development Environment Verification

Verify the primary commands:

```powershell
pwsh --version
python --version
git --version
code --version
gh --version
ssh -V
winget --version
```

This repository also provides:

```text
examples/powershell/get-tool-versions.ps1
```

for a broader workstation software inventory.

Run:

```powershell
.\examples\powershell\get-tool-versions.ps1
```

---

# 23. Security Practices

Do not commit:

- SSH private keys
- Passwords
- API keys
- Access tokens
- `.env` files containing secrets
- BitLocker recovery keys
- Private certificates
- GitHub authentication tokens

Do not configure:

- global Administrator-only development sessions
- disabled Defender
- disabled Windows Firewall
- unnecessarily weakened execution policies
- inbound SSH services solely for GitHub access

GitHub access requires the SSH **client**, not an SSH server.

---

# 24. Tested Environment

This guide was validated against the software versions documented in:

[Tool Manifest](tool-manifest.md)

Versions will change over time.

Unless a specific compatibility requirement exists, prefer current stable releases from trusted publishers.

---

## Design Principle

> Build a development environment that improves capability without turning convenience into unnecessary privilege or credential exposure.