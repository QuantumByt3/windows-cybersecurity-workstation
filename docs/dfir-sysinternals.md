# DFIR and Windows Internals with Microsoft Sysinternals

## Overview

The Windows 11 Cybersecurity Workstation includes a focused set of Microsoft Sysinternals utilities for:

- Digital forensics and incident response
- Process investigation
- Startup and persistence analysis
- Network connection inspection
- File-signature verification
- Event tracing
- Static string extraction
- Windows internals troubleshooting

The primary tools documented in this project are:

- Process Explorer
- Process Monitor
- Autoruns
- TCPView
- Sigcheck
- Strings

These tools complement Windows-native PowerShell commands, Microsoft Defender, Windows Event Logs, Wireshark, and other security-analysis utilities.

---

# Tested Environment

The workstation baseline used for this project validated the following Sysinternals versions:

| Tool | Tested Version |
|---|---:|
| Process Explorer | 17.13 |
| Process Monitor | 4.1 |
| Autoruns | 14.3 |
| TCPView | 4.19 |
| Sigcheck | 2.91 |
| Strings | 2.54 |

These are **tested versions**, not permanent version requirements.

Users should generally obtain current stable releases directly from Microsoft unless a specific compatibility requirement exists.

---

# 1. Why Sysinternals?

Windows includes many built-in administrative and diagnostic utilities.

Sysinternals extends that visibility with specialized tools capable of exposing:

- Process relationships
- Loaded executables
- Digital signatures
- Command lines
- Registry operations
- File-system activity
- Startup entries
- Services
- Network endpoints
- Executable metadata
- Embedded strings

For cybersecurity work, this provides a useful bridge between:

```text
Normal system administration
          ↓
Troubleshooting
          ↓
Security analysis
          ↓
DFIR investigation
```

---

# 2. Security Principle: Tool Provenance Matters

DFIR tools often require elevated visibility into the operating system.

That makes software provenance especially important.

Do not obtain Sysinternals binaries from:

- Random download sites
- Repackaged archives
- File-sharing services
- Unverified mirrors
- Third-party bundles with unknown modifications

Prefer official Microsoft sources.

---

# 3. Package Integrity Failure During Setup

During development of this workstation, an attempt was made to obtain Sysinternals through Windows Package Manager.

The package download completed, but WinGet returned an integrity error similar to:

```text
Installer hash does not match
```

The same condition occurred when attempting an individual Process Explorer package.

The package was **not forced through**.

No hash-bypass option was used.

Instead, the workflow changed to:

```text
Package integrity failure
        ↓
Stop installation
        ↓
Do not bypass verification
        ↓
Obtain tool from official Microsoft source
        ↓
Verify Authenticode signature
        ↓
Execute only after validation
```

This behavior is intentional.

---

# 4. Never Normalize Integrity Failures

A package-manager integrity failure is a security signal.

Possible explanations include:

- Publisher updated the binary
- Package metadata is stale
- CDN content changed
- Package-manifest hash is outdated
- Cache corruption
- Network corruption
- Repository synchronization issue
- Unexpected package modification

Most causes may ultimately be benign.

However, the workstation should not assume that.

Do not use options such as:

```text
ignore hash
force install
skip verification
```

merely to make installation succeed.

Investigate first.

---

# 5. Recommended Sysinternals Directory

A clean local structure is:

```text
$HOME\Tools\Sysinternals\
```

Example:

```text
Sysinternals/
├── ProcessExplorer/
├── ProcessMonitor/
├── Autoruns/
├── TCPView/
├── Sigcheck/
└── Strings/
```

Keeping each tool in a dedicated directory makes:

- Version inspection easier
- Updating easier
- Provenance review easier
- Scripting easier
- Documentation clearer

---

# 6. Authenticode Verification

Before executing a downloaded Sysinternals binary, verify its digital signature.

Example:

