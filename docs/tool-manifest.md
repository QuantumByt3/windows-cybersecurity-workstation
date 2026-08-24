# Tool Manifest

## Overview

This document records the software versions used and validated during development of the **Windows 11 Cybersecurity Workstation** project.

The versions listed here are **tested versions**, not permanent version requirements.

Unless a compatibility requirement states otherwise, users should generally install the current stable release from the software publisher or a trusted package manager.

> Tested baseline: August 23, 2026

---

# 1. Development Environment

## PowerShell

| Property | Value |
|---|---|
| Tool | PowerShell |
| Tested Version | 7.6.5 |
| Executable | `pwsh.exe` |
| Package ID | `Microsoft.PowerShell` |
| Installation Method | Windows Package Manager (`winget`) |
| Purpose | Modern Windows shell, automation, scripting, and repository tooling |

### Install

```powershell
winget install --id Microsoft.PowerShell -e --source winget
```

### Verify

```powershell
pwsh --version
```

Expected tested result:

```text
PowerShell 7.6.5
```

---

## Python

| Property | Value |
|---|---|
| Tool | Python |
| Tested Version | 3.14.7 |
| Executable | `python.exe` |
| Package ID | `Python.Python.3.14` |
| Installation Method | Windows Package Manager (`winget`) |
| Purpose | Scripting, automation, security development, and tooling |

### Install

```powershell
winget install --id Python.Python.3.14 -e --source winget
```

### Verify

```powershell
python --version
py --version
pip --version
```

Tested result:

```text
Python 3.14.7
```

### Recommended Practice

Use Python virtual environments for individual projects:

```powershell
python -m venv .venv
```

Activate with:

```powershell
.\.venv\Scripts\Activate.ps1
```

Avoid unnecessarily installing project dependencies into the global Python environment.

---

## Git for Windows

| Property | Value |
|---|---|
| Tool | Git for Windows |
| Tested Version | 2.55.0.windows.3 |
| Executable | `git.exe` |
| Package ID | `Git.Git` |
| Installation Method | Windows Package Manager (`winget`) |
| Purpose | Source control and GitHub workflows |

### Install

```powershell
winget install --id Git.Git -e --source winget
```

### Verify

```powershell
git --version
```

Tested result:

```text
git version 2.55.0.windows.3
```

---

## Visual Studio Code

| Property | Value |
|---|---|
| Tool | Visual Studio Code |
| Tested Version | 1.134.0 |
| Executable | `Code.exe` / `code` |
| Architecture | x64 |
| Package ID | `Microsoft.VisualStudioCode` |
| Installation Method | Windows Package Manager (`winget`) |
| Purpose | Development, scripting, Markdown documentation, and Git integration |

### Install

```powershell
winget install --id Microsoft.VisualStudioCode -e --source winget
```

### Verify

```powershell
code --version
```

### Tested Extensions

```text
ms-python.debugpy
ms-python.python
ms-python.vscode-pylance
ms-python.vscode-python-envs
yzhang.markdown-all-in-one
```

The Microsoft PowerShell extension may also be installed for PowerShell development and static analysis.

---

## GitHub CLI

| Property | Value |
|---|---|
| Tool | GitHub CLI |
| Tested Version | 2.98.0 |
| Executable | `gh.exe` |
| Package ID | `GitHub.cli` |
| Installation Method | Windows Package Manager (`winget`) |
| Purpose | GitHub authentication, repository management, issues, pull requests, and workflow operations |

### Install

```powershell
winget install --id GitHub.cli -e --source winget
```

### Verify

```powershell
gh --version
```

### Authenticate

```powershell
gh auth login
```

When Git is already configured for SSH, select:

```text
GitHub.com
SSH
```

Do not publish authentication tokens generated or stored by GitHub CLI.

---

## 7-Zip

| Property | Value |
|---|---|
| Tool | 7-Zip |
| Tested Version | 26.02 |
| Architecture | x64 |
| Executable | `7z.exe` |
| Package ID | `7zip.7zip` |
| Installation Method | Windows Package Manager (`winget`) |
| Purpose | Archive extraction and file management |

### Install

```powershell
winget install --id 7zip.7zip -e --source winget
```

### Verify

```powershell
& "C:\Program Files\7-Zip\7z.exe" i
```

---

# 2. Network Analysis

## Wireshark

| Property | Value |
|---|---|
| Tool | Wireshark |
| Tested Version | 4.6.8 |
| Executables | `Wireshark.exe`, `tshark.exe` |
| Package ID | `WiresharkFoundation.Wireshark` |
| Installation Method | Windows Package Manager (`winget`) |
| Purpose | Packet capture, protocol inspection, and network analysis |

