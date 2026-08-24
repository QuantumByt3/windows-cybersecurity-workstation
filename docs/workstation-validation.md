# Windows Cybersecurity Workstation Validation

## Overview

This document provides a consolidated validation procedure for the **Windows 11 Cybersecurity Workstation**.

The objective is to answer a simple question:

> Is the workstation configured, functional, secure, and ready for normal cybersecurity, development, DFIR, lab, CTF, and authorized testing workflows?

Validation is divided into the following areas:

1. Windows security baseline
2. PowerShell environment
3. Development tooling
4. Git and GitHub
5. Python environment
6. Visual Studio Code
7. Network analysis
8. Sysinternals / DFIR tooling
9. VMware Workstation
10. Kali Linux guest
11. Repository safety
12. Final readiness

This document does not replace the detailed guides in `docs/`.

It provides a high-level operational acceptance checklist.

---

# 1. Validation Philosophy

A workstation should not be considered ready merely because applications appear installed.

Validation should confirm:

```text
Installed
   ↓
Configured
   ↓
Functional
   ↓
Secure
   ↓
Documented
```

A tool that exists but cannot perform its intended function is not fully validated.

Likewise, a tool that works only after unnecessarily weakening host security does not meet this project's baseline.

---

# 2. Validation States

Use the following result categories:

```text
PASS
WARN
FAIL
INFO
```

## PASS

Expected condition is confirmed.

## WARN

The workstation remains usable, but the condition should be reviewed.

## FAIL

A required baseline control or capability is missing or malfunctioning.

## INFO

Informational state that may require manual verification.

---

# 3. Administrative Privileges

Most validation should begin in a normal PowerShell session.

Check:

```powershell
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()

$Principal = [Security.Principal.WindowsPrincipal]::new(
    $Identity
)

$Principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
```

For normal operation, the expected result is:

```text
False
```

Some checks require an elevated session.

Use Administrator privileges only when required.

---

# 4. Windows Version

Inspect:

```powershell
Get-ComputerInfo |
    Select-Object `
        WindowsProductName,
        WindowsVersion,
        OsBuildNumber
```

Expected baseline:

```text
Windows 11
```

Exact build numbers will change over time.

---

# 5. Windows Update

Open Windows Update and confirm:

- No critical update is pending
- No required restart has been ignored
- Security updates are current

This remains partly a manual validation item.

---

# 6. Microsoft Defender

Run:

```powershell
Get-MpComputerStatus |
    Select-Object `
        AntivirusEnabled,
        RealTimeProtectionEnabled,
        BehaviorMonitorEnabled,
        IoavProtectionEnabled,
        NISEnabled,
        AntispywareEnabled
```

Expected:

```text
True
```

for the enabled protection fields.

Do not disable Defender merely to make a cybersecurity tool easier to run.

---

# 7. Windows Firewall

Run:

```powershell
Get-NetFirewallProfile |
    Select-Object `
        Name,
        Enabled
```

Expected:

```text
Domain   True
Private  True
Public   True
```

All firewall profiles should remain enabled unless an explicitly documented environment requires otherwise.

---

# 8. BitLocker

Run from an elevated shell:

```powershell
manage-bde -status C:
```

Confirm:

- Protection Status is On
- Encryption is complete
- Expected encryption method is reported
- System volume is unlocked only because Windows is running normally

Do not display or record the BitLocker recovery password in public documentation.

---

# 9. TPM

From an elevated PowerShell session:

```powershell
Get-Tpm |
    Select-Object `
        TpmPresent,
        TpmReady,
        TpmEnabled,
        TpmActivated
```

Expected:

```text
True
True
True
True
```

---

# 10. Secure Boot

From an elevated session:

```powershell
Confirm-SecureBootUEFI
```

Expected:

```text
True
```

---

# 11. System Protection

Confirm Windows System Protection is enabled for the system drive.

Before major workstation changes, create a restore point when appropriate.

Example:

```powershell
Checkpoint-Computer `
    -Description "Cybersecurity Workstation Baseline" `
    -RestorePointType MODIFY_SETTINGS
```

This may require elevation and appropriate Windows configuration.

---

# 12. Automated Security Baseline

Run:

```powershell
.\scripts\Test-SecurityBaseline.ps1
```

A normal non-elevated session may report elevated checks as pending.

An elevated validation run should ideally finish with:

```text
BASELINE HEALTHY
```

without failures.

---

# 13. PowerShell 7

Check:

