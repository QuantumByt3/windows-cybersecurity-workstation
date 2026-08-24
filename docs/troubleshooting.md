# Troubleshooting Guide

## Overview

This document provides a structured troubleshooting reference for the **Windows 11 Cybersecurity Workstation** project.

It covers common problems involving:

- Windows security checks
- PowerShell
- WinGet
- Git
- GitHub SSH
- GitHub CLI
- Python
- Visual Studio Code
- Wireshark
- Npcap
- Sysinternals
- VMware Workstation
- Kali Linux guest integration
- Repository safety
- Git line endings

The general troubleshooting principle used throughout this project is:

```text
Observe the symptom
        ↓
Identify the affected layer
        ↓
Run a narrow diagnostic check
        ↓
Change one relevant variable
        ↓
Retest
        ↓
Document the result
```

Avoid making multiple unrelated changes at the same time.

---

# 1. Start With the Exact Error

Do not troubleshoot from memory when the terminal already provides useful evidence.

Capture:

- Command entered
- Exact error message
- Exit code when relevant
- Current directory
- Whether the shell is elevated
- Tool version
- Recent configuration changes

A single exact error is usually more useful than a broad description such as:

```text
"It doesn't work."
```

---

# 2. Check the Current Directory

Many command failures are simply path problems.

Verify:

```powershell
Get-Location
```

List files:

```powershell
Get-ChildItem
```

For the repository:

```powershell
Get-ChildItem -Force
```

If a command expects:

```text
docs/network-analysis.md
```

but the file was accidentally created under:

```text
docs/docs/network-analysis.md
```

Git will correctly report that the intended path does not exist.

Use:

```powershell
Get-ChildItem .\docs -Recurse
```

to inspect the actual hierarchy.

---

# 3. Check Whether a Command Exists

Before troubleshooting application behavior, confirm the command is available.

```powershell
Get-Command winget
```

```powershell
Get-Command git
```

```powershell
Get-Command gh
```

```powershell
Get-Command python
```

```powershell
Get-Command code
```

If PowerShell cannot locate the command, the problem may be:

- Application not installed
- PATH not refreshed
- Terminal started before installation
- Executable installed in a non-PATH location

---

# 4. Restart the Terminal After Installation

Some installers update environment variables such as PATH.

An already-open terminal may not receive the new environment.

If software was just installed:

1. Close the current terminal.
2. Open a new PowerShell 7 session.
3. Retry the command.

Do not reinstall software immediately just because the current terminal cannot see it.

---

# 5. PowerShell Version Confusion

Windows may contain both:

```text
Windows PowerShell 5.1
```

and:

```text
PowerShell 7
```

Check:

```powershell
$PSVersionTable.PSVersion
```

PowerShell 7 normally launches as:

```text
pwsh.exe
```

Windows PowerShell 5.1 normally launches as:

```text
powershell.exe
```

The distinction matters because modules, behavior, and compatibility can differ.

---

# 6. Check Whether PowerShell Is Elevated

Some workstation checks require Administrator privileges.

Determine the current privilege state:

```powershell
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()

$Principal = [Security.Principal.WindowsPrincipal]::new(
    $Identity
)

$Principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
```

Expected:

```text
True
```

for an elevated session and:

```text
False
```

for a standard session.

Use a normal session by default.

Elevate only when required.

---

# 7. Execution Policy Blocks a Script

Inspect execution policy:

```powershell
Get-ExecutionPolicy -List
```

A common workstation configuration is:

```text
LocalMachine RemoteSigned
```

Do not immediately use:

```powershell
Set-ExecutionPolicy Unrestricted
```

or bypass security controls globally.

Determine whether the script is:

- Local
- Downloaded
- Blocked
- Signed
- Trusted

For a downloaded file, inspect:

```powershell
Get-Item .\script.ps1 |
    Format-List *
```

If appropriate, review before using:

