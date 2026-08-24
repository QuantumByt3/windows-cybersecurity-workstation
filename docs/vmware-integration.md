# VMware Workstation Integration

## Overview

Virtualization is a core component of the Windows 11 Cybersecurity Workstation.

This project uses **VMware Workstation** to provide isolated guest operating systems for:

- Cybersecurity laboratories
- Capture-the-flag environments
- Hack The Box work
- Linux tooling
- Application testing
- Network experimentation
- Defensive analysis
- Controlled offensive-security exercises

The workstation baseline was validated with a Kali Linux guest running under VMware Workstation on Windows 11.

This guide focuses on:

- VMware installation and validation
- Windows virtualization compatibility
- Guest resource allocation
- NAT networking
- VMware virtual adapters
- VMware Tools / open-vm-tools
- Hardware compatibility
- Snapshot strategy
- Common integration problems
- Security boundaries

---

# Tested Environment

The validated workstation used:

| Component | Tested Configuration |
|---|---|
| Host OS | Windows 11 |
| VMware Workstation | 26.0.0 build-25388281 |
| Guest OS | Kali Linux 2026.2 |
| Guest Architecture | AMD64 |
| Guest RAM | 8 GB |
| Guest CPU Allocation | 4 cores |
| Guest Disk | approximately 80 GB |
| Networking | NAT |
| VMware Tools | open-vm-tools |
| 3D Acceleration | Disabled |

These values are a tested baseline, not universal requirements.

Resource allocation should be adjusted according to the host system and workload.

---

# 1. Virtualization Architecture

The workstation architecture can be represented as:

```text
Windows 11 Host
      │
      ├── Native Windows Security Tooling
      │
      ├── Development Environment
      │
      ├── Wireshark / Npcap
      │
      ├── Sysinternals
      │
      └── VMware Workstation
              │
              ↓
          Kali Linux VM
              │
              ├── Security tools
              ├── Lab browsers
              ├── CTF tooling
              ├── Scripting
              └── Authorized testing
```

The Windows host remains the primary workstation.

The Kali guest provides a separate security-testing environment without requiring the host operating system itself to become the offensive-tooling platform.

---

# 2. Why Use a Virtual Machine?

A virtual machine provides useful separation between:

```text
Personal / development environment
              and
Cybersecurity testing environment
```

Benefits include:

- Easier rollback
- Isolated package management
- Separate operating-system configuration
- Easier lab reproduction
- Reduced host clutter
- Controlled network design
- Snapshot support
- Dedicated security tooling

A VM is not automatically a complete security boundary.

Misconfigured networking, shared folders, clipboard integration, mounted drives, and exposed services can reduce isolation.

---

# 3. VMware Workstation Installation

Install VMware Workstation only from an official or trusted publisher source.

After installation, verify the executable and version.

Example:

```powershell
Get-Item `
    "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe"