```powershell
$PSVersionTable.PSVersion
```

The workstation should use PowerShell 7 as the primary command-line shell.

The tested baseline used:

```text
PowerShell 7.6.5
```

A newer stable release may be appropriate.

---

# 14. Windows Terminal

Confirm:

- PowerShell 7 is available
- PowerShell 7 is the preferred/default profile
- Normal sessions do not automatically run as Administrator
- Starting directory is reasonable for the user

An unexpected current directory alone does not indicate misconfiguration.

---

# 15. WinGet

Run:

```powershell
winget --version
```

Confirm Windows Package Manager is available.

Then:

```powershell
winget source list
```

Review expected sources.

---

# 16. Development Tool Inventory

Run:

```powershell
.\examples\powershell\get-tool-versions.ps1
```

Expected core tools include:

- PowerShell
- Git
- Python
- Visual Studio Code
- GitHub CLI
- 7-Zip
- Wireshark / TShark
- Npcap
- VMware Workstation
- Sysinternals utilities

Exact versions may differ from the tested baseline.

---

# 17. Development Installer Evaluation

Preview package state:

```powershell
.\examples\powershell\install-development-tools.ps1 -WhatIf
```

Expected behavior:

```text
Installed + current
    → PASS

Installed + update available
    → UPDATE / report only

Missing
    → proposed installation
```

Nothing should actually install during `-WhatIf`.

---

# 18. Explicit Upgrade Preview

Run:

```powershell
.\examples\powershell\install-development-tools.ps1 `
    -Upgrade `
    -WhatIf
```

This validates the explicit upgrade path without changing software.

The script should not silently upgrade installed tools unless `-Upgrade` is intentionally supplied.

---

# 19. Git

Run:

```powershell
git --version
```

Then:

```powershell
git config --get user.name
```

and:

```powershell
git config --get user.email
```

Use an intended public Git identity.

Avoid unintentionally embedding personal or school email addresses in public commit metadata.

---

# 20. Default Git Branch

Run:

```powershell
git config --get init.defaultBranch
```

Recommended:

```text
main
```

---

# 21. GitHub SSH Configuration

Review:

```powershell
Get-Content $HOME\.ssh\config
```

A dedicated GitHub identity may resemble:

```text
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_windows
    IdentitiesOnly yes
```

Do not publish private-key content.

---

# 22. GitHub SSH Test

Run:

```powershell
ssh -T git@github.com
```

A successful result should indicate that GitHub authentication succeeded.

GitHub may also state that shell access is not provided.

That is expected.

---

# 23. GitHub CLI

Run:

```powershell
gh auth status
```

Confirm:

- Correct GitHub account
- Account is active
- Git operations use the intended protocol
- Authentication is valid

Do not expose tokens in screenshots or logs.

---

# 24. Repository Remote

Inside the repository:

```powershell
git remote -v
```

Confirm the fetch and push destinations are the intended GitHub repository.

---

# 25. Git Synchronization

Run:

```powershell
git status -sb
```

A synchronized repository should resemble:

```text
## main...origin/main
```

without:

```text
ahead
behind
```

indicators.

---

# 26. Git Working Tree

Run:

```powershell
git status
```

Before declaring the repository clean, expect:

```text
nothing to commit, working tree clean
```

unless deliberate work is in progress.

---

# 27. Python

Run:

```powershell
python --version
```

Then:

```powershell
python -c "import sys; print(sys.executable)"
```

Confirm the expected Python installation is being used.

---

# 28. Python Virtual Environment

Inside a Python project:

```powershell
python -m venv .venv
```

Activate:

```powershell
.\.venv\Scripts\Activate.ps1
```

Then:

```powershell
python -c "import sys; print(sys.executable)"
```

Expected path should point inside:

```text
.venv
```

---

# 29. pip

Inside the virtual environment:

```powershell
python -m pip --version
```

Prefer:

```powershell
python -m pip
```

when interpreter ambiguity is possible.

---

# 30. Visual Studio Code

Run:

```powershell
code --version
```

Confirm VS Code launches.

---

# 31. VS Code Extensions

Run:

```powershell
code --list-extensions
```

Expected baseline extensions include:

```text
ms-python.python
ms-python.vscode-pylance
yzhang.markdown-all-in-one
ms-vscode.powershell
```

Other extensions may also be installed.

---

# 32. VS Code Python Environment

Open a Python project and confirm VS Code detects the project's:

```text
.venv
```

Run a known simple script.

