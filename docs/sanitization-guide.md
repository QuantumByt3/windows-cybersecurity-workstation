# Repository Sanitization Guide

## Objective

The purpose of repository sanitization is to make technical material useful and reproducible without exposing private information about the person or workstation that created it.

A public cybersecurity repository should demonstrate the process, tools, commands, and reasoning without publishing private operational data.

---

## 1. Never Publish Secrets

Never commit:

- Passwords
- Passphrases
- SSH private keys
- API keys
- Access tokens
- Authentication cookies
- Recovery codes
- BitLocker recovery keys
- Private certificates
- VPN credentials
- Cloud credentials

Use placeholders whenever documentation requires an example.

Examples:

```text
YOUR_GITHUB_USERNAME
YOUR_EMAIL@example.com
YOUR_API_TOKEN
```

---

## 2. Sanitize User-Specific Paths

Avoid publishing personally identifying paths such as:

```text
C:\Users\ActualUsername\
```

Prefer:

```text
C:\Users\<USERNAME>\
```

For PowerShell examples, prefer portable variables such as:

```powershell
$HOME
$env:USERPROFILE
```

---

## 3. Sanitize Network Information

Private IP addresses are not normally credentials, but unnecessary workstation-specific information should still be removed from public examples.

When fictional addresses are needed, use documentation networks such as:

```text
192.0.2.0/24
198.51.100.0/24
203.0.113.0/24
```

Do not publish:

- Personal public IP addresses
- VPN credentials
- Private DNS information
- Sensitive packet captures
- Internal organizational addressing that is not intended for disclosure

---

## 4. Screenshot Workflow

Raw screenshots belong only in:

```text
assets/raw-screenshots/
```

That directory is excluded from Git.

Only reviewed and sanitized images should be placed in:

```text
assets/sanitized-images/
```

Before publishing a screenshot, inspect it for:

- Names
- Usernames
- Email addresses
- IP addresses
- Hostnames
- Device names
- Browser tabs or history
- File paths
- Authentication codes
- Recovery information
- Notifications
- Background windows containing private information

---

## 5. Command Output

Terminal output must be reviewed before publication.

Look for:

- User profile paths
- Hostnames
- MAC addresses
- IP addresses
- Serial numbers
- UUIDs
- Account identifiers
- Email addresses
- Tokens or credentials

Replace unnecessary identifying values with descriptive placeholders.

---

## 6. Git Safety Checks

Before committing:

```powershell
git status
```

Before committing staged changes:

```powershell
git diff --cached
```

Before pushing:

```powershell
git log --oneline --decorate -5
```

This project will also include an automated repository safety scanner.

---

## 7. If a Secret Is Accidentally Committed

Deleting the visible file is not enough because Git maintains history.

Immediately:

1. Revoke or rotate the exposed credential.
2. Stop additional pushes.
3. Determine whether the secret reached GitHub.
4. Remove the secret from Git history if necessary.
5. Re-scan the repository.
6. Confirm that replacement credentials are secure.

Credential rotation is more important than simply deleting the exposed file.

---

## 8. Publishing Principle

**Publish the procedure.**

**Publish the code.**

**Publish the reasoning.**

**Do not publish the credential, identity, or private operational data.**