```

Depending on installation architecture or version, the exact path may differ.

Check version metadata:

```powershell
(Get-Item `
    "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe"
).VersionInfo |
    Select-Object `
        ProductVersion,
        FileVersion
```

The validated workstation reported:

```text
26.0.0 build-25388281
```

---

# 4. Windows Hypervisor Compatibility

Modern Windows security features may use Microsoft's virtualization stack.

Examples can include:

- Hyper-V
- Virtualization-Based Security
- Credential Guard
- Device Guard
- Windows Hypervisor Platform

VMware Workstation can operate in compatibility modes that coexist with these technologies.

The tested workstation used VMware successfully while Windows hypervisor-related protections remained enabled.

---

# 5. Do Not Disable Windows Security Features Automatically

A common troubleshooting recommendation found online is to disable:

```text
Hyper-V
Credential Guard
Device Guard
Virtualization-Based Security
Memory Integrity
```

to improve virtualization behavior.

This project does **not** treat that as a default solution.

Disabling host security protections may introduce unnecessary risk.

Preferred sequence:

```text
Confirm virtualization problem
        ↓
Identify compatibility limitation
        ↓
Determine whether VMware supports current Windows configuration
        ↓
Use supported compatibility path
        ↓
Disable security controls only when justified and understood
```

---

# 6. Nested Virtualization

Nested virtualization means exposing virtualization extensions from the physical processor to a guest VM.

Conceptually:

```text
Physical Host
    ↓
VMware Guest
    ↓
Nested Hypervisor / Nested VM
```

Nested virtualization may not be available when VMware is operating through the Windows hypervisor compatibility layer.

The tested workstation did not rely on nested virtualization.

---

# 7. When Nested Virtualization Matters

Nested virtualization may be relevant for:

- Running Hyper-V inside a guest
- Running nested ESXi
- Some container or emulator configurations
- Certain advanced lab designs

Many cybersecurity workflows do not require it.

Typical tooling such as:

- Nmap
- Burp Suite
- Caido
- BloodHound clients
- Python
- Metasploit
- Gobuster
- ffuf
- Wireshark
- John the Ripper

does not inherently require nested virtualization.

---

# 8. Guest Resource Allocation

The tested Kali guest used:

```text
RAM:        8 GB
CPU:        4 cores
Disk:       ~80 GB
Networking: NAT
```

This was selected for a Windows host with sufficient memory and processing capacity.

Do not allocate all host resources to the VM.

The Windows host still needs capacity for:

- Browser sessions
- VMware itself
- Windows Defender
- VS Code
- Wireshark
- Communications software
- Background services
- File operations

---

# 9. Memory Allocation

A practical virtualization rule is:

> Leave enough memory for the host to remain responsive under expected workload.

For example, on a host with substantial RAM, an 8 GB Kali allocation may provide comfortable operation without starving Windows.

More memory is not automatically better.

Excessive allocation can reduce overall workstation performance.

---

# 10. CPU Allocation

The tested Kali VM used:

```text
4 processor cores
```

This is sufficient for many cybersecurity tasks.

CPU-heavy workloads may include:

- Password auditing
- Compilation
- Large scans
- Static analysis
- Some cryptographic workloads

Do not assume that assigning every host core to a VM improves performance.

The host operating system and VMware scheduler also require resources.

---

# 11. Disk Allocation

The tested VM used an approximately:

```text
80 GB
```

virtual disk.

Disk requirements depend on:

- Installed packages
- Wordlists
- Captures
- Source code
- Tool caches
- Updates
- Lab artifacts

Large wordlists and packet captures can consume substantial storage.

---

# 12. Network Mode

The validated Kali VM uses:

```text
NAT
```

NAT was intentionally retained rather than switching the guest to bridged networking.

---

# 13. VMware NAT

Conceptually:

```text
Kali VM
   │
   ↓
VMware NAT
   │
   ↓
Windows Host
   │
   ↓
Physical Network
   │
   ↓
Internet
```

NAT allows the guest to access external networks through the host without placing the guest directly on the physical LAN as a normal peer device.

---

# 14. Why NAT Is a Good Default

NAT is useful for a cybersecurity workstation because it generally provides:

- Internet access
- Separation from the physical LAN
- Predictable guest connectivity
- Reduced exposure to other local devices
- Simple VMware configuration

It does not make unauthorized activity acceptable.

Network authorization requirements still apply regardless of virtualization mode.

---

# 15. NAT Is Not Complete Isolation

A NAT guest can still:

- Access Internet services
- Communicate with reachable networks
- Generate traffic through the host
- Access services allowed by VMware configuration

Therefore:

```text
NAT ≠ air gap
```

If an exercise requires strict network isolation, use an appropriately designed isolated lab network.

---

# 16. Bridged Networking

Bridged mode conceptually places the VM onto the same physical network as the host.

```text
Physical Network
      │
      ├── Windows Host
      └── Kali VM
```

This may be useful for specific lab scenarios but increases exposure to the local network.

Do not switch to bridged mode simply because a tutorial recommends it.

Understand the environment first.

---

# 17. Host-Only Networking

Host-only networking can provide communication between:

```text
Host
  ↕
VM
```

without normal external-network access.

This can be useful for:

- Isolated targets
- Malware-analysis labs
- Training networks
- Multi-VM exercises
- Controlled application testing

The exact configuration should match the lab's security requirements.

---

# 18. VMware Virtual Network Adapters

VMware may create Windows adapters such as:

```text
VMnet1
VMnet8
```

Commonly:

```text
VMnet1 → host-only
VMnet8 → NAT
```

Exact configuration should be verified rather than assumed.

PowerShell can enumerate host adapters:

```powershell
Get-NetAdapter
```

Wireshark or TShark may also expose VMware interfaces.

---

# 19. Inspecting VMware Interfaces

Run:

```powershell
Get-NetAdapter |
    Where-Object {
        $_.InterfaceDescription -match "VMware"
    }
```

This provides a quick view of VMware-created network adapters.

For packet capture:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" -D
```

may show VMware interfaces as available capture points.

---

# 20. Guest Network Validation

Inside the Linux guest, inspect interfaces with:

```bash
ip addr
```

Inspect routes:

```bash
ip route
```

Test basic external connectivity:

```bash
ping -c 4 1.1.1.1
```

Test DNS separately:

```bash
getent hosts example.com
```

This helps distinguish:

```text
Network path failure
        from
DNS resolution failure
```

---

# 21. Do Not Publish Real Lab Addresses Unnecessarily

Public documentation should avoid exposing private workstation-specific values.

Prefer placeholders:

```text
<GUEST_IP>
<GATEWAY_IP>
<HOST_ONLY_SUBNET>
```

or documentation networks when examples require actual IP syntax.

---

# 22. Kali Guest Installation Source

The validated workstation used an official Kali VMware image rather than an unknown preconfigured security VM.

Using publisher-provided images reduces uncertainty regarding:

- Operating-system modifications
- Preinstalled accounts
- Tool changes
- Hidden services
- Image provenance

---

# 23. Verify Downloaded VM Images

Large VM images should be integrity-checked when the publisher provides hashes.

Example:

```powershell
Get-FileHash `
    -Algorithm SHA256 `
    -Path ".\kali-linux-<VERSION>-vmware-amd64.7z"
```

Compare the resulting digest against the official publisher value.

Do not rely solely on the filename.

---

# 24. Archive Extraction

Kali VMware images may arrive as compressed archives.

Use a trusted extraction utility such as 7-Zip.

After extraction, keep VM files in a controlled directory.

Example:

```text
C:\VMs\
```

rather than scattering VM components across Downloads or Desktop.

---

# 25. VM Folder Design

A simple structure is:

```text
C:\VMs\
└── kali-linux-<VERSION>-vmware-amd64.vmwarevm\
```

Advantages include:

- Easier backup
- Easier migration
- Easier snapshot awareness
- Clear storage accounting
- Less accidental deletion

Do not store VM disks inside a Git repository.

---

# 26. VMware Tools

For Linux guests, VMware integration commonly uses:

```text
open-vm-tools
```

Check status inside Kali:

```bash
systemctl status open-vm-tools
```

If installed and operating correctly, the service should be active.

---

# 27. What VMware Tools Provides

Depending on the guest and configuration, VMware Tools may support:

- Improved mouse integration
- Time synchronization
- Display integration
- Guest information
- Clipboard integration
- Drag-and-drop functionality
- Graceful shutdown
- VMware communication services

Not every capability should automatically be enabled.

---

# 28. Clipboard and Drag-and-Drop Security

Convenience features can weaken separation between host and guest.

Consider the implications of:

```text
Host clipboard ↔ Guest clipboard
Host files     ↔ Guest drag-and-drop
Shared folders ↔ Guest access
```

For higher-risk analysis environments, disabling these features may be appropriate.

For standard CTF and authorized lab work, users may choose convenience based on risk.

---

# 29. Shared Folders

Shared folders make host files accessible inside the guest.

This can be useful for:

- Reports
- Scripts
- Lab notes
- Data exchange

However, shared folders also create a direct trust relationship.

Avoid sharing broad directories such as:

```text
C:\
$HOME\
Documents\
```

Prefer narrowly scoped folders when sharing is needed.

---

# 30. Guest Credentials

Do not reuse critical Windows, Microsoft, school, work, or GitHub passwords inside lab VMs.

Use unique guest credentials.

Guest credentials should still be strong because VM snapshots, exported disks, and local compromise can expose them.

---

# 31. VMware Hardware Compatibility

VMware VMs have a virtual hardware compatibility level.

This determines which VMware virtual-hardware features the guest can use.

Older compatibility levels may intentionally exist to maximize portability across VMware versions.

---

# 32. Do Not Assume Old Compatibility Means Broken Packaging

A prebuilt VM may ship with an older compatibility level intentionally.

Possible reasons include:

- Wider VMware compatibility
- Easier import across releases
- Conservative virtual hardware support
- Reduced dependency on recent VMware features

Do not automatically classify older virtual hardware as a packaging mistake.

---

# 33. Hardware Compatibility and Troubleshooting

The tested workstation encountered a guest cursor-visibility problem.

Changing VMware virtual hardware compatibility to a newer Workstation compatibility level resolved that specific cursor problem.

This demonstrates an important troubleshooting principle:

```text
Observe symptom
      ↓
Change one relevant variable
      ↓
Retest
      ↓
Record actual result
```

Do not claim that a compatibility upgrade fixes unrelated problems.

---

# 34. Compatibility Upgrade Caution

Before upgrading VM hardware compatibility:

1. Shut down the VM.
2. Confirm a backup or snapshot exists.
3. Understand potential backward-compatibility implications.
4. Upgrade one VM at a time.
5. Test afterward.

Newer virtual hardware may not open correctly in substantially older VMware versions.

---

# 35. Display Integration

Linux guest display integration depends on several components:

```text
VMware virtual graphics
        ↓
Guest kernel / display stack
        ↓
Desktop environment
        ↓
open-vm-tools
        ↓
VMware integration
```

A display problem can originate at any layer.

---

# 36. 3D Acceleration

The tested Kali VM operated with:

```text
Accelerate 3D graphics: Disabled
```

This was appropriate for the validated security workstation.

3D acceleration is not required for typical:

- Terminal work
- Browser-based labs
- Burp Suite
- Caido
- Nmap
- Python
- Git
- CTF workflows

Enable it only when needed.

---

# 37. Dynamic Display Resizing

Automatic guest-display resizing can depend on:

- open-vm-tools
- Desktop environment
- Display protocol
- VMware guest integration
- Window-manager behavior
- VMware version

The tested workstation had working VMware tools but dynamic resizing remained a separate integration issue.

Therefore:

> Do not treat successful VMware Tools installation as proof that every display-integration feature is functioning.

---

# 38. Troubleshooting Display Resizing

Inside a Linux guest, verify:

```bash
systemctl status open-vm-tools
```

Then inspect:

```bash
ps aux | grep vmtoolsd
```

Check desktop integration components appropriate for the guest environment.

Avoid repeatedly reinstalling VMware Tools without first identifying which integration layer is failing.

---

# 39. Cursor Problems

If the guest cursor disappears or renders incorrectly:

1. Confirm guest OS is responsive.
2. Check VMware Tools.
3. Disable unnecessary 3D acceleration.
4. Review virtual hardware compatibility.
5. Test VMware display settings.
6. Change one variable at a time.

Record which change actually resolves the issue.

---

# 40. Snapshot Strategy

Snapshots are one of the most valuable features of virtualization for cybersecurity labs.

A snapshot records recoverable VM state.

Useful milestones include:

```text
Clean OS
   ↓
Updated OS
   ↓
Configured workstation
   ↓
Before risky lab change
```

---

# 41. Recommended Snapshot Naming

Use descriptive names.

Example:

```text
01 - Clean Kali Baseline
02 - Updated Stable Kali
03 - Security Workstation Configured
04 - Before Major Tool Upgrade
```

Avoid names such as:

```text
snapshot1
test
new
copy
```

Clear names reduce restoration mistakes.

---

# 42. Snapshots Are Not Backups

A snapshot is generally stored as part of the VM's disk chain.

If the VM folder or physical drive is lost, snapshots can be lost too.

Therefore:

```text
Snapshot ≠ backup
```

Use separate backup procedures for important VMs.

---

# 43. Snapshot Before Major Changes

Consider a snapshot before:

- Kernel upgrades
- Desktop-environment changes
- VMware compatibility upgrades
- Major toolchain changes
- Network redesign
- Experimental packages
- Complex lab configuration

Snapshots allow rapid recovery from configuration mistakes.

---

# 44. Snapshot Sprawl

Too many snapshots can create:

- Disk consumption
- Complex disk chains
- Performance overhead
- Confusing restore points

Snapshots should be deliberate and periodically reviewed.

---

# 45. VM Suspend vs Shutdown

Suspend preserves runtime state.

Shutdown performs a normal guest OS shutdown.

For major configuration changes such as:

- Virtual hardware modification
- Disk changes
- Compatibility upgrades
- Some networking changes

a complete shutdown is preferable.

---

# 46. Windows Host Security Still Applies

Running Kali in VMware does not remove the need to protect Windows.

The host should maintain:

- Microsoft Defender
- Windows Firewall
- BitLocker
- Secure Boot
- TPM
- Windows Update
- Least-privilege operation

The guest is part of the workstation, not a replacement for host security.

---

# 47. Guest Security Still Matters

A cybersecurity VM should also be maintained.

Inside Kali:

```bash
sudo apt update
sudo apt full-upgrade
```

Review upgrade output before accepting major changes in important environments.

Keep the guest patched unless a lab explicitly requires an older vulnerable configuration.

---

# 48. Lab Targets vs Security Workstation

Do not deliberately make the primary Kali workstation vulnerable merely because it is used for cybersecurity.

If vulnerable services are needed, use:

- Separate target VMs
- Purpose-built vulnerable machines
- Containers
- Cyber ranges
- HTB environments

Keep the primary security workstation reasonably hardened.

---

# 49. VMware Networking and Authorized Testing

A VM does not change authorization boundaries.

Only test:

- Systems you own
- Systems you administer with permission
- Cyber ranges
- CTF environments
- Approved lab machines
- Explicitly authorized assessment targets

Do not treat:

```text
"I am inside Kali"
```

as equivalent to:

```text
"I am authorized to attack anything reachable"
```

---

# 50. Packet Capture and VMware

When analyzing VM traffic from Windows, capture location matters.

Possible observation points include:

```text
Guest interface
VMware VMnet adapter
Host physical adapter
```

Each may show a different perspective.

See:

```text
docs/network-analysis.md
```

for packet-capture guidance.

---

# 51. VMware NAT and Wireshark

A useful architecture is:

```text
Kali
 ↓
VMware NAT
 ↓
VMnet interface
 ↓
Windows
 ↓
Physical network
```

Depending on the investigative goal, capturing on a VMware virtual adapter can provide better visibility into guest traffic than capturing only on the physical Wi-Fi interface.

---

# 52. Host Firewall

Do not disable Windows Firewall simply because a VM cannot reach something.

Instead determine:

- Guest IP
- Guest route
- VMware network mode
- Host adapter state
- Target reachability
- Firewall rule
- Service listening state

Troubleshoot the actual path.

---

# 53. Guest Firewall

Linux guests may also enforce firewall rules.

Useful inspection commands can include:

```bash
sudo nft list ruleset
```

or tooling appropriate for the distribution.

Do not assume a connectivity failure originates on Windows.

---

# 54. DNS Troubleshooting

If the VM can reach an IP address but not a hostname:

```bash
ping -c 4 1.1.1.1
```

works, but:

```bash
getent hosts example.com
```

fails, investigate DNS.

Check:

```bash
cat /etc/resolv.conf
```

and the guest's active resolver configuration.

---

# 55. VMware Service Troubleshooting

If VMware networking or VM startup fails, inspect relevant Windows services.

Example:

```powershell
Get-Service |
    Where-Object {
        $_.DisplayName -match "VMware"
    }
```

Do not restart or reconfigure services blindly.

Determine which component is failing first.

---

# 56. Host Adapter Troubleshooting

Inspect:

```powershell
Get-NetAdapter
```

and:

```powershell
Get-NetIPConfiguration
```

Look for:

- Disabled VMware adapters
- Missing VMnet interfaces
- Unexpected address configuration
- Physical connectivity issues

---

# 57. Guest Connectivity Troubleshooting Sequence

Use a layered approach:

```text
1. Guest interface exists
2. Guest has IP address
3. Guest has route
4. Guest reaches gateway
5. Guest reaches external IP
6. DNS resolves
7. Application reaches service
```

Inside Linux:

```bash
ip addr
ip route
ping -c 4 <GATEWAY>
ping -c 4 1.1.1.1
getent hosts example.com
```

This is more useful than repeatedly toggling VMware settings.

---

# 58. VMware Process Validation

On Windows, VMware processes may appear in:

- Task Manager
- Process Explorer
- TCPView

This is expected while VMware services or guests are active.

Correlate the process name with:

- Installation path
- Publisher
- Signature
- Service
- VM state

before classifying behavior.

---

# 59. VMware and Sysinternals

Sysinternals can help troubleshoot VMware.

Examples:

## Process Explorer

Inspect VMware processes and command lines.

## Process Monitor

Observe file and registry operations during VM startup.

## TCPView

Inspect VMware-related network endpoints.

## Autoruns

Review VMware startup components and services.

See:

```text
docs/dfir-sysinternals.md
```

---

# 60. VM Storage Security

Virtual-disk files can contain:

- Operating-system credentials
- Browser sessions
- SSH keys
- Lab artifacts
- Shell history
- Source code
- Captures
- Tokens
- Configuration files

Protect VM storage appropriately.

BitLocker protection on the Windows host provides useful at-rest protection for VM files stored on the encrypted system volume.

---

# 61. VM Exports

An exported VM may contain far more sensitive information than expected.

Before sharing or publishing a VM:

- Remove credentials
- Remove tokens
- Remove SSH private keys
- Clear browser data
- Remove private captures
- Remove personal files
- Review shell history
- Review network configuration
- Review application secrets

Never assume a VM is sanitized simply because it is a laboratory machine.

---

# 62. Shared Clipboard Risk

Clipboard synchronization can inadvertently expose:

- Passwords
- Tokens
- Commands
- Personal text
- Host data

For higher-risk environments, disable clipboard sharing.

For ordinary authorized training environments, evaluate the convenience/security tradeoff.

---

# 63. USB Device Passthrough

VMware can attach USB devices to the guest.

Remember that attachment transfers practical control from:

```text
Windows Host
```

to:

```text
Guest VM
```

Avoid attaching sensitive storage devices to experimental or untrusted guests.

---

# 64. Network Adapter Selection

A VM may support multiple virtual adapters.

Do not add extra adapters without a clear design.

Additional adapters increase:

- Routing complexity
- Exposure
- Troubleshooting difficulty
- Potential cross-network communication

Keep the VM network architecture as simple as the lab permits.

---

# 65. Time Synchronization

Accurate time is important for cybersecurity work because:

- Logs depend on timestamps
- PCAP analysis depends on time
- Authentication may depend on clock synchronization
- Event correlation depends on time

Verify guest time:

```bash
timedatectl
```

Time discrepancies can complicate DFIR analysis.

---

# 66. VMware Updates

Treat VMware updates like other security-sensitive software updates.

Before major updates:

1. Close important workloads.
2. Consider a VM snapshot or backup.
3. Review release information.
4. Install from trusted sources.
5. Reboot if required.
6. Validate guest startup.
7. Validate networking.
8. Validate VMware Tools.
9. Validate critical lab functionality.

---

# 67. Guest Kernel Updates

Linux kernel updates may affect:

- Display integration
- VMware Tools
- Network drivers
- Desktop behavior

After a kernel update:

```bash
uname -r
```

Verify:

```bash
systemctl status open-vm-tools
```

and test networking and display integration.

---

# 68. Troubleshooting Philosophy

Avoid changing many VMware settings simultaneously.

Use:

```text
Observe
   ↓
Hypothesize
   ↓
Change one variable
   ↓
Test
   ↓
Record result
```

This produces reproducible troubleshooting evidence.

---

# 69. Common Mistake — Switching to Bridged Mode Too Early

If a NAT guest cannot reach a target, switching immediately to bridged mode can:

- Mask the real problem
- Change the attack surface
- Place the VM on the physical LAN
- Create unnecessary network exposure

Understand the network requirement first.

---

# 70. Common Mistake — Disabling Hyper-V Security Features

Disabling hypervisor-related Windows protections may resolve some compatibility issues but also changes the host's security posture.

Do not use that as the first troubleshooting step.

---

# 71. Common Mistake — Allocating Too Many Resources

A VM configured with excessive CPU or RAM can degrade the host.

Optimize based on workload rather than maximizing every slider.

---

# 72. Common Mistake — Treating Snapshots as Permanent Backups

Snapshot chains are operational recovery tools.

Use actual backups for important VM preservation.

---

# 73. Common Mistake — Publishing VM Configuration

A `.vmx` or similar configuration file may reveal:

- Host paths
- VM names
- Network configuration
- Shared-folder locations
- Hardware information

Review VM configuration files before publishing them.

This repository does not require uploading the actual production VM configuration.

---

# 74. Common Mistake — Committing Virtual Disks

Never commit virtual disks such as:

```text
*.vmdk
*.vhd
*.vhdx
*.qcow2
```

to a normal source-code repository.

They are:

- Extremely large
- Potentially sensitive
- Poorly suited to Git
- Likely to contain credentials and private artifacts

---

# 75. Recommended `.gitignore` Protection

Repositories associated with VM documentation should consider ignoring:

```gitignore
*.vmdk
*.vhd
*.vhdx
*.vmem
*.vmss
*.vmsn
*.nvram
```

Actual policy should reflect the project.

---

# 76. VMware Validation Checklist

After installation, validate:

- [ ] VMware Workstation launches
- [ ] Version is identified
- [ ] Windows security protections remain enabled
- [ ] Guest starts successfully
- [ ] CPU allocation is appropriate
- [ ] RAM allocation is appropriate
- [ ] Disk capacity is adequate
- [ ] NAT networking works
- [ ] Guest receives an IP address
- [ ] Guest has a default route
- [ ] DNS resolution works
- [ ] open-vm-tools is running
- [ ] Mouse integration works
- [ ] Guest display is usable
- [ ] Snapshot strategy is established
- [ ] No unnecessary host directories are shared
- [ ] No sensitive virtual disks are tracked by Git

---

# 77. Tested Workstation Result

The validated workstation successfully operated a Kali Linux guest with:

```text
VMware Workstation 26.0.0 build-25388281
Kali Linux 2026.2
8 GB RAM
4 CPU cores
~80 GB virtual disk
NAT networking
open-vm-tools
3D acceleration disabled
```

The VM provided:

- Internet connectivity
- Kali tooling
- VMware NAT networking
- Working VMware Tools service
- Usable mouse integration
- Snapshot support
- Integration with the host cybersecurity workflow

A virtual-hardware compatibility upgrade resolved a cursor-visibility problem.

Dynamic automatic display resizing remained a separate integration issue and should not be represented as conclusively resolved.

---

# 78. Relationship to the Windows Workstation

VMware is one layer of the overall workstation:

```text
Windows Security Baseline
          │
          ├── Development Environment
          ├── Git / GitHub
          ├── Wireshark / Npcap
          ├── Sysinternals / DFIR
          └── VMware
                 ↓
              Kali VM
```

This architecture allows the Windows machine to remain the controlled primary workstation while providing a flexible Linux security environment.

---

## Related Documentation

See:

- [Windows Security Baseline](windows-security-baseline.md)
- [Network Analysis](network-analysis.md)
- [DFIR and Sysinternals](dfir-sysinternals.md)
- [Development Environment](development-environment.md)
- [Tool Manifest](tool-manifest.md)
- [Repository Sanitization Guide](sanitization-guide.md)

---

## Core Principles

> Keep the host secure rather than weakening Windows to make virtualization convenient.

> Use NAT as a sensible default unless a lab design requires something else.

> Treat snapshots as recovery checkpoints, not backups.

> Validate downloaded VM images before use.

> Keep guest credentials and artifacts separate from the host.

> Change one variable at a time when troubleshooting virtualization problems.