Example:

```python
print("Python workspace validated")
```

Successful execution validates:

- Interpreter
- Terminal
- Workspace
- VS Code integration

---

# 33. PowerShell Static Analysis

For PowerShell files, use the VS Code Problems panel.

Before publication, expect:

```text
0 errors
0 warnings
```

for project scripts where practical.

---

# 34. Wireshark

Verify:

```powershell
Get-Item "C:\Program Files\Wireshark\Wireshark.exe"
```

Then:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" --version
```

The tested baseline used:

```text
Wireshark / TShark 4.6.8
```

---

# 35. Npcap Service

Run:

```powershell
Get-Service npcap
```

Expected:

```text
Running
```

---

# 36. Npcap Driver

Run:

```powershell
Test-Path "$env:WINDIR\System32\drivers\npcap.sys"
```

Expected:

```text
True
```

Inspect version:

```powershell
(Get-Item "$env:WINDIR\System32\drivers\npcap.sys").VersionInfo |
    Select-Object `
        ProductVersion,
        FileVersion
```

---

# 37. Capture Interface Enumeration

Run:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" -D
```

Confirm expected interfaces appear.

Possible examples:

- Wi-Fi
- Ethernet
- VMware VMnet interfaces
- Loopback

---

# 38. Controlled Packet Capture

After identifying the intended interface:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" `
    -i <INTERFACE_NUMBER> `
    -a duration:5 `
    -c 20
```

Successful packet output validates the capture stack.

Do not save real traffic unless required.

---

# 39. Network Analysis Validation Script

When available, run:

```powershell
.\scripts\Test-NetworkAnalysis.ps1
```

Expected checks should include:

- Wireshark executable
- TShark
- Npcap service
- Npcap driver
- Capture interfaces

A live capture should remain optional and explicit.

---

# 40. Process Explorer

Verify:

```powershell
Test-Path `
    "$HOME\Tools\Sysinternals\ProcessExplorer\procexp64.exe"
```

Expected:

```text
True
```

---

# 41. Process Monitor

Verify:

```powershell
Test-Path `
    "$HOME\Tools\Sysinternals\ProcessMonitor\Procmon64.exe"
```

---

# 42. Autoruns

Verify:

```powershell
Test-Path `
    "$HOME\Tools\Sysinternals\Autoruns\Autoruns64.exe"
```

---

# 43. TCPView

Verify:

```powershell
Test-Path `
    "$HOME\Tools\Sysinternals\TCPView\tcpview64.exe"
```

---

# 44. Sigcheck

Verify:

```powershell
Test-Path `
    "$HOME\Tools\Sysinternals\Sigcheck\sigcheck64.exe"
```

---

# 45. Strings

Verify:

```powershell
Test-Path `
    "$HOME\Tools\Sysinternals\Strings\strings64.exe"
```

---

# 46. Sysinternals Signatures

For each executable:

```powershell
Get-AuthenticodeSignature "PATH_TO_EXECUTABLE"
```

Expected:

```text
Status : Valid
```

and expected Microsoft signer information.

---

# 47. Sysinternals Toolkit Script

When available:

```powershell
.\scripts\Test-SysinternalsToolkit.ps1
```

Expected results should confirm:

- File exists
- Version is identified
- Signature is valid
- Expected publisher is present

The script should be read-only.

---

# 48. Process Explorer Functional Validation

Launch:

```powershell
& "$HOME\Tools\Sysinternals\ProcessExplorer\procexp64.exe"
```

Confirm:

- Processes display
- Command Line can be shown
- Verified Signer can be enabled
- Process ancestry is visible

Do not force administrative execution unless necessary.

---

# 49. Process Monitor Functional Validation

Launch Process Monitor and create a narrow filter.

Example:

```text
Process Name is pwsh.exe
```

Perform one controlled file operation and confirm events such as:

```text
CreateFile
WriteFile
CloseFile
```

appear.

Stop capture afterward.

---

# 50. Autoruns Functional Validation

Launch Autoruns.

Recommended review settings:

```text
Hide Microsoft Entries
Hide Windows Entries
Verify Code Signatures
```

Confirm expected third-party entries appear.

Do not disable anything merely to validate the application.

---

# 51. TCPView Functional Validation

Launch TCPView.

Confirm active endpoints are visible.

Do not terminate connections during baseline validation.

---

# 52. Sigcheck Functional Validation

Use a known Windows binary:

```powershell
& "$HOME\Tools\Sysinternals\Sigcheck\sigcheck64.exe" `
    "C:\Windows\System32\notepad.exe"
```