```powershell
Unblock-File .\script.ps1
```

---

# 8. PSScriptAnalyzer Reports Problems

The VS Code PowerShell extension may surface:

- Errors
- Warnings
- Style recommendations

Do not ignore parser errors.

A script that appears visually correct may still contain:

- Unbalanced braces
- Invalid parameter blocks
- Automatic-variable collisions
- Scope mistakes
- Syntax errors

Use the VS Code **Problems** panel before executing newly created scripts.

---

# 9. Automatic Variable Name Conflicts

PowerShell contains automatic variables such as:

```text
$Profile
$PID
$HOME
$Host
$Matches
```

Using these names for unrelated loop variables or custom state can cause confusing behavior.

Prefer descriptive names such as:

```powershell
$FirewallProfile
$PackageState
$CurrentIdentity
```

---

# 10. WinGet Is Missing

Check:

```powershell
winget --version
```

If unavailable, verify Microsoft App Installer is present and current.

Do not download random copies of `winget.exe`.

Use Microsoft's supported installation path.

---

# 11. WinGet Package Detection Looks Wrong

If a script claims an installed package is missing, verify WinGet manually.

Example:

```powershell
winget list --id Microsoft.PowerShell -e
```

A successful result may resemble:

```text
Name       Id                   Version Source
PowerShell Microsoft.PowerShell 7.x.x   winget
```

Do not assume a custom parser is correct merely because WinGet returned no error.

Inspect WinGet's actual output.

---

# 12. WinGet Update Detection

Check whether a specific installed package has an upgrade available:

```powershell
winget list `
    --id Microsoft.PowerShell `
    -e `
    --upgrade-available
```

If WinGet reports no matching installed package in this filtered mode, it can mean:

```text
The package is installed
but no upgrade is currently available.
```

Verify installation separately with:

```powershell
winget list --id Microsoft.PowerShell -e
```

---

# 13. Do Not Parse Human-Readable Tables Carelessly

WinGet output is formatted for human readability.

Column spacing may vary.

A brittle script may incorrectly assume:

```text
Column 1 = Name
Column 2 = ID
Column 3 = Version
```

when names contain spaces or formatting changes.

When parsing command output:

- Anchor to a known package ID
- Validate expected fields
- Test against real output
- Treat absence and failure as separate states

---

# 14. WinGet Hash Mismatch

If WinGet reports:

```text
Installer hash does not match
```

stop.

Recommended sequence:

```text
Hash mismatch
    ↓
Do not force installation
    ↓
Confirm package identity
    ↓
Check official publisher
    ↓
Obtain trusted installer if necessary
    ↓
Verify signature
```

Do not use hash-bypass options merely to make the install succeed.

---

# 15. Installed Tool Has a Newer Version Than Documentation

The repository distinguishes:

```text
Tested Version
```

from:

```text
Current Stable Version
```

A tested version documents what was actually validated.

It is not necessarily a version pin.

For WinGet packages, installation commands generally obtain the current release unless a package family is intentionally selected.

Example:

```text
Python.Python.3.14
```

tracks Python 3.14 releases but does not automatically move to Python 3.15.

---

# 16. Git Is Not a Repository

If Git reports:

```text
fatal: not a git repository
```

check:

```powershell
Get-Location
```

and:

```powershell
Get-ChildItem -Force
```

A Git repository should contain:

```text
.git
```

at its root.

Do not run `git init` repeatedly in nested folders.

---

# 17. Git Created a Nested Repository Accidentally

If `.git` exists inside a subfolder rather than the intended project root, stop before committing.

Example accidental structure:

```text
project/
└── docs/
    └── .git/