```powershell
Get-AuthenticodeSignature `
    "$HOME\Tools\Sysinternals\ProcessExplorer\procexp64.exe"
```

Review at least:

```text
Status
SignerCertificate
Path
```

A valid Microsoft binary should normally report:

```text
Status : Valid
```

The signer should correspond to Microsoft.

---

# 7. Generic Signature Validation Pattern

A reusable PowerShell pattern is:

```powershell
$Path = "$HOME\Tools\Sysinternals\TOOL\tool64.exe"

$Signature = Get-AuthenticodeSignature $Path

$Signature |
    Select-Object `
        Status,
        StatusMessage,
        Path
```

If:

```text
Status = Valid
```

that is strong evidence that the file is signed correctly.

It is not a substitute for obtaining the binary from an appropriate source.

---

# 8. Additional File Metadata

Inspect version metadata with:

```powershell
(Get-Item "PATH_TO_EXECUTABLE").VersionInfo |
    Select-Object `
        ProductName,
        ProductVersion,
        FileVersion,
        CompanyName
```

This is useful when documenting the workstation or comparing versions.

---

# 9. Process Explorer

## Purpose

Process Explorer provides advanced process inspection beyond the standard Windows Task Manager.

It can expose:

- Parent/child process relationships
- Executable paths
- Command lines
- Process ownership
- Loaded modules
- Handles
- Digital signatures
- Process resource activity
- Service relationships

Tested version:

```text
17.13
```

Validated executable:

```text
procexp64.exe
```

---

# 10. Launch Process Explorer

Example:

```powershell
& "$HOME\Tools\Sysinternals\ProcessExplorer\procexp64.exe"
```

Do not automatically run it elevated.

Normal-user visibility is often sufficient.

Elevate only when the investigation requires access unavailable to the standard session.

---

# 11. Recommended Process Explorer Columns

Useful fields include:

- Process
- PID
- CPU
- Private Bytes
- Working Set
- Description
- Company Name
- Verified Signer
- Command Line

The exact set can be adjusted according to the investigation.

---

# 12. Verify Image Signatures

One useful Process Explorer feature is:

```text
Verify Image Signatures
```

This allows Process Explorer to evaluate executable signatures.

A verified signer can help distinguish:

```text
Known signed Microsoft binary
            vs
Unsigned or unexpectedly signed executable
```

Signature verification alone does not prove that software is safe.

It is one investigative signal.

---

# 13. Command-Line Visibility

Enable the:

```text
Command Line
```

column when investigating processes.

For example:

```text
powershell.exe
```

does not tell the whole story.

The command line may reveal:

```text
powershell.exe -File example.ps1
```

or other invocation arguments.

Command-line context can be essential during process investigation.

---

# 14. Parent/Child Process Relationships

Process Explorer displays process ancestry.

Example:

```text
explorer.exe
    ↓
powershell.exe
    ↓
python.exe
```

This allows an analyst to reason about:

- Who launched a process
- Whether process ancestry is expected
- Whether execution chains appear unusual
- Whether a process originated from a browser, script host, service, or user shell

Parent-child relationships are especially useful in incident-response triage.

---

# 15. Do Not Treat Unknown as Malicious

A process may be:

- Unsigned
- Unfamiliar
- Located outside System32
- Launched by another application

without being malicious.

Investigate context before making conclusions.

Useful questions include:

- What is the executable path?
- Who owns the file?
- Is it digitally signed?
- What is the parent process?
- What command line launched it?
- Does the process have active network connections?
- Was it installed intentionally?
- Does its timing correspond with known software activity?

---

# 16. Process Monitor

## Purpose

Process Monitor provides detailed real-time visibility into:

- File-system operations
- Registry activity
- Process activity
- Thread activity
- Image loads

Tested version:

```text
4.1
```

Validated executable:

```text
Procmon64.exe
```

---

# 17. Why Process Monitor Is Powerful

A single application can generate thousands of operating-system events in seconds.

Process Monitor can expose operations such as:

```text
CreateFile
WriteFile
ReadFile
CloseFile
RegOpenKey
RegQueryValue
RegSetValue
Process Create
Process Exit
Load Image
```

This is valuable for:

- Troubleshooting
- Malware analysis
- Installation analysis
- Persistence investigation
- File activity tracing
- Registry investigation

---

# 18. Process Monitor Requires Filtering

Running Process Monitor without filters can generate an overwhelming amount of data.

A practical workflow is:

```text
Start Process Monitor
        ↓
