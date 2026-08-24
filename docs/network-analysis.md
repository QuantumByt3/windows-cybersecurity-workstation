# Network Analysis with Wireshark and Npcap

## Overview

Network analysis is a core capability of the Windows 11 Cybersecurity Workstation.

This project uses:

- **Wireshark** for graphical packet inspection
- **TShark** for command-line packet analysis and capture validation
- **Npcap** as the Windows packet-capture driver

Together, these tools provide visibility into network interfaces, protocols, connections, and packet-level activity.

This guide focuses on safe installation, validation, and basic capture workflows.

---

## Tested Environment

The workstation baseline used for this project was validated with:

| Component | Tested Version |
|---|---|
| Wireshark | 4.6.8 |
| TShark | 4.6.8 |
| Npcap | 1.88 |
| Windows | Windows 11 |
| PowerShell | PowerShell 7 |

These are **tested versions**, not permanent version requirements.

Where practical, users should install the current stable release from the official publisher.

---

# 1. Architecture

On Windows, Wireshark does not capture packets directly from the network adapter by itself.

The basic architecture is:

```text
Network Adapter
      │
      ↓
    Npcap
      │
      ↓
 ┌─────────────┐
 │             │
 ↓             ↓
Wireshark    TShark
GUI          CLI
```

Npcap provides the packet-capture interface that Wireshark and TShark use to observe network traffic.

Without a working packet-capture driver, Wireshark may launch successfully while still being unable to perform useful live captures.

---

# 2. Install Wireshark

Wireshark can be installed through Windows Package Manager.

```powershell
winget install `
    --id WiresharkFoundation.Wireshark `
    -e `
    --source winget
```

After installation, restart the terminal if necessary.

Verify the graphical executable:

```powershell
Get-Item "C:\Program Files\Wireshark\Wireshark.exe"
```

Verify TShark:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" --version
```

Example:

```text
TShark (Wireshark) 4.x
```

The exact current version may differ from the version used to test this repository.

---

# 3. Npcap

## Why Npcap Matters

Npcap is the packet-capture driver used by Wireshark on modern Windows systems.

A successful Wireshark installation does not necessarily guarantee that Npcap is installed and functioning.

The workstation used to validate this project required Npcap to be installed separately.

---

## Obtain Npcap

Download Npcap only from its official publisher.

Do not install packet-capture drivers from unofficial mirrors or unknown software repositories.

Because Npcap operates at a low level within Windows networking, installer provenance matters.

---

# 4. Verify the Npcap Installer

Before executing a downloaded installer, inspect its Authenticode signature.

Example:

```powershell
Get-AuthenticodeSignature `
    "$HOME\Downloads\npcap-<VERSION>.exe"
```

A legitimate installer should return a valid signature from the expected publisher.

Example conceptually:

```text
Status
------
Valid
```

Do not continue if the signature is:

```text
NotSigned
UnknownError
HashMismatch
NotTrusted
```

until the cause has been investigated.

---

# 5. Npcap Installation Options

For a general cybersecurity workstation, conservative defaults are appropriate.

The tested workstation did **not** require:

- Administrative-only capture mode
- Raw 802.11 traffic support
- WinPcap compatibility mode

These options should not be enabled automatically.

Enable specialized features only when:

1. They are technically required.
2. Their security implications are understood.
3. The network adapter supports the capability.
4. The activity is authorized.

---

# 6. Verify the Npcap Service

After installation:

```powershell
Get-Service npcap
```

Expected state:

```text
Status   Name
------   ----
Running  npcap
```

If Npcap is installed but the service is stopped, Wireshark may be unable to capture traffic.

---

# 7. Verify the Npcap Driver

The driver is normally located at:

```text
C:\Windows\System32\drivers\npcap.sys
```

Check that it exists:

```powershell
Get-Item "$env:WINDIR\System32\drivers\npcap.sys"
```

Inspect its version:

```powershell
(Get-Item "$env:WINDIR\System32\drivers\npcap.sys").VersionInfo |
    Select-Object ProductVersion, FileVersion
```

The tested workstation reported Npcap version:

```text
1.88
```

---

# 8. Enumerate Capture Interfaces

Before performing a capture, determine which interfaces TShark can see.

Run:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" -D
```

Possible interfaces may include:

```text
Wi-Fi
Ethernet
VMware Network Adapter VMnet1
VMware Network Adapter VMnet8
Loopback
```

The exact interface list depends on the workstation.

Virtualization software such as VMware may create additional virtual network adapters.

---

# 9. Selecting the Correct Interface

Do not assume interface number `1` is always the desired adapter.

Interface numbering can change after:

- Driver updates
- VPN installation
- VMware changes
- Network adapter changes
- Windows updates
- Docking or undocking hardware