```

Determine which repository is intended before deleting or moving metadata.

Do not casually remove `.git` directories without confirming their role.

---

# 18. Git Status Shows `??`

Example:

```text
?? README.md
```

means:

```text
Untracked file
```

The file exists but has not been staged or committed.

Stage deliberately with:

```powershell
git add README.md
```

---

# 19. Git Status Shows `A`

Example:

```text
A  README.md
```

means:

```text
File is staged as newly added
```

Review:

```powershell
git diff --cached -- README.md
```

before committing.

---

# 20. Git Status Shows `M`

The position matters.

Example:

```text
 M README.md
```

means the working-tree file is modified but not staged.

Example:

```text
M  README.md
```

means the modification is staged.

Use:

```powershell
git status
```

for the full explanation.

---

# 21. `git diff` Shows Nothing for an Untracked File

Normal:

```powershell
git diff
```

does not display the contents of completely untracked files.

To inspect the file:

```powershell
Get-Content .\NEWFILE.md
```

or stage it first and inspect:

```powershell
git add NEWFILE.md
git diff --cached -- NEWFILE.md
```

---

# 22. Git Opens a Screen With `(END)`

Git may pipe long output into a pager such as `less`.

You may see:

```text
~
~
~
(END)
```

This is not a frozen terminal.

Press:

```text
q
```

to quit the pager.

Useful pager keys include:

```text
Space     next page
b         previous page
/         search
q         quit
```

---

# 23. Avoid Repeating Commands While Inside the Pager

If the screen displays:

```text
(END)
```

you are still inside the pager.

Typing another Git command will not execute normally until you exit.

Press:

```text
q
```

first.

---

# 24. LF / CRLF Warnings

On Windows, Git may display:

```text
CRLF will be replaced by LF
```

or:

```text
LF will be replaced by CRLF
```

This is usually a line-ending normalization warning, not file corruption.

This repository uses `.gitattributes` to keep repository text files consistently stored as LF.

Example policy:

```gitattributes
* text=auto eol=lf
```

with Windows-native batch files allowed to use CRLF.

---

# 25. Normalize Existing Files

After introducing `.gitattributes`:

```powershell
git add --renormalize .
```

Then review:

```powershell
git status --short
```

and:

```powershell
git diff --cached --check
```

Do not assume line-ending warnings indicate a security problem.

---

# 26. Missing Newline at End of File

Git may show:

```text
\ No newline at end of file
```

This is usually a formatting issue.

Open the file, place the cursor after the final line, press Enter once, save, and restage.

Then verify:

```powershell
git diff --cached --check
```

---

# 27. Git Reports Nothing to Commit

If:

```text
nothing to commit, working tree clean
```

appears, Git sees no uncommitted changes.

Verify:

```powershell
git status --short
```

If you expected changes:

- Confirm the file was saved
- Confirm you are in the correct repository
- Confirm the file is not ignored
- Check the actual file path

---

# 28. File Is Ignored Unexpectedly

Use:

```powershell
git check-ignore -v PATH
```

Example:

```powershell
git check-ignore -v private/
```

This reports the exact `.gitignore` rule responsible.

---

# 29. Confirm Local-Only Paths Are Ignored

Examples:

```powershell
git check-ignore -v private/
```

```powershell
git check-ignore -v assets/raw-screenshots/
```

Expected output should identify the matching `.gitignore` entries.

---

# 30. Git Branch Has No Upstream

If:

```powershell
git push
```

reports that no upstream is configured, use:

```powershell
git push -u origin main
```

Afterward, normal pushes can usually use:

```powershell
git push
```

---

# 31. Check Synchronization

Use:

```powershell
git status -sb
```

Healthy synchronized result:

```text
## main...origin/main
```

If you see:

```text
[ahead 1]
```

local commits have not yet been pushed.

If you see:

```text
[behind 1]
```

the remote contains commits missing locally.

---

# 32. Git Remote Is Wrong

Inspect:

```powershell
git remote -v
```

Expected form for GitHub SSH:

```text
origin  git@github.com:USERNAME/REPOSITORY.git
```

Do not push until the destination is verified.

---

# 33. Test a Push Without Uploading

Use:

```powershell
git push --dry-run origin main
```

This is useful before an initial publication.

A successful dry run may show:

```text
[new branch] main -> main
```

without transferring the commit.

---

# 34. SSH Passphrase Prompt Appears Every Push

This is expected when:

- The SSH private key has a passphrase
- `ssh-agent` is not storing the unlocked key

Typing the passphrase manually is a valid security choice.

Do not remove the key passphrase merely to eliminate the prompt.

---

# 35. GitHub SSH Authentication Fails

Test:

```powershell
ssh -T git@github.com
```

Possible causes include:

- Wrong SSH key
- Public key not uploaded
- SSH config points to wrong identity
- Key filename mismatch
- Host-key problem
- Network restriction

Inspect:

```powershell
Get-Content $HOME\.ssh\config
```

Do not publish private-key contents.

---

# 36. SSH Config Identity

Example:

```text
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github_windows
    IdentitiesOnly yes