Pause capture if needed
        ↓
Configure narrow filter
        ↓
Clear old events
        ↓
Resume capture
        ↓
Perform test action
        ↓
Stop capture
        ↓
Analyze result
```

Filtering should be deliberate.

---

# 19. Example Process Filter

To observe PowerShell activity:

```text
Process Name
is
pwsh.exe
Include
```

This limits visible events to operations involving PowerShell 7.

---

# 20. Example Path Filter

If investigating a test directory, use a path filter such as:

```text
Path
begins with
C:\Users\<USERNAME>\Cybersecurity\Projects\
Include
```

For public documentation, use placeholders rather than publishing a real local username.

---

# 21. Validated Process Monitor Exercise

The tested workstation successfully observed a controlled PowerShell file operation.

The workflow was:

```text
Filter for pwsh.exe
        ↓
Perform controlled file operation
        ↓
Observe CreateFile
        ↓
Observe WriteFile
        ↓
Observe CloseFile
```

This confirmed that Process Monitor was functioning correctly.

---

# 22. Process Monitor Event Volume

Process Monitor can consume substantial memory when left capturing for extended periods.

Avoid unattended captures without reason.

Stop collection when the needed activity has been observed.

Large traces may also contain private operational information.

---

# 23. Process Monitor Privacy

A Process Monitor trace may reveal:

- Usernames
- File paths
- Application names
- Registry paths
- Installed software
- User documents
- Temporary files
- Browser activity
- Network-related configuration
- Authentication artifacts

Do not publish raw `.PML` traces without deliberate review and sanitization.

---

# 24. Autoruns

## Purpose

Autoruns provides visibility into programs and components configured to start automatically.

Tested version:

```text
14.3
```

Validated executable:

```text
Autoruns64.exe
```

---

# 25. Autoruns Investigation Areas

Autoruns can expose categories such as:

- Logon entries
- Services
- Scheduled tasks
- Drivers
- Explorer extensions
- Browser-related components
- AppInit entries
- Image hijacks
- Known DLL mechanisms

This makes Autoruns particularly useful for persistence analysis.

---

# 26. Recommended Autoruns Configuration

For initial triage, useful options include:

```text
Hide Microsoft Entries
Hide Windows Entries
Verify Code Signatures
```

These reduce noise and emphasize non-Microsoft components.

VirusTotal integration is optional and should not be enabled automatically.

---

# 27. Why Hide Microsoft and Windows Entries?

A typical Windows installation contains a very large number of legitimate Microsoft startup components.

Hiding them allows the analyst to focus initially on:

- Third-party software
- User-installed applications
- Non-Microsoft drivers
- Shell extensions
- Startup utilities

This is a filtering strategy, not a trust decision.

Microsoft entries can still be investigated when relevant.

---

# 28. Autoruns Is Not a Removal Tool by Default

Do not treat every unfamiliar startup item as something to disable.

First determine:

- Publisher
- File path
- Signature
- Purpose
- Installation source
- Relationship to installed software
- Whether the entry is expected

Disabling persistence mechanisms without understanding them can break legitimate software or system functionality.

---

# 29. Example Legitimate Third-Party Entries

Depending on the workstation, expected entries may include:

- Graphics utilities
- Audio drivers
- VMware utilities
- Compression shell extensions
- Communication clients
- Hardware control software

The presence of a third-party entry alone does not indicate compromise.

---

# 30. Unverified Does Not Automatically Mean Malicious

A legitimate component may appear as:

```text
Not Verified
```

for several reasons.

For example, a shell extension from a known installed application may not display the same signature status as the application's primary executable.

Investigate:

```text
Path
Publisher
File metadata
Installation context
Hash
Related software
```

before taking action.

---

# 31. TCPView

## Purpose

TCPView provides a process-oriented view of active network endpoints.

Tested version:

```text
4.19
```

Validated executable:

```text
tcpview64.exe
```

---

# 32. TCPView Displays

TCPView can display:

- Process name
- PID
- Protocol
- Local address
- Local port
- Remote address
- Remote port
- Connection state

This helps answer:

```text
Which process is communicating?
```

rather than immediately inspecting raw packets.

---

# 33. TCPView vs Wireshark

TCPView and Wireshark answer different questions.

TCPView:

```text
Which process owns this connection?
```

Wireshark:

```text
What is happening at the packet/protocol level?
```

A useful workflow is:

```text
TCPView
    ↓