Always enumerate interfaces first:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" -D
```

Then identify the interface associated with the intended network connection.

---

# 10. Basic TShark Capture Validation

A short capture can verify that the capture stack works without generating a large packet-capture file.

First identify the desired interface number.

Then run:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" `
    -i <INTERFACE_NUMBER> `
    -a duration:5 `
    -c 20
```

This instructs TShark to:

```text
Capture from selected interface
        ↓
Stop after 5 seconds
        OR
Stop after 20 packets
```

whichever condition is reached first.

This is useful as a functional test.

---

# 11. What a Successful Validation Proves

A successful short capture demonstrates that:

- TShark launches correctly
- Npcap is functioning
- The network interface is visible
- The user has sufficient capture permissions
- Packets are reaching the capture engine

It does **not** prove that every protocol or network path is visible.

---

# 12. Wireshark GUI Validation

Launch Wireshark:

```powershell
& "C:\Program Files\Wireshark\Wireshark.exe"
```

The startup screen should list available capture interfaces.

Select the appropriate interface and begin a short capture.

Generate ordinary traffic, such as opening a website, and verify that packets appear.

Stop the capture after validation.

Do not save the capture unless it is needed.

---

# 13. Display Filters

Wireshark display filters allow captured packets to be narrowed to specific traffic.

Examples:

## DNS

```text
dns
```

## TCP

```text
tcp
```

## UDP

```text
udp
```

## TLS

```text
tls
```

## ICMP

```text
icmp
```

## Specific documentation IP

```text
ip.addr == 192.0.2.10
```

The address above belongs to an RFC 5737 documentation range and is not a real workstation address.

---

# 14. Capture Filters vs Display Filters

Wireshark supports two different filtering concepts.

## Capture Filter

Controls which packets are collected.

Example:

```text
tcp port 443
```

Packets that do not match the filter are not captured.

## Display Filter

Controls which already-captured packets are displayed.

Example:

```text
tcp.port == 443
```

The underlying packets remain in the capture.

This distinction is important:

```text
Capture Filter
      ↓
Determines collection

Display Filter
      ↓
Determines visibility after collection
```

For learning and troubleshooting, capturing first and applying display filters afterward is often easier.

---

# 15. Common Network Interfaces

A cybersecurity workstation may expose several classes of interfaces.

## Physical Interfaces

Examples:

```text
Wi-Fi
Ethernet
```

These represent physical network connectivity.

## VMware Interfaces

VMware Workstation may create adapters such as:

```text
VMnet1
VMnet8
```

Typical purposes include host-only and NAT networking.

Do not assume that capturing on the physical Wi-Fi interface will show all traffic inside a virtual network.

When investigating VM traffic, determine which VMware interface corresponds to the VM network architecture.

## Loopback

Loopback captures may expose traffic involving:

```text
127.0.0.1
```

This can be useful when analyzing locally hosted services and development tooling.

---

# 16. Wireshark and VMware

A workstation running VMware may contain several traffic paths:

```text
Kali VM
   │
   ↓
VMware Virtual Adapter
   │
   ↓
VMware NAT / Virtual Network
   │
   ↓
Windows Host
   │
   ↓
Physical Network Adapter
```

The interface selected for capture determines which portion of this path is visible.

For example, VM traffic may be observable differently on:

- VMnet interfaces
- Physical Wi-Fi
- The guest operating system itself

Capture location matters.

---

# 17. Wi-Fi Capture Limitations

Capturing from a Windows Wi-Fi interface does not automatically place the wireless adapter into monitor mode.

A normal Wi-Fi capture generally reflects traffic available to the host's network stack.

Raw 802.11 frame capture requires:

- Compatible hardware
- Compatible drivers
- Appropriate Npcap options
- A justified technical need

Do not enable raw 802.11 capture merely because the option exists.

---

# 18. Packet Capture Privacy

Packet captures can contain significantly more sensitive information than screenshots or command output.

A capture may expose:

- Internal IP addresses
- DNS queries
- Hostnames
- Service names
- Session metadata
- Authentication exchanges
- User activity
- Network architecture
- Application protocols
- Other devices on the network

For this reason, this repository ignores packet-capture formats such as:

```text
*.pcap
*.pcapng
*.cap
```

Packet captures should not be committed casually.

---

# 19. Repository Policy for Captures

The default rule for this project is:

> Do not commit real packet captures from private or production networks.

If packet-level examples are eventually needed, use:

- Purpose-built laboratory traffic
- Synthetic captures
- Public training captures
- Heavily sanitized artifacts

and review them carefully before publication.

---

# 20. Saving Captures

If a capture must be saved locally:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" `
    -i <INTERFACE_NUMBER> `
    -a duration:10 `
    -w "$HOME\Cybersecurity\Captures\example.pcapng"