```

The filename should match the actual private key.

Verify:

```powershell
Get-ChildItem $HOME\.ssh
```

Do not paste private key contents into documentation or issue reports.

---

# 37. GitHub Host Key Warning

The first connection may ask whether the GitHub host fingerprint should be trusted.

Verify the current fingerprint against GitHub's official documentation before accepting.

Do not accept unknown host keys automatically.

---

# 38. `gh auth status` Shows Authentication

Check:

```powershell
gh auth status
```

This verifies GitHub CLI authentication.

Remember:

```text
GitHub CLI authentication
```

and:

```text
Git over SSH
```

are related but separate mechanisms.

A working `gh` login does not automatically prove SSH Git operations work.

---

# 39. GitHub Repository Does Not Exist

Check:

```powershell
gh repo view USERNAME/REPOSITORY
```

If GitHub cannot resolve it, the repository may:

- Not exist
- Use another name
- Belong to another account
- Be inaccessible to the current account

Do not create another repository until the intended destination is confirmed.

---

# 40. Python Command Resolves to WindowsApps

Check:

```powershell
Get-Command python -All
```

Windows may expose an App Execution Alias under:

```text
WindowsApps
```

as well as a real installed Python interpreter.

Verify:

```powershell
python --version
```

and:

```powershell
python -c "import sys; print(sys.executable)"
```

---

# 41. Python Virtual Environment Is Not Active

Inside a project:

```powershell
.\.venv\Scripts\Activate.ps1
```

Then verify:

```powershell
python -c "import sys; print(sys.executable)"
```

The path should point into:

```text
.venv
```

---

# 42. Virtual Environment Activation Is Blocked

Check:

```powershell
Get-ExecutionPolicy -List
```

Do not blindly weaken execution policy.

A reasonable configuration may allow locally created scripts while retaining restrictions on downloaded scripts.

---

# 43. VS Code Uses the Wrong Python Interpreter

Open the Command Palette:

```text
Python: Select Interpreter
```

Choose the project's:

```text
.venv
```

Verify in the integrated terminal:

```powershell
python -c "import sys; print(sys.executable)"
```

---

# 44. VS Code PowerShell Extension Confusion

Installing the Microsoft PowerShell extension does **not** install another copy of PowerShell itself.

The extension provides:

- IntelliSense
- Debugging
- Syntax support
- PSScriptAnalyzer integration

PowerShell 7 remains the shell runtime.

---

# 45. VS Code Starts in an Unexpected Directory

Check:

```powershell
Get-Location
```

The shell may inherit the launching application's working directory.

This does not necessarily mean Windows Terminal or PowerShell is misconfigured.

Use:

```powershell
Set-Location $HOME
```

or open the intended workspace folder in VS Code.

---

# 46. Wireshark Is Installed but `tshark` Is Not Found

Use the full path:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" --version
```

Wireshark can be installed correctly even when its directory is not added to PATH.

---

# 47. Wireshark Opens but Capture Does Not Work

