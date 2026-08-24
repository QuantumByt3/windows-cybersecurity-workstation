<#
.SYNOPSIS
    Validates the Windows network-analysis stack used by the
    Windows 11 Cybersecurity Workstation project.

.DESCRIPTION
    Performs read-only checks for:

    - Wireshark
    - TShark
    - Npcap service
    - Npcap driver
    - Npcap driver signature
    - Available capture interfaces
    - VMware virtual network adapters

    By default, this script does NOT capture packets.

    An optional controlled capture test can be requested by supplying
    -CaptureInterface with a TShark interface number.

    The optional capture:
    - Is limited by packet count and duration
    - Does not save a packet-capture file
    - Suppresses packet contents from terminal output

.PARAMETER CaptureInterface
    Optional TShark interface number to use for a controlled live-capture
    validation.

.PARAMETER CaptureDuration
    Maximum capture duration in seconds.

    Default: 5

.PARAMETER PacketLimit
    Maximum number of packets to capture.

    Default: 20

.EXAMPLE
    .\Test-NetworkAnalysis.ps1

    Performs read-only validation without capturing traffic.

.EXAMPLE
    .\Test-NetworkAnalysis.ps1 -CaptureInterface 3

    Performs validation and then attempts a short controlled capture on
    TShark interface 3.

.NOTES
    Project: Windows 11 Cybersecurity Workstation
    Author: QuantumByt3

    Only capture traffic on networks and systems where you are authorized
    to perform packet inspection.
#>

[CmdletBinding()]
param(
    [ValidateRange(1, 999)]
    [int]$CaptureInterface,

    [ValidateRange(1, 60)]
    [int]$CaptureDuration = 5,

    [ValidateRange(1, 1000)]
    [int]$PacketLimit = 20
)


# ------------------------------------------------------------
# State
# ------------------------------------------------------------

$PassCount = 0
$WarnCount = 0
$FailCount = 0
$InfoCount = 0

$WiresharkPath = "C:\Program Files\Wireshark\Wireshark.exe"
$TSharkPath = "C:\Program Files\Wireshark\tshark.exe"
$NpcapDriverPath = Join-Path $env:WINDIR "System32\drivers\npcap.sys"


# ------------------------------------------------------------
# Output Helper
# ------------------------------------------------------------

function Write-NetworkResult {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("PASS", "WARN", "FAIL", "INFO")]
        [string]$Status,

        [Parameter(Mandatory)]
        [string]$Check,

        [string]$Details = ""
    )

    $Color = switch ($Status) {
        "PASS" { "Green" }
        "WARN" { "Yellow" }
        "FAIL" { "Red" }
        "INFO" { "Cyan" }
    }

    switch ($Status) {
        "PASS" { $script:PassCount++ }
        "WARN" { $script:WarnCount++ }
        "FAIL" { $script:FailCount++ }
        "INFO" { $script:InfoCount++ }
    }

    $Message = "[$Status] $Check"

    if ($Details) {
        $Message += " - $Details"
    }

    Write-Host $Message -ForegroundColor $Color
}


# ------------------------------------------------------------
# Header
# ------------------------------------------------------------

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Windows Network Analysis Validation" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""


# ------------------------------------------------------------
# Wireshark
# ------------------------------------------------------------

Write-Host "--- Wireshark ---" -ForegroundColor Cyan

if (Test-Path $WiresharkPath) {

    $WiresharkVersion = (
        Get-Item $WiresharkPath
    ).VersionInfo.ProductVersion

    Write-NetworkResult `
        -Status "PASS" `
        -Check "Wireshark executable" `
        -Details "Version $WiresharkVersion"
}
else {

    Write-NetworkResult `
        -Status "FAIL" `
        -Check "Wireshark executable" `
        -Details "Not found at expected installation path"
}


# ------------------------------------------------------------
# TShark
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- TShark ---" -ForegroundColor Cyan

$TSharkAvailable = Test-Path $TSharkPath

