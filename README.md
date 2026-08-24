# Windows 11 Cybersecurity Workstation

A security-focused, reproducible Windows 11 workstation build for cybersecurity students, professionals, homelab users, and anyone who wants a capable platform for development, network analysis, digital forensics, virtualization, and authorized security testing.

> This project documents not only **what to install**, but also **why each component is used, how it is validated, and how to configure it without unnecessarily weakening the Windows host**.
---

## Quick Navigation

- [Windows 11 Cybersecurity Workstation](#windows-11-cybersecurity-workstation)
  - [Quick Navigation](#quick-navigation)
  - [Quick Start](#quick-start)
  - [Project Goals](#project-goals)
  - [Core Design Principles](#core-design-principles)
  - [Workstation Architecture](#workstation-architecture)
  - [Repository Structure](#repository-structure)
  - [Tooling](#tooling)
    - [Development](#development)
    - [Network Analysis](#network-analysis)
    - [DFIR and Windows Internals](#dfir-and-windows-internals)
    - [Virtualization](#virtualization)
  - [Security-First Publishing](#security-first-publishing)
  - [Documentation](#documentation)
  - [Automation](#automation)
    - [Validation Scripts](#validation-scripts)
    - [Reusable PowerShell Examples](#reusable-powershell-examples)
  - [Intended Audience](#intended-audience)
  - [Contributing](#contributing)
  - [Responsible Use](#responsible-use)
  - [Project Status](#project-status)
  - [License](#license)
  - [Author](#author)

---

## Quick Start

This repository is designed to support a clean Windows 11 workstation build rather than blindly installing a large collection of security tools.

A recommended build sequence is:

1. **Establish the Windows security baseline**
   - Apply Windows updates.
   - Confirm Microsoft Defender is enabled.
   - Confirm Windows Firewall is enabled.
   - Verify BitLocker or Device Encryption.
   - Verify TPM and Secure Boot.

2. **Install the development environment**
   - PowerShell 7
   - Git
   - Python
   - Visual Studio Code
   - GitHub CLI
   - 7-Zip

3. **Configure secure development workflows**
   - Create a dedicated GitHub SSH key.
   - Use Python virtual environments.
   - Configure Git identity.
   - Keep credentials and secrets out of repositories.

4. **Install network-analysis tooling**
   - Wireshark
   - Npcap

5. **Build the Windows DFIR toolkit**
   - Process Explorer
   - Process Monitor
   - Autoruns
   - TCPView
   - Sigcheck
   - Strings

6. **Configure virtualization**
   - VMware Workstation
   - Dedicated Kali Linux VM
   - NAT-based VM networking unless another architecture is specifically required

7. **Validate the workstation**
   - Confirm security controls remain enabled.
   - Verify installed tools.
   - Review network interfaces.
   - Test Git, Python, Wireshark, and virtualization independently.

> Detailed installation instructions and validation scripts are being developed under the `docs/` and `scripts/` directories.

---


## Project Goals

This project provides a practical methodology for building a Windows 11 cybersecurity workstation that can support:

- Cybersecurity coursework and research
- Python and PowerShell development
- Git and GitHub workflows
- Digital forensics and incident response
- Network traffic analysis
- Windows internals analysis
- VMware-based security laboratories
- Kali Linux virtualization
- Hack The Box and CTF environments
- Authorized penetration-testing workflows
- Technical documentation and reporting

The Windows host is treated as the **trusted daily-use workstation**, while offensive tooling can be isolated inside dedicated virtual machines.

---

## Core Design Principles

The workstation follows several security and operational principles:

1. **Keep the Windows host protected**
   - Microsoft Defender remains enabled.
   - Windows Firewall remains enabled.
   - BitLocker protects the system drive.
   - Secure Boot and TPM remain enabled.

2. **Separate host and offensive environments**
   - Windows handles daily work, development, documentation, and analysis.
   - Kali Linux runs inside VMware for penetration-testing workflows.

3. **Do not weaken security for convenience**
   - Security controls are not disabled merely because a tool requests it.
   - Software is obtained from trusted sources whenever possible.
   - Digital signatures are validated for security-sensitive tools.

4. **Use isolated development environments**
   - Python projects use virtual environments.
   - Git repositories exclude secrets, credentials, and local environment data.

5. **Document and verify**
   - Important configuration decisions are documented.
   - Baseline checks are repeatable.
   - Automation scripts will provide workstation validation.

---

## Workstation Architecture

```text
Windows 11 Host
│
├── Windows Security
│   ├── Microsoft Defender
│   ├── Windows Firewall
│   ├── BitLocker
│   ├── TPM
│   └── Secure Boot
│
├── Development
│   ├── PowerShell 7
│   ├── Python
│   ├── Visual Studio Code
│   ├── Git
│   └── GitHub CLI
│
├── Network Analysis
│   ├── Wireshark
│   └── Npcap
│
├── DFIR / Windows Internals
│   ├── Process Explorer
│   ├── Process Monitor
│   ├── Autoruns
│   ├── TCPView
│   ├── Sigcheck
│   └── Strings
│
└── Virtualization
    └── VMware Workstation
        └── Kali Linux VM
```

---

## Repository Structure

```text
windows-cybersecurity-workstation/
│
├── README.md
├── SECURITY.md
├── .gitignore
│
├── docs/
│   └── sanitization-guide.md
│
├── scripts/
│
├── examples/
│   ├── git/
│   ├── powershell/
│   └── vscode/
│
├── assets/
│   └── sanitized-images/
│
└── private/                # Local-only and excluded from Git
```

Additional documentation, automation, examples, and troubleshooting material will be added as the project develops.

---

## Tooling

### Development

| Tool | Purpose |
|---|---|
| PowerShell 7 | Modern Windows shell and automation |
| Python | Scripting, automation, and cybersecurity development |
| Visual Studio Code | Primary editor and development environment |
| Git | Local source control |
| GitHub CLI | GitHub repository and workflow management |
| 7-Zip | Archive and file-management utility |

### Network Analysis

| Tool | Purpose |
|---|---|
| Wireshark | Packet inspection and protocol analysis |
| Npcap | Windows packet-capture driver |

### DFIR and Windows Internals

| Tool | Purpose |
|---|---|
| Process Explorer | Advanced process inspection |
| Process Monitor | File system, registry, process, and thread activity |
| Autoruns | Startup and persistence analysis |
| TCPView | Process-to-network connection mapping |
| Sigcheck | Digital signatures, hashes, and file metadata |
| Strings | Static extraction of readable strings from binaries |

### Virtualization

| Tool | Purpose |
|---|---|
| VMware Workstation | Virtualized security laboratory environment |
| Kali Linux | Dedicated penetration-testing and security-testing VM |

---

## Security-First Publishing

This repository is designed to be publicly accessible without exposing sensitive workstation information.

Before publication:

- Credentials are excluded.
- SSH private keys are excluded.
- BitLocker recovery information is excluded.
- Raw packet captures are excluded.
- Raw screenshots are excluded.
- Personally identifying paths and account information are sanitized.

See:

[Repository Sanitization Guide](docs/sanitization-guide.md)

and

[Security Policy](SECURITY.md)

for additional details.

---

## Documentation

Detailed guides for the workstation are available in the `docs/` directory:

- [Windows Security Baseline](docs/windows-security-baseline.md)
- [Development Environment](docs/development-environment.md)
- [Git and GitHub Workflow](docs/git-github-workflow.md)
- [Network Analysis](docs/network-analysis.md)
- [DFIR and Sysinternals](docs/dfir-sysinternals.md)
- [VMware Workstation Integration](docs/vmware-integration.md)
- [Workstation Validation](docs/workstation-validation.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Tool Manifest](docs/tool-manifest.md)
- [Repository Sanitization Guide](docs/sanitization-guide.md)

---

## Automation

The repository includes PowerShell scripts for workstation validation, repository safety, and repeatable development setup.

### Validation Scripts

- [`Test-SecurityBaseline.ps1`](scripts/Test-SecurityBaseline.ps1) — validates the Windows security baseline while handling checks that require elevation.
- [`Test-NetworkAnalysis.ps1`](scripts/Test-NetworkAnalysis.ps1) — validates Wireshark, TShark, Npcap, capture interfaces, and VMware network adapters.
- [`Test-SysinternalsToolkit.ps1`](scripts/Test-SysinternalsToolkit.ps1) — validates the installed Sysinternals toolkit, versions, and Microsoft Authenticode signatures.
- [`Test-RepositorySafety.ps1`](scripts/Test-RepositorySafety.ps1) — scans the repository for publication risks such as secrets, sensitive files, local-only paths, and identifying information.

### Reusable PowerShell Examples

- [`get-tool-versions.ps1`](examples/powershell/get-tool-versions.ps1) — inventories key workstation software and tested tool versions.
- [`install-development-tools.ps1`](examples/powershell/install-development-tools.ps1) — provides controlled installation and explicit upgrade handling for the development toolchain.
- [`windows-security-baseline-commands.ps1`](examples/powershell/windows-security-baseline-commands.ps1) — provides reusable commands for inspecting Windows security controls.

The goal is to make workstation configuration **verifiable and repeatable**, not merely documented.

---

## Intended Audience

This project may be useful for:

- Cybersecurity students
- SOC and DFIR learners
- Penetration-testing students
- IT administrators
- Homelab builders
- CTF participants
- Security researchers
- Windows power users

---

## Contributing

Contributions, corrections, compatibility updates, documentation improvements, and security-focused enhancements are welcome.

Review the [Contribution Guidelines](CONTRIBUTING.md) before opening an issue or pull request.

See the [Changelog](CHANGELOG.md) for notable project changes.

---

## Responsible Use

This project is intended for:

- Defensive cybersecurity
- Cybersecurity education
- System administration
- Digital forensics
- Authorized laboratory environments
- CTF environments
- Authorized penetration testing

Users are responsible for ensuring that security-testing activities are performed only against systems for which they have explicit authorization.

---

## Project Status

**Active Development**

The workstation baseline has been established and documentation, automation, validation scripts, and sanitized examples are being developed.

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Author

**QuantumByt3**

Cybersecurity student and practitioner focused on hands-on security engineering, digital forensics, network analysis, and practical cybersecurity education.