Check the layers independently:

```text
Wireshark
   ↓
TShark
   ↓
Npcap
   ↓
Npcap driver
   ↓
Network interface
```

Commands:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" --version
```

```powershell
Get-Service npcap
```

```powershell
Test-Path "$env:WINDIR\System32\drivers\npcap.sys"
```

```powershell
& "C:\Program Files\Wireshark\tshark.exe" -D
```

---

# 48. Npcap Is Missing

Check:

```powershell
Get-Service npcap
```

and:

```powershell
Test-Path "$env:WINDIR\System32\drivers\npcap.sys"
```

If both fail, Npcap may not be installed.

Obtain it from its official publisher and verify the installer signature before installation.

---

# 49. Npcap Service Is Stopped

Check:

```powershell
Get-Service npcap
```

Do not immediately force-start or reinstall.

Investigate:

- Recent reboot
- Installation state
- Driver errors
- Security software interaction
- Service configuration

---

# 50. No Wireshark Interfaces Appear

Run:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" -D
```

Then inspect Windows adapters:

```powershell
Get-NetAdapter
```

If VMware is installed, additional VMnet interfaces may also appear.

---

# 51. Wrong Capture Interface Selected

Do not rely permanently on interface numbers.

Run:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" -D
```

again before scripted capture testing.

Interface numbering can change.

---

# 52. VMware Traffic Is Missing From Wireshark

Understand the capture point.

Possible observation locations include:

```text
Guest interface
VMware VMnet adapter
Physical Windows adapter
```

Capturing on Wi-Fi does not guarantee visibility into every packet inside the VMware virtual network.

---

# 53. Sysinternals Tool Is Missing

Check the expected file:

```powershell
Test-Path `
    "$HOME\Tools\Sysinternals\ProcessExplorer\procexp64.exe"
```

Repeat for the appropriate tool.

Do not assume the entire Sysinternals suite was installed just because one utility exists.

---

# 54. Sysinternals Signature Validation

Check:

```powershell
Get-AuthenticodeSignature "PATH_TO_TOOL"
```

Expected:

```text
Status : Valid
```

If not valid:

1. Stop.
2. Confirm source.
3. Confirm file.
4. Re-download from Microsoft if appropriate.
5. Investigate before executing.

---

# 55. Process Explorer Shows `Not Verified`

Do not immediately assume malware.

Investigate:

- File path
- Publisher
- Related application
- Authenticode status
- Installation context

Some legitimate third-party components may display differently from Microsoft-signed binaries.

---

# 56. Process Monitor Produces Too Much Output

Apply a narrow filter.

Examples:

```text
Process Name is pwsh.exe
```

or:

```text
Path begins with <TARGET_DIRECTORY>
```

Then clear old events and repeat the controlled action.

---

# 57. Autoruns Shows Many Entries

Use filtering such as:

```text
Hide Microsoft Entries
Hide Windows Entries
Verify Code Signatures
```

Do not disable entries simply to make the list shorter.

---

# 58. TCPView Shows Unfamiliar Connections

Investigate context before closing them.

Check:

- Process
- PID
- Remote host
- Remote port
- Connection state
- Publisher
- Timing

Modern applications legitimately contact many remote services.

---

# 59. VMware VM Will Not Start

Verify:

- VMware Workstation launches
- VM files exist
- Host has sufficient memory
- VM is not already locked
- No stale VMware process is holding the VM
- Windows hypervisor compatibility is supported
- VM configuration is valid

Avoid deleting lock files until you understand why they exist.

---

# 60. VMware Guest Has No Internet

Inside Linux:

```bash
ip addr
```

then:

```bash
ip route
```

then:

```bash
ping -c 4 1.1.1.1
```

then:

```bash
getent hosts example.com
```

This distinguishes:

```text
Interface
Route
Internet path
DNS
```

rather than treating them as one problem.

---

# 61. NAT vs Bridged Confusion

