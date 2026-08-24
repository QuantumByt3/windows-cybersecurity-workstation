# Changelog

All notable changes to the **Windows 11 Cybersecurity Workstation** project are documented in this file.

This project uses a practical changelog rather than treating every Git commit as a release.

---

## Unreleased

### Added

- Windows security baseline documentation
- PowerShell security-baseline validation
- Development environment documentation
- Development-tool installation and update evaluation
- Tool-version inventory
- Git and GitHub workflow documentation
- Git command cheat sheet
- Repository sanitization guidance
- Repository safety scanner
- Network-analysis documentation
- Wireshark and Npcap validation
- Sysinternals / DFIR documentation
- Sysinternals toolkit validation
- VMware Workstation integration documentation
- Consolidated troubleshooting guide
- Master workstation validation checklist
- Contribution guidelines
- GitHub issue templates
- Pull request template
- GitHub Actions validation workflow
- MIT License

### Security

- Added repository secret-pattern scanning
- Added private-path and personal-data review checks
- Added packet-capture exclusions
- Added raw-screenshot exclusions
- Added local-only repository directories
- Added Git tracking checks for sensitive local-only paths
- Added Authenticode validation for Npcap and Sysinternals tooling
- Documented safe handling of package-integrity failures
- Added least-privilege guidance throughout the workstation build

---

## Initial Public Baseline — 2026-08

### Added

- Initial Windows 11 cybersecurity workstation repository
- Reproducible security baseline
- PowerShell automation
- Development toolchain documentation
- GitHub SSH workflow
- Tool manifest
- Repository publication safeguards

### Validation

The initial public baseline validated:

- Microsoft Defender
- Windows Firewall
- BitLocker
- TPM
- Secure Boot
- PowerShell 7
- Git
- GitHub CLI
- Python
- Visual Studio Code
- 7-Zip
- Wireshark
- TShark
- Npcap
- VMware Workstation
- Microsoft Sysinternals utilities