if ($TSharkAvailable) {

    Write-NetworkResult `
        -Status "PASS" `
        -Check "TShark executable" `
        -Details $TSharkPath

    try {

        $TSharkVersionOutput = @(
            & $TSharkPath --version 2>&1
        )

        $TSharkVersionLine = $TSharkVersionOutput |
            Select-Object -First 1

        if ($LASTEXITCODE -eq 0 -and $TSharkVersionLine) {

            Write-NetworkResult `
                -Status "PASS" `
                -Check "TShark version query" `
                -Details $TSharkVersionLine
        }
        else {

            Write-NetworkResult `
                -Status "WARN" `
                -Check "TShark version query" `
                -Details "Executable exists but version query did not complete normally"
        }
    }
    catch {

        Write-NetworkResult `
            -Status "WARN" `
            -Check "TShark version query" `
            -Details "Unable to execute TShark"
    }
}
else {

    Write-NetworkResult `
        -Status "FAIL" `
        -Check "TShark executable" `
        -Details "Not found at expected installation path"
}


# ------------------------------------------------------------
# Npcap Service
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Npcap Service ---" -ForegroundColor Cyan

$NpcapService = Get-Service `
    -Name npcap `
    -ErrorAction SilentlyContinue

if (-not $NpcapService) {

    Write-NetworkResult `
        -Status "FAIL" `
        -Check "Npcap service" `
        -Details "Npcap service was not found"
}
elseif ($NpcapService.Status -eq "Running") {

    Write-NetworkResult `
        -Status "PASS" `
        -Check "Npcap service" `
        -Details "Running"
}
else {

    Write-NetworkResult `
        -Status "WARN" `
        -Check "Npcap service" `
        -Details "Current status: $($NpcapService.Status)"
}


# ------------------------------------------------------------
# Npcap Driver
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Npcap Driver ---" -ForegroundColor Cyan

if (Test-Path $NpcapDriverPath) {

    Write-NetworkResult `
        -Status "PASS" `
        -Check "Npcap driver" `
        -Details "npcap.sys found"

    $NpcapVersionInfo = (
        Get-Item $NpcapDriverPath
    ).VersionInfo

    $NpcapVersion = $NpcapVersionInfo.ProductVersion

    if ($NpcapVersion) {

        Write-NetworkResult `
            -Status "INFO" `
            -Check "Npcap driver version" `
            -Details $NpcapVersion
    }

    try {

        $NpcapSignature = Get-AuthenticodeSignature `
            -FilePath $NpcapDriverPath

        if ($NpcapSignature.Status -eq "Valid") {

            Write-NetworkResult `
                -Status "PASS" `
                -Check "Npcap driver signature" `
                -Details "Authenticode signature is valid"
        }
        else {

            Write-NetworkResult `
                -Status "WARN" `
                -Check "Npcap driver signature" `
                -Details "Signature status: $($NpcapSignature.Status)"
        }
    }
    catch {

        Write-NetworkResult `
            -Status "WARN" `
            -Check "Npcap driver signature" `
            -Details "Signature validation could not be completed"
    }
}
else {

    Write-NetworkResult `
        -Status "FAIL" `
        -Check "Npcap driver" `
        -Details "npcap.sys was not found"
}


# ------------------------------------------------------------
# Capture Interfaces
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Capture Interfaces ---" -ForegroundColor Cyan

$CaptureInterfaces = @()

if ($TSharkAvailable) {

    try {

        $CaptureInterfaces = @(
            & $TSharkPath -D 2>&1
        )

        if (
            $LASTEXITCODE -eq 0 -and
            $CaptureInterfaces.Count -gt 0
        ) {

            Write-NetworkResult `
                -Status "PASS" `
                -Check "TShark interface enumeration" `
                -Details "$($CaptureInterfaces.Count) capture interface(s) detected"

            Write-Host ""

            foreach ($CaptureInterfaceLine in $CaptureInterfaces) {

                $FriendlyInterface = $null

                if (
                    $CaptureInterfaceLine -match '^\s*(\d+)\.\s+.+\s+\((.+)\)\s*$'
                ) {

                    $InterfaceNumber = $Matches[1]
                    $InterfaceName = $Matches[2]

                    $FriendlyInterface = "$InterfaceNumber. $InterfaceName"
                }
                elseif (
                    $CaptureInterfaceLine -match '^\s*(\d+)\.\s+(.+?)\s*$'
                ) {

                    $InterfaceNumber = $Matches[1]
                    $InterfaceName = $Matches[2]

                    $FriendlyInterface = "$InterfaceNumber. $InterfaceName"
                }

                if ($FriendlyInterface) {
                    Write-Host "  $FriendlyInterface" -ForegroundColor DarkGray
                }
            }
        }
        else {

            Write-NetworkResult `
                -Status "FAIL" `
                -Check "TShark interface enumeration" `
                -Details "No capture interfaces were detected"
        }
    }
    catch {

        Write-NetworkResult `
            -Status "FAIL" `
            -Check "TShark interface enumeration" `
            -Details "Unable to enumerate interfaces"
    }
}
else {

    Write-NetworkResult `
        -Status "INFO" `
        -Check "TShark interface enumeration" `
        -Details "Skipped because TShark is unavailable"
}


# ------------------------------------------------------------
# Windows Physical / Virtual Adapters
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Windows Network Adapters ---" -ForegroundColor Cyan

try {

    $ActiveAdapters = @(
        Get-NetAdapter `
            -ErrorAction Stop |
            Where-Object {
                $_.Status -eq "Up"
            }
    )

    if ($ActiveAdapters.Count -gt 0) {

        Write-NetworkResult `
            -Status "PASS" `
            -Check "Active Windows adapters" `
            -Details "$($ActiveAdapters.Count) adapter(s) currently Up"
    }
    else {

        Write-NetworkResult `
            -Status "WARN" `
            -Check "Active Windows adapters" `
            -Details "No adapters currently report status Up"
    }


    $VmwareAdapters = @(
        Get-NetAdapter `
            -ErrorAction Stop |
            Where-Object {
                $_.InterfaceDescription -match "VMware"
            }
    )

    if ($VmwareAdapters.Count -gt 0) {

        Write-NetworkResult `
            -Status "PASS" `
            -Check "VMware network adapters" `
            -Details "$($VmwareAdapters.Count) VMware adapter(s) detected"
    }
    else {

        Write-NetworkResult `
            -Status "INFO" `
            -Check "VMware network adapters" `
            -Details "No VMware adapters detected"
    }
}
catch {

    Write-NetworkResult `
        -Status "WARN" `
        -Check "Windows network adapter query" `
        -Details "Get-NetAdapter query could not be completed"
}