Confirm signature and file metadata are returned.

---

# 53. Strings Functional Validation

Run:

```powershell
& "$HOME\Tools\Sysinternals\Strings\strings64.exe" `
    "C:\Windows\System32\notepad.exe"
```

Confirm readable strings are produced.

No unknown binary needs to be executed for this validation.

---

# 54. VMware Workstation

Verify the VMware executable exists.

Example:

```powershell
Get-Item `
    "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe"
```

Exact path may vary by release.

Inspect version metadata.

---

# 55. Windows Security With VMware

Confirm VMware functions without disabling the Windows security baseline unnecessarily.

Verify again as appropriate:

- Defender
- Firewall
- Secure Boot
- TPM
- BitLocker

Virtualization should coexist with the host's security controls.

---

# 56. VMware Virtual Adapters

Run:

```powershell
Get-NetAdapter |
    Where-Object {
        $_.InterfaceDescription -match "VMware"
    }
```

Confirm expected virtual adapters exist.

---

# 57. Kali VM Startup

Start the Kali VM.

Confirm:

- Guest boots
- Login works
- Desktop is usable
- Mouse integration works
- Terminal opens

---

# 58. Kali Guest Resources

Confirm expected guest configuration:

- RAM allocation
- CPU allocation
- Disk capacity
- NAT networking

Do not overallocate host resources.

---

# 59. Kali Network Interface

Inside Kali:

```bash
ip addr
```

Confirm the active network interface has an address.

---

# 60. Kali Route

Run:

```bash
ip route
```

Confirm a default route exists.

---

# 61. Kali External Connectivity

Test:

```bash
ping -c 4 1.1.1.1
```

A successful response demonstrates basic external IP connectivity.

---

# 62. Kali DNS

Run:

```bash
getent hosts example.com
```

Successful resolution confirms DNS functionality.

---

# 63. open-vm-tools

Inside Kali:

```bash
systemctl status open-vm-tools
```

Expected:

```text
active
```

or equivalent healthy service state.

---

# 64. VMware Display

Confirm:

- Guest display is usable
- Cursor is visible
- Window interaction works

Dynamic auto-resize should be validated separately.

Do not claim it works unless it has been tested successfully.

---

# 65. VMware 3D Acceleration

The tested workstation did not require 3D acceleration.

Confirm the current configuration matches the user's intended environment.

Do not enable unnecessary graphics features merely for completeness.

---

# 66. VMware Snapshot Baseline

Confirm meaningful restore points exist.

Recommended conceptual sequence:

```text
01 - Clean Guest Baseline
02 - Updated Stable Guest
03 - Configured Security Workstation
```

Snapshots should have meaningful names.

---

# 67. Snapshot vs Backup

Confirm users understand:

```text
Snapshot ≠ Backup
```

Important VM preservation should use a separate backup strategy.

---

# 68. Guest Credentials

Confirm:

- Guest credentials are unique
- Critical Windows or GitHub passwords are not reused
- Credentials are not documented in public files

---

# 69. Repository Safety Files

Confirm existence:

```text
.gitignore
.gitattributes
SECURITY.md
CONTRIBUTING.md
docs/sanitization-guide.md
```

---

# 70. Local-Only Directories

Confirm sensitive local storage remains outside Git tracking.

Examples:

```text
private/
assets/raw-screenshots/
```

---

# 71. Confirm Ignore Rules

Run:

```powershell
git check-ignore -v private/
```

and:

```powershell
git check-ignore -v assets/raw-screenshots/
```

Expected output should identify the matching `.gitignore` rules.

---

# 72. Repository Safety Scanner

Run:

```powershell
.\scripts\Test-RepositorySafety.ps1
```

Preferred summary:

```text
WARN : 0
FAIL : 0
Overall Result: SAFETY CHECKS PASSED
```

Warnings must be manually reviewed rather than suppressed automatically.

---

# 73. Confirm Local-Only Files Are Not Tracked

Run:

```powershell
git ls-files |
    Where-Object {
        $_ -like "private/*" -or
        $_ -like "assets/raw-screenshots/*"
    }
```

Expected:

```text
No output
```

---

# 74. Check Repository Status

Run:

```powershell
git status --short
```

Review every pending file.

Before release, do not allow unexpected files to remain unexplained.

---

# 75. Review Unstaged Changes

Run:

```powershell
git diff
```

