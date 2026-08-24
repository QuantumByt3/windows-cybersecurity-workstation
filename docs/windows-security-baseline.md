# Windows 11 Security Baseline

## Overview

Before installing cybersecurity tooling, development environments, virtual machines, or packet-analysis utilities, the Windows 11 host should first be treated as a trusted platform.

This baseline verifies that the major built-in Windows security controls are operational before the workstation is expanded into a cybersecurity environment.

The baseline covers:

- Windows Update
- Microsoft Defender Antivirus
- Windows Defender Firewall
- BitLocker Drive Encryption
- Trusted Platform Module (TPM)
- Secure Boot
- System Restore / System Protection
- Administrative privilege discipline

The objective is not to disable Windows security features for convenience.

The objective is to build cybersecurity capability **while preserving the security of the host operating system**.

---

# 1. Windows Update

Start with a fully patched Windows 11 installation.

Open:

```text
Settings > Windows Update
```

Select:

```text
Check for updates
```

Install normal Windows security and cumulative updates.

Treat the following separately before installation:

- Preview updates
- BIOS updates
- Firmware updates
- Optional driver updates

These updates may still be appropriate, but they should be reviewed before installation rather than installed blindly.

## Verification

The Windows Update page should report:

```text
You're up to date
```

---

# 2. Microsoft Defender Baseline

Microsoft Defender should remain enabled unless another trusted endpoint-security product intentionally replaces it.

For a cybersecurity workstation, disabling Defender globally is generally poor practice.

Open a normal PowerShell session and run:

```powershell
Get-MpComputerStatus |
    Select-Object `
        AntivirusEnabled,
        RealTimeProtectionEnabled,
        BehaviorMonitorEnabled,
        IoavProtectionEnabled,
        NISEnabled,
        AntispywareEnabled,
        AntivirusSignatureLastUpdated
```

Expected security-control values:

```text
AntivirusEnabled            True
RealTimeProtectionEnabled   True
BehaviorMonitorEnabled      True
IoavProtectionEnabled       True
NISEnabled                  True
AntispywareEnabled          True
```

The exact signature-update timestamp will vary.

## What These Controls Do

### AntivirusEnabled

Confirms that Microsoft Defender Antivirus is operational.

### RealTimeProtectionEnabled

Provides real-time inspection of files and processes as they are accessed or executed.

### BehaviorMonitorEnabled

Allows Defender to analyze process behavior rather than relying solely on static signatures.

### IoavProtectionEnabled

Provides inspection of downloaded files and attachments.

### NISEnabled

Enables the Network Inspection System used to detect certain network-based threats.

### AntispywareEnabled

Confirms Defender's antispyware protection remains operational.

---

# 3. Windows Firewall Baseline

All Windows Firewall profiles should remain enabled.

Run:

```powershell
Get-NetFirewallProfile |
    Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction
```

Expected result:

```text
Name     Enabled
----     -------
Domain   True
Private  True
Public   True
```

`DefaultInboundAction` or `DefaultOutboundAction` may display:

```text
NotConfigured
```

This does not automatically indicate a problem.

It may mean the profile is using Windows' inherited/default policy instead of an explicitly overridden value.

## Security Principle

Do not disable Windows Firewall merely because a cybersecurity application requires network access.

Create narrowly scoped firewall rules when a legitimate application specifically requires them.

---

# 4. BitLocker Drive Encryption

BitLocker protects data stored on the workstation if the device is lost, stolen, or accessed outside the normal Windows authentication process.

Checking BitLocker status requires an elevated terminal.

Open PowerShell **as Administrator** and run:

```powershell
manage-bde -status C:
```

A protected system drive should show values similar to:

```text
BitLocker Version:    2.0
Percentage Encrypted: 100.0%
Protection Status:    Protection On
Lock Status:          Unlocked
Key Protectors:
    Numerical Password
    TPM
```

The encryption algorithm may vary by system configuration.

For example:

```text
XTS-AES 128
```

or another supported BitLocker configuration may be present.

## Important

Never publish or share the actual 48-digit BitLocker recovery key.

It is safe to document that a recovery protector exists.

It is **not** safe to publish the recovery password itself.

Example of safe documentation:

```text
Key Protectors:
    Numerical Password
    TPM
```

Do not include the numerical recovery key.

---

# 5. Trusted Platform Module (TPM)

TPM stands for:

**Trusted Platform Module**

A TPM is a hardware-backed security component used to protect cryptographic secrets and support platform-integrity functions.

Windows uses the TPM for technologies including:

- BitLocker
- Windows Hello
- Device identity
- Cryptographic key protection
- Measured boot
- Platform integrity

Run from an elevated PowerShell session:

```powershell
Get-Tpm |
    Select-Object `
        TpmPresent,
        TpmReady,
        TpmEnabled,
        TpmActivated
```