Identify process and endpoint
    ↓
Wireshark
    ↓
Inspect relevant network traffic
```

---

# 34. Do Not Kill Connections Casually

TCPView can terminate connections.

This project treats connection termination as an active administrative action.

Do not close a connection merely because:

- The remote address is unfamiliar
- The port number looks unusual
- The process is not recognized immediately

Investigate first.

---

# 35. Correlating TCPView with PowerShell

Windows can also expose network connections through:

```powershell
Get-NetTCPConnection
```

Example:

```powershell
Get-NetTCPConnection |
    Select-Object `
        LocalAddress,
        LocalPort,
        RemoteAddress,
        RemotePort,
        State,
        OwningProcess
```

Resolve the process:

```powershell
Get-Process -Id <PID>
```

TCPView provides a convenient graphical representation of similar information.

---

# 36. Sigcheck

## Purpose

Sigcheck is a command-line utility for inspecting:

- File versions
- Digital signatures
- Publishers
- Hashes
- Certificate information
- Executable metadata

Tested version:

```text
2.91
```

Validated executable:

```text
sigcheck64.exe
```

---

# 37. Basic Sigcheck Usage

Example:

```powershell
& "$HOME\Tools\Sysinternals\Sigcheck\sigcheck64.exe" `
    "C:\Windows\System32\notepad.exe"
```

This can reveal:

- Verified signature
- Publisher
- Company
- Product
- Version
- File metadata

---

# 38. Hash Calculation with Sigcheck

Sigcheck can produce cryptographic hashes.

Example:

```powershell
& "$HOME\Tools\Sysinternals\Sigcheck\sigcheck64.exe" `
    -h `
    "C:\Windows\System32\notepad.exe"
```

Hashes are useful for:

- File identification
- Integrity comparison
- Incident documentation
- Threat-intelligence lookup
- Comparing binaries across systems

A hash alone does not determine whether a file is malicious.

---

# 39. Signature vs Hash

These concepts are related but different.

## Digital Signature

Helps answer:

```text
Who signed this file?
Has the signed content been modified?
```

## Cryptographic Hash

Helps answer:

```text
Is this exact file byte-for-byte identical to another known copy?
```

Both can be useful during investigation.

---

# 40. Example File Verification Workflow

```text
Suspicious or unknown executable
        ↓
Inspect file path
        ↓
Check Authenticode signature
        ↓
Inspect with Sigcheck
        ↓
Calculate SHA-256
        ↓
Compare with trusted information
        ↓
Correlate with process/network behavior
```

No single step should be treated as definitive evidence.

---

# 41. Strings

## Purpose

Strings extracts human-readable character sequences from binary files.

Tested version:

```text
2.54
```

Validated executable:

```text
strings64.exe
```

---

# 42. Basic Strings Usage

Example:

```powershell
& "$HOME\Tools\Sysinternals\Strings\strings64.exe" `
    "C:\Windows\System32\notepad.exe"
```