Inspect:

- Content changes
- Paths
- Usernames
- Email addresses
- IP addresses
- Secrets
- Debug output
- Temporary text

---

# 76. Review Staged Changes

After staging:

```powershell
git diff --cached
```

This shows exactly what the next commit will contain.

---

# 77. Git Whitespace Check

Run:

```powershell
git diff --cached --check
```

Preferred result:

```text
No output
```

---

# 78. Staged File Inventory

Run:

```powershell
git diff --cached --name-status
```

Confirm every staged file is intended.

---

# 79. Staged Statistics

Run:

```powershell
git diff --cached --stat
```

This provides a high-level summary of the change.

Large or unexpected changes should be investigated before commit.

---

# 80. Verify Commit Identity

Run:

```powershell
git config --get user.name
```

and:

```powershell
git config --get user.email
```

Confirm the identity is appropriate for public Git history.

---

# 81. Verify Remote Destination

Run:

```powershell
git remote -v
```

Confirm:

- Repository owner
- Repository name
- SSH or HTTPS protocol
- Fetch destination
- Push destination

Do this before significant publication operations.

---

# 82. Dry-Run Initial Push

For a first publication:

```powershell
git push --dry-run origin main
```

This validates the outbound Git path without sending commits.

For routine subsequent pushes, this is not necessary when nothing about the remote configuration has changed.

---

# 83. Final Repository Synchronization

After push:

```powershell
git status -sb
```

Expected synchronized state:

```text
## main...origin/main
```

---

# 84. Public Repository Review

On GitHub, confirm:

- README renders correctly
- Internal links work
- LICENSE is recognized
- CONTRIBUTING is visible
- SECURITY guidance is present
- Repository description is correct
- Topics are appropriate
- No accidental sensitive files appear

---

# 85. Repository Topics

Appropriate topics may include:

```text
windows-11
cybersecurity
powershell
security-hardening
dfir
sysinternals
wireshark
python
homelab
security-tools
```

Topics should describe the repository accurately rather than maximize keyword count.

---

# 86. Documentation Cross-Links

Confirm major documents link to related material.

Expected documentation includes:

```text
README.md
SECURITY.md
CONTRIBUTING.md
docs/windows-security-baseline.md
docs/development-environment.md
docs/network-analysis.md
docs/dfir-sysinternals.md
docs/vmware-integration.md
docs/troubleshooting.md
docs/tool-manifest.md
docs/sanitization-guide.md
docs/git-github-workflow.md
```

---

# 87. Scripts

Expected reusable scripts include:

```text
scripts/Test-SecurityBaseline.ps1
scripts/Test-RepositorySafety.ps1
scripts/Test-NetworkAnalysis.ps1
scripts/Test-SysinternalsToolkit.ps1
```

Additional example scripts may appear under:

```text
examples/powershell/
```

---

# 88. Scripts Must Be Readable Before Execution

Users should be able to inspect scripts before running them.

Avoid:

- Obfuscated PowerShell
- Hidden downloads
- Silent security-control modification
- Embedded credentials
- Unexplained elevation
- Unverified remote execution

---

# 89. Scripts Should Fail Safely

A validation script should generally:

- Report missing dependencies
- Distinguish warning from failure
- Avoid destructive changes
- Avoid silently changing system configuration
- Avoid dumping secrets into terminal output

---

# 90. Security Controls Must Remain Enabled

The final workstation baseline should preserve:

```text
Microsoft Defender
Windows Firewall
BitLocker
TPM
Secure Boot
Windows Update
Least privilege
```

unless a specific, documented, authorized use case requires a deviation.

---

# 91. Tool Provenance

Confirm sensitive security tooling came from trusted publishers.

Examples:

- Microsoft Sysinternals from Microsoft
- Npcap from the official publisher
- Wireshark from Wireshark Foundation
- VMware from the official VMware distribution channel
- Kali from official Kali sources

---

# 92. Integrity Validation

Where publisher hashes or signatures are available, verify them before execution.

Examples:

```powershell
Get-AuthenticodeSignature FILE
```

and:

```powershell
Get-FileHash -Algorithm SHA256 FILE
```

Do not normalize integrity failures.

---

# 93. No Unnecessary Security Bypasses

The final workstation should not depend on undocumented use of:

```text
ignore hash
disable antivirus
disable firewall
disable Secure Boot
disable BitLocker
disable Credential Guard
execution policy Unrestricted
```

for ordinary operation.

---

