<#
.SYNOPSIS
    Performs a read-only Windows 11 cybersecurity workstation
    security-baseline assessment.

.DESCRIPTION
    Checks Microsoft Defender, Windows Firewall, TPM, Secure Boot,
    BitLocker, and the current PowerShell privilege level.

    This script is designed to report configuration state without
    disabling or modifying Windows security controls.

.NOTES
    Project: Windows 11 Cybersecurity Workstation
    Author: QuantumByt3

    Some checks may require an elevated PowerShell session.
#>

[CmdletBinding()]
param()

$PassCount = 0
$WarnCount = 0
$FailCount = 0
$InfoCount = 0
$AdminChecksPending = $false

function Write-BaselineResult {
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


Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Windows 11 Cybersecurity Security Baseline" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""


# ------------------------------------------------------------
# Administrative Session
# ------------------------------------------------------------

$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()

$CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new(
    $CurrentIdentity
)

$IsAdmin = $CurrentPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if ($IsAdmin) {
    Write-BaselineResult `
        -Status "INFO" `
        -Check "PowerShell privilege level" `
        -Details "Running as Administrator"
}
else {
    Write-BaselineResult `
        -Status "PASS" `
        -Check "Routine PowerShell privilege level" `
        -Details "Running as a standard user"
}


# ------------------------------------------------------------
# Microsoft Defender
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Microsoft Defender ---" -ForegroundColor Cyan

try {
    $Defender = Get-MpComputerStatus -ErrorAction Stop

    if ($Defender.AntivirusEnabled) {
        Write-BaselineResult -Status "PASS" -Check "Microsoft Defender Antivirus"
    }
    else {
        Write-BaselineResult -Status "FAIL" -Check "Microsoft Defender Antivirus" -Details "Disabled"
    }

    if ($Defender.RealTimeProtectionEnabled) {
        Write-BaselineResult -Status "PASS" -Check "Defender Real-Time Protection"
    }
    else {
        Write-BaselineResult -Status "FAIL" -Check "Defender Real-Time Protection" -Details "Disabled"
    }

    if ($Defender.BehaviorMonitorEnabled) {
        Write-BaselineResult -Status "PASS" -Check "Defender Behavior Monitoring"
    }
    else {
        Write-BaselineResult -Status "WARN" -Check "Defender Behavior Monitoring" -Details "Disabled"
    }

    if ($Defender.IoavProtectionEnabled) {
        Write-BaselineResult -Status "PASS" -Check "Downloaded File Protection"
    }
    else {
        Write-BaselineResult -Status "WARN" -Check "Downloaded File Protection" -Details "Disabled"
    }

    if ($Defender.NISEnabled) {
        Write-BaselineResult -Status "PASS" -Check "Network Inspection System"
    }
    else {
        Write-BaselineResult -Status "WARN" -Check "Network Inspection System" -Details "Disabled"
    }
}
catch {
    Write-BaselineResult `
        -Status "WARN" `
        -Check "Microsoft Defender" `
        -Details "Status could not be queried"
}


# ------------------------------------------------------------
# Windows Firewall
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Windows Firewall ---" -ForegroundColor Cyan

try {
    $FirewallProfiles = Get-NetFirewallProfile -ErrorAction Stop

    foreach ($FirewallProfile in $FirewallProfiles) {
    if ($FirewallProfile.Enabled) {
        Write-BaselineResult `
            -Status "PASS" `
            -Check "Firewall - $($FirewallProfile.Name)"
    }
    else {
        Write-BaselineResult `
            -Status "FAIL" `
            -Check "Firewall - $($FirewallProfile.Name)" `
            -Details "Disabled"
    }
}
}
catch {
    Write-BaselineResult `
        -Status "WARN" `
        -Check "Windows Firewall" `
        -Details "Firewall profiles could not be queried"
}


# ------------------------------------------------------------
# Trusted Platform Module
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Trusted Platform Module ---" -ForegroundColor Cyan

if (-not $IsAdmin) {
    $AdminChecksPending = $true

    Write-BaselineResult `
        -Status "INFO" `
        -Check "TPM" `
        -Details "Run as Administrator for a reliable TPM assessment"
}
else {
    try {
        $Tpm = Get-Tpm -ErrorAction Stop

        if ($Tpm.TpmPresent) {
            Write-BaselineResult -Status "PASS" -Check "TPM Present"
        }
        else {
            Write-BaselineResult -Status "FAIL" -Check "TPM Present" -Details "TPM not detected"
        }

        if ($Tpm.TpmReady) {
            Write-BaselineResult -Status "PASS" -Check "TPM Ready"
        }
        else {
            Write-BaselineResult -Status "WARN" -Check "TPM Ready" -Details "TPM is not ready"
        }

        if ($Tpm.TpmEnabled) {
            Write-BaselineResult -Status "PASS" -Check "TPM Enabled"
        }
        else {
            Write-BaselineResult -Status "FAIL" -Check "TPM Enabled" -Details "TPM is disabled"
        }

        if ($Tpm.TpmActivated) {
            Write-BaselineResult -Status "PASS" -Check "TPM Activated"
        }
        else {
            Write-BaselineResult -Status "WARN" -Check "TPM Activated" -Details "TPM is not activated"
        }
    }
    catch {
        Write-BaselineResult `
            -Status "WARN" `
            -Check "TPM" `
            -Details "TPM status could not be queried"
    }
}


# ------------------------------------------------------------
# Secure Boot
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Secure Boot ---" -ForegroundColor Cyan

if (-not $IsAdmin) {
    $AdminChecksPending = $true

    Write-BaselineResult `
        -Status "INFO" `
        -Check "Secure Boot" `
        -Details "Run as Administrator for a reliable Secure Boot assessment"
}
else {
    try {
        $SecureBoot = Confirm-SecureBootUEFI -ErrorAction Stop

        if ($SecureBoot) {
            Write-BaselineResult -Status "PASS" -Check "Secure Boot"
        }
        else {
            Write-BaselineResult `
                -Status "FAIL" `
                -Check "Secure Boot" `
                -Details "Disabled"
        }
    }
    catch {
        Write-BaselineResult `
            -Status "WARN" `
            -Check "Secure Boot" `
            -Details "Status could not be queried or the system is not using UEFI"
    }
}


# ------------------------------------------------------------
# BitLocker
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- BitLocker ---" -ForegroundColor Cyan

if (-not $IsAdmin) {
    $AdminChecksPending = $true

    Write-BaselineResult `
        -Status "INFO" `
        -Check "BitLocker" `
        -Details "Run as Administrator for a complete BitLocker assessment"
}
else {
    try {
        $SystemDrive = $env:SystemDrive

        $BitLocker = Get-BitLockerVolume `
            -MountPoint $SystemDrive `
            -ErrorAction Stop

        if ($BitLocker.ProtectionStatus -eq "On") {
            Write-BaselineResult `
                -Status "PASS" `
                -Check "BitLocker Protection" `
                -Details "Protection On"
        }
        else {
            Write-BaselineResult `
                -Status "FAIL" `
                -Check "BitLocker Protection" `
                -Details "Protection is not On"
        }

        if ($BitLocker.EncryptionPercentage -eq 100) {
            Write-BaselineResult `
                -Status "PASS" `
                -Check "System Drive Encryption" `
                -Details "100% encrypted"
        }
        else {
            Write-BaselineResult `
                -Status "WARN" `
                -Check "System Drive Encryption" `
                -Details "$($BitLocker.EncryptionPercentage)% encrypted"
        }

        Write-BaselineResult `
            -Status "INFO" `
            -Check "BitLocker Encryption Method" `
            -Details "$($BitLocker.EncryptionMethod)"
    }
    catch {
        Write-BaselineResult `
            -Status "WARN" `
            -Check "BitLocker" `
            -Details "BitLocker status could not be queried"
    }
}


# ------------------------------------------------------------
# Windows Update
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Windows Update ---" -ForegroundColor Cyan

Write-BaselineResult `
    -Status "INFO" `
    -Check "Windows Update" `
    -Details "Confirm 'You're up to date' in Settings > Windows Update"


# ------------------------------------------------------------
# System Protection
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- System Protection ---" -ForegroundColor Cyan

Write-BaselineResult `
    -Status "INFO" `
    -Check "System Protection" `
    -Details "Verify protection is enabled for the Windows system drive"


# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

Write-Host ""
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host " Baseline Summary" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

Write-Host "PASS : $PassCount" -ForegroundColor Green
Write-Host "WARN : $WarnCount" -ForegroundColor Yellow
Write-Host "FAIL : $FailCount" -ForegroundColor Red
Write-Host "INFO : $InfoCount" -ForegroundColor Cyan
Write-Host ""

if ($FailCount -gt 0) {
    Write-Host "Overall Result: ATTENTION REQUIRED" -ForegroundColor Red
}
elseif ($WarnCount -gt 0) {
    Write-Host "Overall Result: REVIEW WARNINGS" -ForegroundColor Yellow
}
elseif ($AdminChecksPending) {
    Write-Host "Overall Result: PARTIAL - ELEVATED CHECKS PENDING" -ForegroundColor Yellow
}
else {
    Write-Host "Overall Result: BASELINE HEALTHY" -ForegroundColor Green
}

Write-Host ""
Write-Host "This script performs read-only security checks." -ForegroundColor DarkGray
Write-Host "It does not disable or modify Windows security controls." -ForegroundColor DarkGray
Write-Host ""