The output may include:

- DLL names
- Registry paths
- URLs
- Internal function names
- Error messages
- File paths
- Protocol references
- Configuration strings

---

# 43. Filtering Strings Output

Raw Strings output may be very large.

PowerShell can filter the results.

Example:

```powershell
& "$HOME\Tools\Sysinternals\Strings\strings64.exe" `
    "C:\Windows\System32\notepad.exe" |
    Select-String `
        -Pattern "http|dll|registry|software"
```

This reduces noise during exploratory analysis.

---

# 44. Strings Is Not Decompilation

Strings does not reconstruct source code.

It simply identifies printable character sequences embedded in a file.

A binary may contain interesting strings that:

- Are never executed
- Belong to libraries
- Are error messages
- Are diagnostic text
- Are unused
- Are deliberately misleading

Interpret strings in context.

---

# 45. Combining Sysinternals Tools

The tools become more powerful when used together.

Example investigation:

```text
Process Explorer
      ↓
Identify unusual process
      ↓
Inspect command line and parent
      ↓
TCPView
      ↓
Check active connections
      ↓
Sigcheck
      ↓
Inspect signature and hash
      ↓
Autoruns
      ↓
Check persistence
      ↓
Process Monitor
      ↓
Observe file/registry behavior
      ↓
Strings
      ↓
Inspect embedded textual artifacts
```

This is a triage workflow, not a substitute for a complete forensic methodology.

---

# 46. DFIR Triage Example

Suppose an unfamiliar application appears after logon.

A reasonable investigation sequence might be:

### Step 1 — Process Explorer

Determine:

- Process name
- PID
- Parent process
- Command line
- Executable path
- Verified signer

### Step 2 — TCPView

Determine:

- Whether the process is listening
- Whether it has remote connections
- Connection states
- Remote endpoints

### Step 3 — Sigcheck

Inspect:

- Signature
- Publisher
- Version
- Hash

### Step 4 — Autoruns

Determine whether the executable persists through:

- Logon
- Service
- Task
- Driver
- Shell extension

### Step 5 — Process Monitor

Observe:

- Files opened
- Files written
- Registry keys accessed
- Registry keys modified

### Step 6 — Strings

Inspect the binary for useful static indicators.

The evidence is then correlated before reaching a conclusion.

---

# 47. Least Privilege

Do not run every Sysinternals utility as Administrator by default.

Use a standard user session when possible.

Elevate only when:

- Required data is inaccessible
- The investigation explicitly requires elevated visibility
- The security implications are understood

This reduces unnecessary privileged execution.

---

# 48. Administrative Visibility

Some information may require elevation, including:

- Certain protected processes
- System services
- Kernel-related components
- Security-sensitive registry paths
- Some driver information

When elevation is required, use it deliberately and return to the standard session afterward.

---

# 49. VirusTotal Integration

Several Sysinternals tools can integrate with VirusTotal.

This can be useful, but it introduces privacy considerations.

Depending on the feature and configuration, information such as file hashes or files themselves may be sent to external services.

Do not automatically enable cloud-based analysis for:

- Proprietary software
- Sensitive evidence
- Client artifacts
- School or employer systems
- Private malware samples
- Incident-response evidence

Understand what will be transmitted before enabling the feature.

---

# 50. Repository Privacy

Do not commit raw investigation artifacts casually.

Potentially sensitive artifacts include:

```text
Process Monitor traces
Autoruns exports
Packet captures
Event log exports
Memory dumps
Registry exports
Process dumps
Network inventories
Screenshots
```

These may contain:

- Usernames
- Hostnames
- IP addresses
- Account names
- Installed software
- Network architecture
- File paths
- Tokens
- Authentication artifacts

Use the repository sanitization process before publication.