### Install

```powershell
winget install --id WiresharkFoundation.Wireshark -e --source winget
```

### Verify

```powershell
& "C:\Program Files\Wireshark\tshark.exe" --version
```

Tested result:

```text
TShark (Wireshark) 4.6.8
```

### Capture Interface Enumeration

```powershell
& "C:\Program Files\Wireshark\tshark.exe" -D
```

---

## Npcap

| Property | Value |
|---|---|
| Tool | Npcap |
| Tested Version | 1.88 |
| Driver | `npcap.sys` |
| Driver Path | `C:\Windows\System32\drivers\npcap.sys` |
| Installation Method | Official Npcap installer |
| Purpose | Windows packet-capture driver used by Wireshark |

### Verify Driver Service

```powershell
Get-Service npcap
```

Expected operational state:

```text
Running
```

### Verify Installed Driver Version

```powershell
$NpcapDriver = Get-Item "$env:SystemRoot\System32\drivers\npcap.sys"

[PSCustomObject]@{
    File           = $NpcapDriver.Name
    ProductVersion = $NpcapDriver.VersionInfo.ProductVersion
    FileVersion    = $NpcapDriver.VersionInfo.FileVersion
}
```

Tested result:

```text
npcap.sys
ProductVersion: 1.88
FileVersion:    1.88
```

### Installation Note

The Wireshark MSI installed through Windows Package Manager did not install Npcap during this workstation build.

Npcap was therefore obtained separately from the official Npcap distribution.

Do not substitute legacy WinPcap-compatible packages unless a specific application requires them.

---

# 3. Virtualization

## VMware Workstation

| Property | Value |
|---|---|
| Tool | VMware Workstation |
| Tested Version | 26.0.0 build-25388281 |
| Executable | `vmware.exe` |
| Tested Path | `C:\Program Files\VMware\VMware Workstation\vmware.exe` |
| Purpose | Virtualized cybersecurity laboratory environment |

### Verify Installed Version

```powershell
$Vmware = Get-Item "C:\Program Files\VMware\VMware Workstation\vmware.exe"

[PSCustomObject]@{
    ProductVersion = $Vmware.VersionInfo.ProductVersion
    FileVersion    = $Vmware.VersionInfo.FileVersion
}
```

The Windows workstation in this project uses VMware as the virtualization layer for a dedicated Kali Linux security VM.

The Kali environment is documented separately from the Windows host.

---

# 4. Windows Platform Utilities

## OpenSSH for Windows

| Property | Value |
|---|---|
| Tool | OpenSSH for Windows |
| Tested Version | 9.5p2 |
| Cryptographic Library | LibreSSL 3.8.2 |
| Executable | `ssh.exe` |
| Purpose | SSH authentication and GitHub SSH workflows |

### Verify

```powershell
ssh -V
```

Tested result:

```text
OpenSSH_for_Windows_9.5p2, LibreSSL 3.8.2
```

---

## Windows Package Manager

| Property | Value |
|---|---|
| Tool | Windows Package Manager |
| Command | `winget` |
| Tested Version | 1.29.290 |
| Purpose | Repeatable software installation and package discovery |

### Verify

```powershell
winget --version
```

Tested result:

```text
v1.29.290
```

---

# 5. Microsoft Sysinternals DFIR Toolkit

The following Sysinternals utilities were installed individually from Microsoft's official Sysinternals distribution.

During this workstation build, attempts to install the Sysinternals Suite and Process Explorer through `winget` resulted in:

```text
Installer hash does not match.
```

The package-manager security check was **not bypassed**.

Instead:

1. The affected package installation was stopped.
2. The utility was downloaded from Microsoft's official Sysinternals distribution.
3. The archive was extracted locally.
4. The x64 executable was identified.
5. The executable's Authenticode signature was validated before execution.

This behavior is intentional.

> A package-integrity failure should be investigated rather than bypassed merely for convenience.

---

## Process Explorer

| Property | Value |
|---|---|
| Tested Version | 17.13 |
| Executable | `procexp64.exe` |
| Purpose | Advanced process inspection, executable provenance, parent/child relationships, command lines, and signer analysis |

### Signature Verification

```powershell
Get-AuthenticodeSignature `
    "$HOME\Tools\Sysinternals\ProcessExplorer\procexp64.exe"
