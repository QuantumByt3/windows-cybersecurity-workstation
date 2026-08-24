# Security Policy

## Purpose

This repository documents the construction and validation of a Windows 11 cybersecurity workstation.

Because cybersecurity documentation can easily expose sensitive system information, this project follows a security-first publishing model.

## Supported Content

The repository may contain:

- PowerShell automation and validation scripts
- Windows 11 configuration guidance
- Cybersecurity workstation documentation
- VMware integration guidance
- DFIR and network-analysis workflows
- Sanitized screenshots and example output
- Security baseline procedures

The repository must not contain real credentials, authentication secrets, recovery material, or personally identifying workstation data.

## Sensitive Information

Never commit or publish:

- Passwords or passphrases
- API keys
- Access tokens
- Session cookies
- SSH private keys
- BitLocker recovery keys
- Authentication recovery codes
- Certificate private keys
- VPN credentials or private profiles
- Browser credential exports
- Packet captures containing private traffic
- Unredacted forensic artifacts
- Personally identifying screenshots
- Private email addresses
- Device serial numbers
- Account identifiers
- Other secrets or authentication material

## Screenshots

Only sanitized screenshots belong in:

`assets/sanitized-images/`

Raw screenshots must remain in:

`assets/raw-screenshots/`

The raw screenshot directory is excluded from Git.

Before publishing a screenshot, review:

1. Usernames and account names
2. Email addresses
3. IP addresses where disclosure is unnecessary
4. Hostnames
5. Browser tabs and history
6. File paths
7. Device identifiers
8. Authentication material
9. Recovery information
10. Background applications or notifications containing private information

## Repository Safety Checks

Before every public push:

1. Review `git status`.
2. Review staged files with `git diff --cached`.
3. Run the repository safety scanner when available.
4. Inspect screenshots manually.
5. Confirm that no secret or recovery material is staged.
6. Push only after the review passes.

## Security Issue Reporting

If you discover a security issue in this project, avoid publicly posting working credentials, private information, or other sensitive material in a GitHub issue.

Describe the issue without exposing the sensitive data.

## Disclaimer

This project is intended for defensive security, system administration, cybersecurity education, authorized laboratory use, and professional development.

Users are responsible for understanding and validating changes before applying them to their own systems.