NAT:

```text
Guest → VMware NAT → Host → Network
```

Bridged:

```text
Guest → Physical LAN as peer device
```

Do not change to bridged merely because NAT troubleshooting is inconvenient.

---

# 62. VMware Cursor Is Invisible

Possible areas to inspect:

- VMware Tools
- 3D acceleration
- Guest desktop environment
- VMware hardware compatibility
- Display stack

Change one relevant setting at a time.

A hardware-compatibility upgrade may resolve some display/input problems, but it should not be presented as a universal fix.

---

# 63. VMware Display Does Not Auto-Resize

Verify:

```bash
systemctl status open-vm-tools
```

and guest desktop integration.

Working VMware Tools does not guarantee that automatic display resizing is functioning.

Treat these as separate validation items.

---

# 64. VMware Tools Service

Inside Linux:

```bash
systemctl status open-vm-tools
```

If inactive, investigate:

- Installation
- Service state
- Package health
- Desktop integration package
- Guest reboot requirement

---

# 65. VMware Snapshot Does Not Replace a Backup

Snapshots are useful for rollback but remain associated with the VM disk chain.

If the host drive fails, snapshots can disappear with the VM.

Use backups for preservation.

---

# 66. Repository Safety Scanner Reports a Real Email

The scanner intentionally warns on non-placeholder email patterns.

If the match is intentional:

1. Determine whether it is safe to publish.
2. Replace with a placeholder when possible.

Preferred example:

```text
user@example.com
```

Do not weaken the scanner globally just to remove a warning.

---

# 67. Repository Scanner Flags `git@github.com`

This is SSH `user@host` syntax, not a personal email address.

A scanner may need a narrow approved exception for the exact value:

```text
git@github.com
```

Avoid broad exceptions such as:

```text
Ignore all github.com email-like strings
```

which could hide real findings.

---

# 68. Scanner Detects Its Own Patterns

A security scanner may contain strings such as:

```text
BEGIN OPENSSH PRIVATE KEY
github_pat_
AKIA
```

as detection rules.

If the scanner scans its own source code, it can create false positives.

Exclude the scanner itself from its secret-content pass, or design patterns to avoid self-matching.

---

# 69. Safety Scanner Returns Warnings but No Failures

Interpret:

```text
FAIL
```

as:

```text
Must be resolved before publication
```

and:

```text
WARN
```

as:

```text
Requires manual review
```

A warning is not automatically a security incident.

Investigate the specific finding.

---

# 70. Safety Scanner Passed

A clean result such as:

```text
WARN : 0
FAIL : 0
```

is a useful guardrail.

It is not a guarantee.

Still review:

```powershell
git status
```

```powershell
git diff
```

and:

```powershell
git diff --cached
```

before public publication.

---

# 71. Secret Was Accidentally Committed

Do not simply delete the file and commit again.

Git history may still contain the secret.

Immediately:

1. Revoke or rotate the credential.
2. Stop further pushes.
3. Determine whether it reached the remote.
4. Remove it from history if necessary.
5. Re-scan the repository.

Credential rotation comes first.

---

# 72. Secret Was Pushed to GitHub

Assume exposure.

Even if the repository was private or the commit existed briefly:

```text
Rotate or revoke the secret.
```

Then address Git history.

Do not rely on deletion alone.

---

# 73. Raw Screenshot Accidentally Added

If staged but not committed:

```powershell
git restore --staged PATH
```

Move the file to:

```text
assets/raw-screenshots/
```

and confirm it is ignored.

If already committed, evaluate whether private information entered history.

---

# 74. Packet Capture Accidentally Added

Before commit:

```powershell
git restore --staged capture.pcapng
```

Then move it outside public repository content.

If committed or pushed, treat it as potentially sensitive and review its contents.

---

# 75. `.gitignore` Does Not Remove Already-Tracked Files

Adding a path to `.gitignore` does not automatically untrack a file Git already knows about.