```

Expected:

```text
Status: Valid
Signer: Microsoft Corporation
```

---

## Process Monitor

| Property | Value |
|---|---|
| Tested Version | 4.1 |
| Executable | `Procmon64.exe` |
| Purpose | File-system, registry, process, thread, and image-load monitoring |

### Signature Verification

```powershell
Get-AuthenticodeSignature `
    "$HOME\Tools\Sysinternals\ProcessMonitor\Procmon64.exe"
```

---

## Autoruns

| Property | Value |
|---|---|
| Tested Version | 14.3 |
| Executable | `Autoruns64.exe` |
| Purpose | Startup, persistence, driver, service, scheduled-task, and logon inspection |

### Signature Verification

```powershell
Get-AuthenticodeSignature `
    "$HOME\Tools\Sysinternals\Autoruns\Autoruns64.exe"
```

Recommended inspection options include:

```text
Hide Microsoft Entries
Hide Windows Entries
Verify Code Signatures
```

Do not disable persistence entries merely because they are unfamiliar.

Investigate first.

---

## TCPView

| Property | Value |
|---|---|
| Tested Version | 4.19 |
| Executable | `tcpview64.exe` |
| Purpose | Process-to-network connection mapping |

### Signature Verification

```powershell
Get-AuthenticodeSignature `
    "$HOME\Tools\Sysinternals\TCPView\tcpview64.exe"
```

TCPView can help correlate:

```text
Process
   ↓
PID
   ↓
Local socket
   ↓
Remote destination
```

with Process Explorer and other DFIR tooling.

---

## Sigcheck

| Property | Value |
|---|---|
| Tested Version | 2.91 |
| Executable | `sigcheck64.exe` |
| Purpose | Digital-signature validation, hashes, file metadata, and executable inspection |

### Example

```powershell
& "$HOME\Tools\Sysinternals\Sigcheck\sigcheck64.exe" `
    -accepteula -a -h `
    "$env:WINDIR\System32\notepad.exe"
```

Useful output includes:

```text
Verified
Publisher
Company
File version
Machine type
SHA256
Entropy
```

A digital signature and file hash should be considered alongside other evidence rather than treated as independent proof that a file is safe.

---

## Strings

| Property | Value |
|---|---|
| Tested Version | 2.54 |
| Executable | `strings64.exe` |
| Purpose | Static extraction of readable strings from executable and binary files |

### Example

```powershell
& "$HOME\Tools\Sysinternals\Strings\strings64.exe" `
    -n 6 `
    "$env:WINDIR\System32\notepad.exe" |
    Select-String -Pattern '\.dll|https?://|Software\\|System32|Microsoft|notepad'
```

Useful extracted artifacts may include:

- DLL names
- URLs
- Domain names
- File paths
- Registry paths
- Commands
- Debug references
- Application identifiers

Strings analysis does not require executing the target binary.

---

# 6. Sysinternals Version Summary

| Tool | Tested Version | x64 Executable |
|---|---:|---|
| Process Explorer | 17.13 | `procexp64.exe` |
| Process Monitor | 4.1 | `Procmon64.exe` |
| Autoruns | 14.3 | `Autoruns64.exe` |
| TCPView | 4.19 | `tcpview64.exe` |
| Sigcheck | 2.91 | `sigcheck64.exe` |
| Strings | 2.54 | `strings64.exe` |

---

# 7. Complete Tested Version Summary

| Component | Tested Version |
|---|---:|
| PowerShell | 7.6.5 |
| Python | 3.14.7 |
| Git for Windows | 2.55.0.windows.3 |
| Visual Studio Code | 1.134.0 |
| GitHub CLI | 2.98.0 |
| 7-Zip | 26.02 |
| Wireshark / TShark | 4.6.8 |
| Npcap | 1.88 |
| VMware Workstation | 26.0.0 build-25388281 |
| OpenSSH for Windows | 9.5p2 |
| Windows Package Manager | 1.29.290 |
| Process Explorer | 17.13 |
| Process Monitor | 4.1 |
| Autoruns | 14.3 |
| TCPView | 4.19 |
| Sigcheck | 2.91 |
| Strings | 2.54 |

---

# 8. Versioning Philosophy

Cybersecurity software changes frequently.

This project therefore distinguishes between:

### Tested Version

The exact version validated during development of this workstation.

### Required Version

A version that must be used because of a documented compatibility or security requirement.

Unless a required version is specifically identified, users should generally prefer the current stable version available from the software publisher.

Always validate:

- Publisher
- Download source
- Package identifier
- Digital signature where applicable
- Package-manager integrity checks
- Release architecture (`x64`, `ARM64`, etc.)

Do not disable integrity verification simply to force an installation to succeed.

---

## Security Principle

> Trust the source, verify the artifact, and document the version.