# Contributing

Thank you for your interest in contributing to the **Windows 11 Cybersecurity Workstation** project.

This repository is intended to provide a security-conscious, reproducible Windows 11 workstation baseline for cybersecurity students, practitioners, homelab users, and others interested in defensive security, development, network analysis, and DFIR tooling.

Contributions that improve accuracy, security, documentation, compatibility, automation, or usability are welcome.

---

## Before Contributing

Please review:

- [README.md](README.md)
- [SECURITY.md](SECURITY.md)
- [Repository Sanitization Guide](docs/sanitization-guide.md)
- [Git and GitHub Workflow](docs/git-github-workflow.md)

Do not submit sensitive, private, proprietary, or unauthorized data.

---

## Ways to Contribute

Useful contributions may include:

- Documentation corrections
- Installation improvements
- PowerShell script improvements
- Windows compatibility fixes
- Tool-version updates
- Security-hardening recommendations
- Troubleshooting documentation
- Additional validation checks
- Accessibility improvements
- Reproducibility improvements

---

## Reporting Problems

For normal bugs or documentation problems, open a GitHub Issue.

Useful issue reports should include:

- Windows version
- Relevant tool version
- Command or script being used
- Expected behavior
- Actual behavior
- Relevant error messages
- Reproduction steps

Sanitize all output before submitting it.

Do not include:

- Passwords
- API keys
- Access tokens
- SSH private keys
- Recovery keys
- Session cookies
- Private email addresses
- Personal account identifiers
- Private network information
- Unsanitized packet captures
- Sensitive forensic evidence

For security-sensitive matters, follow [SECURITY.md](SECURITY.md).

---

## Contribution Workflow

A typical contribution workflow is:

```text
Fork repository
      ↓
Clone your fork
      ↓
Create a feature branch
      ↓
Make changes
      ↓
Review and sanitize
      ↓
Commit
      ↓
Push your branch
      ↓
Open a pull request
```

Example:

```powershell
git switch -c docs/improve-installation-guide
```

After making changes:

```powershell
git status
git diff
```

Stage only intended files:

```powershell
git add <file>
```

Review staged changes:

```powershell
git diff --cached
```

Then commit:

```powershell
git commit -m "Improve installation documentation"
```

---

## Branch Naming

Use concise branch names that describe the purpose of the work.

Examples:

```text
docs/update-tool-manifest
fix/winget-detection
feature/network-validation
security/improve-secret-scanner
```

---

## Commit Messages

Commit messages should describe the change clearly.

Good examples:

```text
Fix WinGet update detection
Document Npcap installation
Improve repository safety scanner
Add VMware troubleshooting guidance
Update tested tool versions
```

Avoid vague messages such as:

```text
update
changes
stuff
fix
```

---

## PowerShell Contributions

PowerShell scripts should:

- Use clear variable and function names
- Avoid unnecessary administrative privileges
- Avoid weakening Windows security controls
- Prefer read-only checks where practical
- Validate potentially destructive actions
- Support `-WhatIf` when appropriate
- Avoid embedding credentials or environment-specific secrets
- Include useful comments and help information
- Produce understandable output
- Be reviewed with PowerShell static analysis when practical

Scripts should not silently disable:

- Microsoft Defender
- Windows Firewall
- BitLocker
- Secure Boot
- Credential protections
- Other security controls

Any action that materially changes workstation security should be clearly documented.

---

## Security and Privacy Review

Before submitting a contribution, inspect the change for sensitive material.

At minimum, review:

```powershell
git status
git diff
git diff --cached
```

If using this repository's safety scanner:

```powershell
.\scripts\Test-RepositorySafety.ps1
```

A clean scanner result does not replace manual review.

Automated detection cannot identify every possible secret or privacy issue.

---

## Screenshots

Screenshots are welcome when they materially improve documentation.

Before submitting screenshots:

- Crop unnecessary areas
- Remove usernames
- Remove email addresses
- Remove account identifiers
- Remove tokens and credentials
- Remove recovery information
- Remove private IP or MAC addresses when unnecessary
- Remove unrelated browser tabs
- Remove personal notifications
- Remove proprietary or sensitive information

Public images should be placed under:

```text
assets/sanitized-images/
```

Do not submit raw screenshots from:

```text
assets/raw-screenshots/
```

---

## Tool Versions

The repository distinguishes between:

- **Tested version** — a version validated by the project
- **Current stable version** — the version currently offered by the publisher
- **Required version** — used only when a specific feature depends on that version

Do not unnecessarily pin software to an old tested version when the project is intended to support current stable releases.

If changing a documented tested version, include the environment in which it was validated.

---

## Pull Requests

Pull requests should:

1. Have a clear title.
2. Explain what changed.
3. Explain why the change is useful.
4. Identify relevant testing performed.
5. Mention compatibility considerations.
6. Confirm that sensitive information was reviewed.
7. Keep unrelated changes out of the same pull request where practical.

Small, focused pull requests are easier to review.

---

## Responsible Use

Contributions must support lawful, authorized, and ethical cybersecurity use.

Do not submit content intended to facilitate unauthorized access, credential theft, destructive activity, persistence on systems without permission, or evasion of legitimate security controls.

Security tooling and techniques should be documented in the context of authorized testing, defensive analysis, education, research, or legitimate administration.

---

## License

By contributing to this repository, you agree that your contribution may be distributed under the repository's [MIT License](LICENSE).