Check:

```powershell
git ls-files
```

If a sensitive local-only file is already tracked, stop and resolve it before publishing further.

---

# 76. Check Whether Local-Only Files Are Tracked

Example:

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

# 77. Repository Appears Empty on GitHub

Check:

```powershell
git status -sb
```

and:

```powershell
git remote -v
```

Then inspect commit history:

```powershell
git log --oneline
```

A repository can exist on GitHub without local commits having been pushed.

---

# 78. Local Commit Exists but GitHub Does Not Show It

Check:

```powershell
git status -sb
```

If:

```text
[ahead 1]
```

appears, run:

```powershell
git push
```

after reviewing the commit.

---

# 79. GitHub Shows Everything Up to Date

If:

```text
Everything up-to-date
```

appears, Git has no new commits to transfer.

This is normal when a push was already completed.

---

# 80. Avoid Unnecessary Reverification

Rechecking is useful after:

- A file changes
- A configuration changes
- A reboot affects state
- A package is updated
- A new commit is staged
- A new security-sensitive artifact is added

Repeating identical checks when nothing changed adds noise rather than confidence.

Use verification where state may actually have changed.

---

# 81. Diagnostic Command Order

A good troubleshooting pattern is:

```text
Existence
   ↓
Version
   ↓
Configuration
   ↓
Service
   ↓
Connectivity
   ↓
Permissions
   ↓
Application behavior
```

For example, Wireshark:

```text
Executable exists
   ↓
TShark version
   ↓
Npcap service
   ↓
Npcap driver
   ↓
Interfaces
   ↓
Capture
```

---

# 82. Do Not Disable Security to Diagnose First

Avoid immediately disabling:

- Microsoft Defender
- Windows Firewall
- BitLocker
- Secure Boot
- Credential Guard
- Memory Integrity
- Hypervisor protections

Instead identify which control is actually relevant.

A workaround that weakens the host may conceal the real problem.

---

# 83. Capture Evidence Before Changing Configuration

Before making a significant change, record:

```text
Current state
Error
Version
Configuration
```

Then change one variable.

This helps distinguish:

```text
What actually fixed the problem
```

from:

```text
What merely happened before it appeared fixed
```

---

# 84. Use Known-Good Files for Validation

When testing DFIR tools, inspect trusted operating-system files rather than unknown downloads.

Examples:

```text
C:\Windows\System32\notepad.exe
```

This provides a predictable baseline for:

- Signature checks
- Hashing
- Strings extraction
- Process inspection

---

# 85. Prefer Short Controlled Tests

Examples:

## Packet capture

```text
5 seconds / 20 packets
```

## Process Monitor

```text
One known PowerShell file operation
```

## Git

```text
Dry-run push
```

## Installer

```text
-WhatIf
```

Controlled tests reduce side effects and simplify interpretation.

---

# 86. Troubleshooting Documentation Standard

When documenting a resolved problem, record:

```text
Symptom
Environment
Relevant version
Diagnostic evidence
Cause
Change made
Observed result
Remaining limitations
```

Do not overstate the result.

If one symptom was resolved but another remains, document both separately.

---

# 87. When to Reinstall

Reinstallation should generally come after targeted diagnostics.

Reinstall when evidence points to:

- Missing binaries
- Corrupted files
- Broken package state
- Failed driver installation
- Incomplete upgrade
- Invalid installation path

Repeated reinstall attempts without diagnosis can destroy useful evidence.

---

# 88. When to Reboot

A reboot can be appropriate after:

- Driver installation
- Windows Update
- VMware changes
- Npcap installation
- Hypervisor changes
- System service changes

Do not reboot as a substitute for understanding the failure.

When a reboot resolves something, note that state changed.

---

# 89. Useful Environment Inventory

Capture:

```powershell
$PSVersionTable
```

```powershell
winget --version
```

```powershell
git --version
```