```

Before saving, confirm that the destination is not inside a public Git repository.

The repository `.gitignore` provides guardrails, but `.gitignore` is not a security boundary.

---

# 21. Administrative Privileges

Do not run Wireshark or TShark as Administrator by default.

A normal user session is preferred when the configured Npcap installation permits capture.

Administrative execution should be reserved for situations where it is genuinely required and understood.

This follows the workstation's broader principle of least privilege.

---

# 22. Troubleshooting — No Interfaces Appear

If TShark reports no useful capture interfaces:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" -D
```

check:

```powershell
Get-Service npcap
```

Then verify:

```powershell
Test-Path "$env:WINDIR\System32\drivers\npcap.sys"
```

If either fails, inspect the Npcap installation before reinstalling Wireshark.

---

# 23. Troubleshooting — Npcap Service Is Stopped

Check:

```powershell
Get-Service npcap
```

If the service unexpectedly shows:

```text
Stopped
```

investigate before forcing configuration changes.

Possible causes include:

- Installation problems
- Driver failure
- Security software interaction
- Incomplete restart
- Corrupted installation

Avoid disabling Windows security controls merely to make packet capture work.

---

# 24. Troubleshooting — `tshark` Is Not on PATH

A Wireshark installation may work correctly even if:

```powershell
tshark --version
```

returns a command-not-found error.

Use the full path:

```powershell
& "C:\Program Files\Wireshark\tshark.exe" --version
```

Adding software directories to PATH is optional and should not be treated as evidence that the software itself is broken.

---

# 25. Troubleshooting — Wireshark Opens but Cannot Capture

Check the layers independently:

```text
Wireshark application
        ↓
TShark
        ↓
Npcap service
        ↓
Npcap driver
        ↓
Network interface
```

Useful commands:

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

This is preferable to repeatedly reinstalling software without identifying which layer failed.

---

# 26. Troubleshooting — Virtual Machine Traffic Is Missing

If expected VMware traffic is not visible:

1. Enumerate interfaces with TShark.
2. Identify the VM networking mode.
3. Determine whether the VM uses NAT, host-only, or bridged networking.
4. Inspect the corresponding VMware interface.
5. Consider capturing inside the guest VM when appropriate.

The physical network interface is not always the correct observation point.

---

# 27. Wireshark vs TCPView

Wireshark and TCPView serve different purposes.

## TCPView

Provides a rapid view of:

- Processes
- Local endpoints
- Remote endpoints
- TCP state
- Listening sockets

## Wireshark

Provides packet-level analysis of:

- Protocols
- Headers
- Network conversations
- DNS
- TLS metadata
- TCP behavior
- Packet timing
- Network troubleshooting

A practical workflow may be:

```text
TCPView identifies a connection
          ↓
Wireshark investigates its traffic
```

---

# 28. Wireshark vs PowerShell Networking Commands

Windows also provides useful built-in commands.

Examples:

```powershell
Get-NetAdapter
```

```powershell
Get-NetIPAddress
```

```powershell
Get-NetTCPConnection
```

These provide host-level networking information without packet capture.

Use the least invasive tool that answers the question.

---

# 29. Responsible Capture

Only capture network traffic when you are authorized to do so.

Appropriate contexts include:

- Your own workstation
- Your own network
- Authorized lab environments
- CTF environments
- Cyber ranges
- Explicitly authorized security assessments
- Troubleshooting environments where permission has been granted

Do not assume that access to a network automatically grants permission to inspect other users' traffic.

---

# 30. Validation Checklist

After configuration, verify:

- [ ] Wireshark launches
- [ ] TShark reports its version
- [ ] Npcap service is running
- [ ] Npcap driver exists
- [ ] Capture interfaces are enumerated
- [ ] Expected physical interface appears
- [ ] Relevant VMware interfaces appear when VMware is installed
- [ ] Short TShark capture succeeds
- [ ] Wireshark GUI capture succeeds
- [ ] Wireshark is not unnecessarily running elevated
- [ ] Packet captures are excluded from the public repository

---

# 31. Tested Workstation Result

The project workstation successfully validated:

```text
Wireshark / TShark
        ↓
Npcap service
        ↓
Npcap driver
        ↓
Windows network interfaces
        ↓
Successful short packet capture
```

The tested environment detected physical, loopback, and VMware-related interfaces and successfully completed a limited packet capture.

This confirms the network-analysis stack is operational without requiring Wireshark to run permanently with administrative privileges.

---

## Related Documentation

See:

- [Tool Manifest](tool-manifest.md)
- [Windows Security Baseline](windows-security-baseline.md)
- [Development Environment](development-environment.md)
- [Repository Sanitization Guide](sanitization-guide.md)

---

## Core Principle

> Capture only what you are authorized to inspect, store only what you genuinely need, and never treat packet captures as harmless diagnostic files.