---

# 51. PowerShell Complements Sysinternals

Useful Windows-native commands include:

```powershell
Get-Process
```

```powershell
Get-Service
```

```powershell
Get-NetTCPConnection
```

```powershell
Get-CimInstance Win32_StartupCommand
```

```powershell
Get-AuthenticodeSignature
```

```powershell
Get-FileHash
```

Sysinternals should complement built-in tooling rather than replace it unnecessarily.

---

# 52. Process Explorer vs Task Manager

Task Manager is useful for:

- Basic process visibility
- Performance
- Startup apps
- User sessions
- Services

Process Explorer provides deeper investigative detail.

Use the simpler tool when it answers the question adequately.

---

# 53. Autoruns vs Windows Startup Apps

Windows Startup Apps provides a simplified view of common startup programs.

Autoruns exposes substantially more persistence locations.

That power requires additional care.

Do not disable entries merely because they do not appear in the standard Windows Startup Apps interface.

---

# 54. TCPView vs Get-NetTCPConnection

Both provide endpoint visibility.

PowerShell is useful for:

- Automation
- Filtering
- Export
- Scripting
- Correlation

TCPView is useful for:

- Rapid interactive triage
- Process association
- Visual connection monitoring

Choose according to the task.

---

# 55. Sigcheck vs Get-AuthenticodeSignature

PowerShell:

```powershell
Get-AuthenticodeSignature FILE
```

is excellent for signature validation.

Sigcheck adds additional executable and publisher metadata in a compact forensic utility.

Using both can provide independent perspectives during investigation.

---

# 56. Strings vs Select-String

These serve different purposes.

`Strings` extracts printable text from binary content.

`Select-String` searches text streams or files.

They can be combined:

```powershell
& "$HOME\Tools\Sysinternals\Strings\strings64.exe" FILE |
    Select-String -Pattern "http"
```

---

# 57. Evidence Preservation

If working on a real forensic investigation, avoid casually modifying evidence.

Potential concerns include:

- File timestamps
- Access metadata
- Process state
- Volatile memory
- Network state
- Registry changes

This workstation documentation demonstrates investigative tooling but does not replace an organization's forensic evidence-handling procedures.

---

# 58. Hash Before Analysis

When handling a potentially important file, consider calculating a hash before deeper analysis.

Example:

```powershell
Get-FileHash `
    -Algorithm SHA256 `
    -Path .\sample.exe
```

Record the result separately.

This helps establish a known identity for the artifact.

---

# 59. Avoid Executing Unknown Files

Tools such as Sigcheck and Strings can inspect files without launching them.

Do not execute an unknown binary merely to determine what it does.

Prefer static inspection and appropriate sandboxing or laboratory environments.

---

# 60. Production vs Laboratory Investigation

This repository supports:

- Personal workstation investigation
- Training environments
- CTF environments
- Cyber ranges
- Authorized lab systems
- Defensive troubleshooting

Real enterprise incident response may require:

- Chain of custody
- Legal approval
- Evidence preservation
- Central logging
- EDR telemetry
- Memory acquisition
- Disk imaging
- Formal incident procedures

Adapt accordingly.

---

# 61. Tool Version Inventory

A compact PowerShell inventory can use:

```powershell
(Get-Item `
    "$HOME\Tools\Sysinternals\ProcessExplorer\procexp64.exe"
).VersionInfo.ProductVersion
```

Repeat for other tools as appropriate.

This repository also provides:

```text
examples/powershell/get-tool-versions.ps1
```

for broader workstation inventory.

---

# 62. Recommended Baseline Validation

Verify the following:

```text
Process Explorer
    Executable exists
    Signature valid
    Version identified

Process Monitor
    Executable exists
    Signature valid
    Controlled event capture works

Autoruns
    Executable exists
    Signature valid
    Third-party entries visible

TCPView
    Executable exists
    Signature valid
    Active connections visible