```powershell
gh --version
```

```powershell
python --version
```

```powershell
code --version
```

These versions can materially affect troubleshooting.

---

# 90. Useful Windows Networking Inventory

```powershell
Get-NetAdapter
```

```powershell
Get-NetIPConfiguration
```

```powershell
Get-NetTCPConnection
```

Use these before assuming a problem belongs to Wireshark or VMware.

---

# 91. Useful Security-State Inventory

```powershell
Get-MpComputerStatus
```

```powershell
Get-NetFirewallProfile
```

and, when elevated:

```powershell
Get-Tpm
```

```powershell
Confirm-SecureBootUEFI
```

Use the repository's validation scripts for consolidated reporting.

---

# 92. Useful Git Inventory

```powershell
git status
```

```powershell
git status -sb
```

```powershell
git remote -v
```

```powershell
git log --oneline --decorate -5
```

These four commands answer many common Git-state questions.

---

# 93. Useful Repository Safety Inventory

```powershell
.\scripts\Test-RepositorySafety.ps1
```

Then:

```powershell
git status
```

and, before commit:

```powershell
git diff --cached --check
```

A security scanner complements Git review rather than replacing it.

---

# 94. Keep Public Error Reports Sanitized

When requesting help, remove:

- Real usernames
- Personal email
- SSH private paths when unnecessarily identifying
- Tokens
- Recovery keys
- Internal IPs where not needed
- MAC addresses
- Private hostnames
- Organization identifiers
- Browser session data

Preserve enough technical detail for diagnosis without publishing sensitive context.

---

# 95. Do Not Redact the Error Into Uselessness

Bad sanitization:

```text
Error occurred at [REDACTED] using [REDACTED].
```

Better:

```text
ssh: Could not resolve hostname <HOSTNAME>
```

Replace identifying values while preserving technical structure.

---

# 96. Common Placeholder Conventions

Use:

```text
<USERNAME>
<HOSTNAME>
<IP_ADDRESS>
<GATEWAY>
<REPOSITORY>
<PACKAGE_ID>
<INTERFACE_NUMBER>
```

For documentation IP addresses, use RFC 5737 ranges such as:

```text
192.0.2.0/24
198.51.100.0/24
203.0.113.0/24
```

---

# 97. When the Documentation May Be Wrong

Software evolves.

If a command no longer behaves as documented:

1. Check the tool version.
2. Check official documentation.
3. Determine whether behavior changed.
4. Test the new behavior.
5. Update this repository.

Do not assume either the software or documentation is permanently correct.

---

# 98. Troubleshooting Decision Tree

```text
Does the executable exist?
       │
       ├── No → Installation/path problem
       │
       └── Yes
            ↓
Does it report a valid version?
       │
       ├── No → Binary/runtime problem
       │
       └── Yes
            ↓
Does required service/driver exist?
       │
       ├── No → Dependency problem
       │
       └── Yes
            ↓
Is configuration correct?
       │
       ├── No → Correct narrowly
       │
       └── Yes
            ↓
Are permissions sufficient?
       │
       ├── No → Elevate only if required
       │
       └── Yes
            ↓
Reproduce with controlled test
```

---

# 99. Escalation Principle

When basic troubleshooting does not explain the issue:

- Preserve logs
- Preserve exact errors
- Record versions
- Record recent changes
- Consult official documentation
- Search known issues
- Compare against a clean environment
- Avoid destructive troubleshooting

The goal is to increase evidence, not increase the number of random changes.

---

# 100. Core Troubleshooting Principles

> Read the exact error.

> Verify the affected layer before changing configuration.

> Change one variable at a time.

> Do not weaken Windows security merely to make a tool work.

> Treat package-integrity failures seriously.

> Use short, controlled validation tests.

> Preserve privacy when sharing troubleshooting output.

> Document what actually resolved the symptom.

> Do not claim a problem is fixed when only one part of it was resolved.