Expected result:

```text
TpmPresent     True
TpmReady       True
TpmEnabled     True
TpmActivated   True
```

## Interpretation

### TpmPresent

Windows detects a TPM.

### TpmReady

The TPM is initialized and available for use.

### TpmEnabled

The TPM is enabled by the system firmware.

### TpmActivated

The TPM is activated and usable by Windows.

---

# 6. Secure Boot

Secure Boot helps ensure that trusted boot components are loaded during system startup.

From an elevated PowerShell session run:

```powershell
Confirm-SecureBootUEFI
```

Expected result:

```text
True
```

A result of:

```text
True
```

means Secure Boot is enabled.

Do not disable Secure Boot unless a specific, justified technical requirement exists.

---

# 7. System Protection and Restore Points

Windows System Protection can create restore points that allow certain system-level changes to be rolled back.

Restore points are useful before:

- Major driver changes
- Security-tool installation
- Virtualization changes
- System configuration changes
- Large workstation build phases

## GUI Configuration

Open:

```text
Create a restore point
```

Select:

```text
Windows (C:) (System)
```

Choose:

```text
Configure
```

Enable:

```text
Turn on system protection
```

A small percentage of disk space can be reserved for restore points.

For example:

```text
3%
```

is sufficient for many workstation configurations.

Create a restore point before making major workstation changes.

Example description:

```text
Cybersecurity Workstation Baseline
```

## PowerShell Alternative

On supported Windows client systems, restore points can also be created from an elevated PowerShell session:

```powershell
Checkpoint-Computer `
    -Description "Cybersecurity Workstation Baseline" `
    -RestorePointType "MODIFY_SETTINGS"
```

Windows may limit how frequently restore points can be created.

---

# 8. Administrator vs Standard Sessions

Routine cybersecurity work should not require every terminal session to run as Administrator.

Use a standard PowerShell session for:

- Git
- Python
- VS Code
- GitHub CLI
- File management
- Most development workflows

Use elevation only when a task requires administrative access.

## Check Current Elevation State

Run:

```powershell
([Security.Principal.WindowsPrincipal]`
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
```

Expected result from a normal terminal:

```text
False
```

A result of:

```text
True
```

means the terminal is running with administrative privileges.

---

# 9. Baseline Verification Checklist

A healthy Windows 11 cybersecurity workstation baseline should satisfy the following:

| Control | Desired State |
|---|---|
| Windows Update | Current |
| Microsoft Defender Antivirus | Enabled |
| Defender Real-Time Protection | Enabled |
| Defender Behavior Monitoring | Enabled |
| Windows Firewall Domain Profile | Enabled |
| Windows Firewall Private Profile | Enabled |
| Windows Firewall Public Profile | Enabled |
| BitLocker | Protection On |
| System Drive Encryption | 100% |
| TPM | Present and Ready |
| Secure Boot | Enabled |
| System Protection | Enabled |
| Routine Terminal | Non-administrative |

---

# 10. Commands Summary

## Defender

```powershell
Get-MpComputerStatus |
    Select-Object `
        AntivirusEnabled,
        RealTimeProtectionEnabled,
        BehaviorMonitorEnabled,
        IoavProtectionEnabled,
        NISEnabled,
        AntispywareEnabled,
        AntivirusSignatureLastUpdated
```

## Firewall

```powershell
Get-NetFirewallProfile |
    Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction
```

## BitLocker

Run as Administrator:

```powershell
manage-bde -status C:
```

## TPM

Run as Administrator:

```powershell
Get-Tpm |
    Select-Object TpmPresent, TpmReady, TpmEnabled, TpmActivated
```

## Secure Boot

Run as Administrator:

```powershell
Confirm-SecureBootUEFI
```

## Administrator State

```powershell
([Security.Principal.WindowsPrincipal]`
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
```

---

# 11. What This Baseline Does Not Do

This baseline intentionally does **not**:

- Disable Microsoft Defender
- Disable Windows Firewall
- Disable Secure Boot
- Disable TPM
- Disable BitLocker
- Add broad Defender exclusions
- Open unnecessary inbound firewall ports
- Enable unnecessary remote-access services
- Lower PowerShell security settings globally
- Store recovery keys in the repository

Cybersecurity tooling should operate around the security controls of the host whenever reasonably possible.

---

# 12. Next Steps

After completing this baseline, continue with:

1. Development environment setup
2. Git and GitHub configuration
3. Python environment setup
4. Visual Studio Code integration
5. Network analysis tooling
6. Windows DFIR tooling
7. VMware Workstation configuration
8. Workstation validation automation

---

## Security Principle

> A cybersecurity workstation should increase the operator's capabilities without unnecessarily decreasing the security of the system they depend on.