Sigcheck
    Executable exists
    Signature valid
    Known Windows binary inspected

Strings
    Executable exists
    Signature valid
    Known Windows binary strings extracted
```

---

# 63. Common Mistake — Treating Signatures as Reputation

A valid digital signature tells you that:

- The file was signed
- The signature validates
- The signer identity is represented by the certificate

It does not guarantee that:

- The software is benign
- The software has no vulnerabilities
- The publisher's signing environment was never compromised
- The software is appropriate for your environment

Treat signatures as one part of the evidence.

---

# 64. Common Mistake — Treating Unsigned as Malicious

Many legitimate files may be unsigned.

Examples can include:

- Internal scripts
- Open-source utilities
- Lab tools
- Development builds
- Configuration helpers

Unsigned status increases the need for investigation but does not prove malicious intent.

---

# 65. Common Mistake — Overreacting to Network Connections

Modern applications regularly communicate with:

- CDNs
- Update services
- Authentication services
- Cloud infrastructure
- Telemetry platforms
- APIs

An unfamiliar remote endpoint should trigger investigation, not automatic classification.

Correlate:

```text
Process
Publisher
Destination
Port
Timing
DNS
Application behavior
```

---

# 66. Common Mistake — Leaving Procmon Running

Unbounded Process Monitor collection can generate:

- Massive event counts
- High memory usage
- Large trace files
- Excessive noise

Use focused filters and short capture windows.

---

# 67. Common Mistake — Disabling Autoruns Entries

Removing or disabling persistence without context may break:

- Drivers
- Hardware utilities
- VPN clients
- Audio software
- Virtualization components
- Application launchers

Investigate first.

---

# 68. Common Mistake — Publishing Raw DFIR Output

Command output can reveal more than expected.

Before publishing:

```powershell
Get-Process
Get-NetTCPConnection
Get-CimInstance
Autoruns exports
Sigcheck output
```

review for:

- Usernames
- Hostnames
- IP addresses
- Organization names
- Installed software
- File paths
- Account identifiers

Use placeholders where practical.

---

# 69. Troubleshooting — Tool Will Not Launch

Check:

```powershell
Test-Path "PATH_TO_EXECUTABLE"
```

Then:

```powershell
Get-AuthenticodeSignature "PATH_TO_EXECUTABLE"
```

Then inspect:

```powershell
(Get-Item "PATH_TO_EXECUTABLE").VersionInfo
```

Also consider:

- Windows SmartScreen
- Antivirus quarantine
- Download corruption
- Incorrect architecture
- Incomplete extraction

Do not disable Defender merely to make the tool run.

---

# 70. Troubleshooting — Access Denied

If a tool cannot inspect a protected component:

1. Determine whether the information is actually needed.
2. Confirm that the operation is authorized.
3. Elevate the individual tool only if necessary.
4. Avoid permanently operating the workstation as Administrator.

---

# 71. Troubleshooting — Process Monitor Produces Too Much Data

Use filters.

Start with:

```text
Process Name is <TARGET>
```

or:

```text
Path begins with <TARGET_PATH>
```

Then add additional criteria only as needed.

Clear the event buffer before repeating a controlled test.

---

# 72. Troubleshooting — Signature Is Not Valid

If:

```powershell
Get-AuthenticodeSignature FILE
```

does not return:

```text
Valid
```

do not immediately execute the file.

Check:

- Download source
- File integrity
- Publisher
- Certificate status
- Whether the expected binary is actually signed

Re-download from the official source if appropriate.

---

# 73. Troubleshooting — WinGet Hash Mismatch

If WinGet reports:

```text
Installer hash does not match
```

recommended workflow:

```text
STOP
 ↓
Do not bypass integrity validation
 ↓
Confirm package identity
 ↓
Check official publisher source
 ↓
Download from official source if appropriate
 ↓
Verify digital signature
 ↓