# 94. No Sensitive Public Artifacts

Confirm the public repository does not contain:

- Passwords
- SSH private keys
- Access tokens
- Recovery keys
- Real credential exports
- Raw private packet captures
- Unsanitized screenshots
- Private forensic evidence
- Personal account details

---

# 95. Final Functional Readiness

The workstation is ready when the user can:

```text
Open PowerShell 7
        ↓
Use Git and GitHub
        ↓
Develop in VS Code
        ↓
Create Python virtual environments
        ↓
Capture network traffic
        ↓
Inspect Windows internals
        ↓
Run VMware
        ↓
Use Kali for authorized security work
        ↓
Document and publish sanitized work safely
```

---

# 96. Final Acceptance Checklist

## Windows Security

- [ ] Windows Update current
- [ ] Defender enabled
- [ ] Firewall enabled
- [ ] BitLocker protection on
- [ ] TPM ready
- [ ] Secure Boot enabled
- [ ] System Protection configured
- [ ] Normal shell is non-admin

## Development

- [ ] PowerShell 7 works
- [ ] WinGet works
- [ ] Git works
- [ ] Python works
- [ ] pip works
- [ ] VS Code works
- [ ] GitHub CLI works
- [ ] 7-Zip works

## GitHub

- [ ] Git identity correct
- [ ] GitHub SSH succeeds
- [ ] GitHub CLI authenticated
- [ ] Repository remote correct
- [ ] `main` synchronized

## Network Analysis

- [ ] Wireshark installed
- [ ] TShark works
- [ ] Npcap running
- [ ] Npcap driver exists
- [ ] Interfaces enumerate
- [ ] Short capture succeeds

## DFIR

- [ ] Process Explorer validated
- [ ] Process Monitor validated
- [ ] Autoruns validated
- [ ] TCPView validated
- [ ] Sigcheck validated
- [ ] Strings validated
- [ ] Signatures checked

## Virtualization

- [ ] VMware launches
- [ ] Kali starts
- [ ] NAT works
- [ ] DNS works
- [ ] open-vm-tools works
- [ ] Guest resources appropriate
- [ ] Snapshot baseline exists

## Repository Safety

- [ ] Safety scanner passes
- [ ] `.gitignore` reviewed
- [ ] Local-only directories excluded
- [ ] No unexpected Git-tracked sensitive files
- [ ] Staged diff reviewed
- [ ] Public documentation sanitized

---

# 97. Validation Frequency

Not every check needs to be repeated every day.

Revalidate when meaningful state changes occur.

Examples:

```text
Windows feature update
Security configuration change
Major tool update
VMware update
Guest kernel update
New network driver
Npcap update
New repository automation
Git remote change
New publication workflow
```

Avoid unnecessary repetitive checks when nothing relevant changed.

---

# 98. Evidence of Validation

Useful validation evidence may include:

- Script output
- Version inventories
- Sanitized screenshots
- Commit history
- Tool manifests
- Test results

Do not preserve sensitive evidence merely to prove that validation occurred.

---

# 99. Remaining Limitations

A validated workstation is not guaranteed to be:

- Free of vulnerabilities
- Appropriate for every enterprise environment
- Fully hardened against every threat
- Compatible with every future software release
- A substitute for organizational security policy

This project provides a reproducible baseline.

Users must adapt it to their own environment and risk model.

---

# 100. Final Readiness Standard

The workstation passes final validation when:

```text
Security controls are enabled
        +
Core development tooling works
        +
GitHub authentication works
        +
Network capture works
        +
DFIR tools work
        +
VMware and Kali work
        +
Repository safety controls work
        +
No unresolved critical failures remain
```

At that point, the machine can reasonably be considered a functional Windows 11 cybersecurity workstation baseline.

---

## Related Documentation

See:

- [Windows Security Baseline](windows-security-baseline.md)
- [Development Environment](development-environment.md)
- [Git and GitHub Workflow](git-github-workflow.md)
- [Network Analysis](network-analysis.md)
- [DFIR and Sysinternals](dfir-sysinternals.md)
- [VMware Workstation Integration](vmware-integration.md)
- [Troubleshooting](troubleshooting.md)
- [Tool Manifest](tool-manifest.md)
- [Repository Sanitization Guide](sanitization-guide.md)

---

## Core Principle

> A cybersecurity workstation is ready when its security controls, tooling, virtualization, networking, development workflow, and publication safeguards have all been tested as a system—not merely installed as individual applications.