# ------------------------------------------------------------
# Optional Controlled Capture
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Controlled Capture Test ---" -ForegroundColor Cyan

if ($PSBoundParameters.ContainsKey("CaptureInterface")) {

    if (-not $TSharkAvailable) {

        Write-NetworkResult `
            -Status "FAIL" `
            -Check "Controlled capture" `
            -Details "TShark is unavailable"
    }
    else {

        Write-NetworkResult `
            -Status "INFO" `
            -Check "Controlled capture" `
            -Details "Testing interface $CaptureInterface for up to $CaptureDuration second(s) or $PacketLimit packets"

        Write-Host ""
        Write-Host "No packet-capture file will be saved." `
            -ForegroundColor DarkGray

        Write-Host "Packet contents are suppressed from terminal output." `
            -ForegroundColor DarkGray

        Write-Host ""

        try {

            $CaptureOutput = @(
                & $TSharkPath `
                    -i $CaptureInterface `
                    -a "duration:$CaptureDuration" `
                    -c $PacketLimit `
                    -q `
                    2>&1
            )

            $CaptureExitCode = $LASTEXITCODE

            if ($CaptureExitCode -eq 0) {

                Write-NetworkResult `
                    -Status "PASS" `
                    -Check "Controlled capture" `
                    -Details "TShark capture completed successfully"
            }
            else {

                Write-NetworkResult `
                    -Status "WARN" `
                    -Check "Controlled capture" `
                    -Details "TShark returned exit code $CaptureExitCode"
            }

            if ($CaptureOutput.Count -gt 0) {

                Write-Host ""

                foreach ($CaptureStatusLine in $CaptureOutput) {

                    if (
                        $CaptureStatusLine -match "packet" -or
                        $CaptureStatusLine -match "Capturing"
                    ) {
                        Write-Host "  $CaptureStatusLine" `
                            -ForegroundColor DarkGray
                    }
                }
            }
        }
        catch {

            Write-NetworkResult `
                -Status "FAIL" `
                -Check "Controlled capture" `
                -Details "Capture attempt generated an exception"
        }
    }
}
else {

    Write-NetworkResult `
        -Status "INFO" `
        -Check "Controlled capture" `
        -Details "Not requested. Supply -CaptureInterface to perform a live test."
}


# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Network Analysis Validation Summary" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

Write-Host "PASS : $PassCount" -ForegroundColor Green
Write-Host "WARN : $WarnCount" -ForegroundColor Yellow
Write-Host "FAIL : $FailCount" -ForegroundColor Red
Write-Host "INFO : $InfoCount" -ForegroundColor Cyan
Write-Host ""

if ($FailCount -gt 0) {

    Write-Host "Overall Result: NETWORK ANALYSIS NOT READY" `
        -ForegroundColor Red
}
elseif ($WarnCount -gt 0) {

    Write-Host "Overall Result: REVIEW WARNINGS" `
        -ForegroundColor Yellow
}
else {

    Write-Host "Overall Result: NETWORK ANALYSIS READY" `
        -ForegroundColor Green
}

Write-Host ""
Write-Host "Live packet capture is intentionally optional." `
    -ForegroundColor DarkGray

Write-Host "Only capture traffic where inspection is authorized." `
    -ForegroundColor DarkGray

Write-Host ""