Document the discrepancy
```

Do not normalize hash mismatches as harmless installation friction.

---

# 74. Update Strategy

Sysinternals tools are updated independently.

Do not assume every utility will always have the same release date or versioning cadence.

When updating:

1. Obtain the current official binary.
2. Verify Authenticode.
3. Record the new version.
4. Validate basic functionality.
5. Update the repository tool manifest when appropriate.

---

# 75. Tool Integrity Checklist

For each Sysinternals utility:

- [ ] Obtained from Microsoft
- [ ] Correct architecture selected
- [ ] Archive extracted successfully
- [ ] Executable exists
- [ ] Authenticode status is valid
- [ ] Microsoft signer identified
- [ ] Version recorded
- [ ] Tool launches
- [ ] Basic functionality validated

---

# 76. DFIR Workstation Checklist

The validated workstation should provide:

- [ ] Process inspection
- [ ] Process ancestry
- [ ] Command-line inspection
- [ ] File/registry event tracing
- [ ] Persistence inspection
- [ ] Network endpoint inspection
- [ ] Signature validation
- [ ] SHA-256 hashing
- [ ] Static strings extraction
- [ ] Packet analysis
- [ ] Windows security baseline
- [ ] Least-privilege operation

---

# 77. Relationship to Other Repository Components

The Sysinternals toolkit complements:

## Windows Security Baseline

```text
docs/windows-security-baseline.md
```

Provides host security-state verification.

## Network Analysis

```text
docs/network-analysis.md
```

Provides packet-level visibility with Wireshark and Npcap.

## Tool Manifest

```text
docs/tool-manifest.md
```

Records validated versions and installation methods.

## Repository Sanitization

```text
docs/sanitization-guide.md
```

Defines how outputs and artifacts should be reviewed before publication.

---

# 78. Investigation Mindset

The objective of DFIR triage is not to label unfamiliar things as malicious.

The objective is to gather evidence systematically.

A useful model is:

```text
Observe
   ↓
Identify
   ↓
Correlate
   ↓
Validate
   ↓
Document
   ↓
Conclude
```

Avoid reversing that process by forming a conclusion first and searching only for evidence that supports it.

---

# 79. Practical Triage Sequence

When investigating an unknown Windows process:

```text
1. Process Explorer
   └─ Process identity and ancestry

2. TCPView
   └─ Network connections

3. Sigcheck
   └─ Signature, publisher, hash

4. Autoruns
   └─ Persistence

5. Process Monitor
   └─ File and registry behavior

6. Strings
   └─ Static text indicators

7. Wireshark
   └─ Packet-level analysis if needed
```

Not every investigation requires every tool.

Use the minimum tooling necessary to answer the question.

---

# 80. Tested Workstation Result

The project workstation successfully validated:

```text
Process Explorer 17.13
Process Monitor 4.1
Autoruns 14.3
TCPView 4.19
Sigcheck 2.91
Strings 2.54
```

Each executable used for the workstation baseline was verified with a valid Microsoft Authenticode signature before use.

The toolkit successfully demonstrated:

- Process inspection
- Verified signer visibility
- Command-line inspection
- Controlled file-operation tracing
- Persistence inspection
- Active connection inspection
- File-signature verification
- SHA-256 generation
- Static string extraction

This establishes a practical Windows DFIR and internals baseline without weakening core Windows security controls.

---

## Related Documentation

See:

- [Windows Security Baseline](windows-security-baseline.md)
- [Network Analysis](network-analysis.md)
- [Tool Manifest](tool-manifest.md)
- [Development Environment](development-environment.md)
- [Repository Sanitization Guide](sanitization-guide.md)

---

## Core Principles

> Obtain security tools from trusted sources.

> Treat integrity failures as signals, not inconveniences.

> Use least privilege.

> Gather evidence before drawing conclusions.

> Never publish raw forensic artifacts without reviewing them for sensitive information.