<#
.SYNOPSIS
    Validates the Microsoft Sysinternals toolkit used by the
    Windows 11 Cybersecurity Workstation project.

.DESCRIPTION
    Performs read-only checks for:

    - Process Explorer
    - Process Monitor
    - Autoruns
    - TCPView
    - Sigcheck
    - Strings

    For each utility, the script checks:

    - Expected executable exists
    - File version can be identified
    - Authenticode signature is valid
    - Signer appears to be Microsoft

    The script does NOT:

    - Launch the utilities
    - Accept Sysinternals EULAs
    - Modify the registry
    - Modify services
    - Terminate processes or network connections
    - Disable startup entries
    - Upload files or hashes to external services

.EXAMPLE
    .\Test-SysinternalsToolkit.ps1

.NOTES
    Project: Windows 11 Cybersecurity Workstation
    Author: QuantumByt3
#>

[CmdletBinding()]
param()


# ------------------------------------------------------------
# State
# ------------------------------------------------------------

$PassCount = 0
$WarnCount = 0
$FailCount = 0
$InfoCount = 0

$SysinternalsRoot = Join-Path $HOME "Tools\Sysinternals"


# ------------------------------------------------------------
# Tool Manifest
# ------------------------------------------------------------

$SysinternalsTools = @(
    [PSCustomObject]@{
        Name         = "Process Explorer"
        Executable   = "procexp64.exe"
        RelativePath = "ProcessExplorer\procexp64.exe"
    },
    [PSCustomObject]@{
        Name         = "Process Monitor"
        Executable   = "Procmon64.exe"
        RelativePath = "ProcessMonitor\Procmon64.exe"
    },
    [PSCustomObject]@{
        Name         = "Autoruns"
        Executable   = "Autoruns64.exe"
        RelativePath = "Autoruns\Autoruns64.exe"
    },
    [PSCustomObject]@{
        Name         = "TCPView"
        Executable   = "tcpview64.exe"
        RelativePath = "TCPView\tcpview64.exe"
    },
    [PSCustomObject]@{
        Name         = "Sigcheck"
        Executable   = "sigcheck64.exe"
        RelativePath = "Sigcheck\sigcheck64.exe"
    },
    [PSCustomObject]@{
        Name         = "Strings"
        Executable   = "strings64.exe"
        RelativePath = "Strings\strings64.exe"
    }
)


# ------------------------------------------------------------
# Output Helper
# ------------------------------------------------------------

function Write-SysinternalsResult {
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
Write-Host " Microsoft Sysinternals Toolkit Validation" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

Write-SysinternalsResult `
    -Status "INFO" `
    -Check "Sysinternals root" `
    -Details '$HOME\Tools\Sysinternals'


# ------------------------------------------------------------
# Root Directory
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Toolkit Directory ---" -ForegroundColor Cyan

if (Test-Path $SysinternalsRoot) {

    Write-SysinternalsResult `
        -Status "PASS" `
        -Check "Sysinternals directory" `
        -Details "Directory exists"
}
else {

    Write-SysinternalsResult `
        -Status "FAIL" `
        -Check "Sysinternals directory" `
        -Details "Expected directory was not found"
}


# ------------------------------------------------------------
# Validate Each Utility
# ------------------------------------------------------------

foreach ($ToolEntry in $SysinternalsTools) {

    Write-Host ""
    Write-Host "--- $($ToolEntry.Name) ---" -ForegroundColor Cyan

    $ToolPath = Join-Path `
        $SysinternalsRoot `
        $ToolEntry.RelativePath


    # --------------------------------------------------------
    # Existence
    # --------------------------------------------------------

    if (-not (Test-Path $ToolPath -PathType Leaf)) {

        Write-SysinternalsResult `
            -Status "FAIL" `
            -Check "$($ToolEntry.Name) executable" `
            -Details "Not found"

        continue
    }

    Write-SysinternalsResult `
        -Status "PASS" `
        -Check "$($ToolEntry.Name) executable" `
        -Details $ToolEntry.Executable


    # --------------------------------------------------------
    # Version
    # --------------------------------------------------------

    try {

        $ToolFile = Get-Item `
            -LiteralPath $ToolPath `
            -ErrorAction Stop

        $ToolVersion = $ToolFile.VersionInfo.ProductVersion

        if (-not $ToolVersion) {
            $ToolVersion = $ToolFile.VersionInfo.FileVersion
        }

        if ($ToolVersion) {

            Write-SysinternalsResult `
                -Status "INFO" `
                -Check "$($ToolEntry.Name) version" `
                -Details $ToolVersion
        }
        else {

            Write-SysinternalsResult `
                -Status "WARN" `
                -Check "$($ToolEntry.Name) version" `
                -Details "Version metadata was not available"
        }
    }
    catch {

        Write-SysinternalsResult `
            -Status "WARN" `
            -Check "$($ToolEntry.Name) version" `
            -Details "Unable to read executable metadata"
    }


    # --------------------------------------------------------
    # Authenticode Signature
    # --------------------------------------------------------

    try {

        $Signature = Get-AuthenticodeSignature `
            -FilePath $ToolPath `
            -ErrorAction Stop

        if ($Signature.Status -eq "Valid") {

            Write-SysinternalsResult `
                -Status "PASS" `
                -Check "$($ToolEntry.Name) signature" `
                -Details "Authenticode status Valid"
        }
        else {

            Write-SysinternalsResult `
                -Status "FAIL" `
                -Check "$($ToolEntry.Name) signature" `
                -Details "Status: $($Signature.Status)"

            continue
        }


        # ----------------------------------------------------
        # Signer Identity
        # ----------------------------------------------------

        $SignerSubject = $null

        if ($Signature.SignerCertificate) {
            $SignerSubject = $Signature.SignerCertificate.Subject
        }

        if (
            $SignerSubject -and
            $SignerSubject -match "Microsoft"
        ) {

            Write-SysinternalsResult `
                -Status "PASS" `
                -Check "$($ToolEntry.Name) signer" `
                -Details "Microsoft signer detected"
        }
        elseif ($SignerSubject) {

            Write-SysinternalsResult `
                -Status "WARN" `
                -Check "$($ToolEntry.Name) signer" `
                -Details "Valid signature but expected Microsoft name was not detected"
        }
        else {

            Write-SysinternalsResult `
                -Status "WARN" `
                -Check "$($ToolEntry.Name) signer" `
                -Details "Signer certificate information unavailable"
        }
    }
    catch {

        Write-SysinternalsResult `
            -Status "FAIL" `
            -Check "$($ToolEntry.Name) signature" `
            -Details "Authenticode validation could not be completed"
    }
}


# ------------------------------------------------------------
# Toolkit Completeness
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Toolkit Completeness ---" -ForegroundColor Cyan

$ExpectedToolCount = $SysinternalsTools.Count

$PresentToolCount = @(
    foreach ($ToolEntry in $SysinternalsTools) {

        $CandidatePath = Join-Path `
            $SysinternalsRoot `
            $ToolEntry.RelativePath

        if (Test-Path $CandidatePath -PathType Leaf) {
            $ToolEntry
        }
    }
).Count

if ($PresentToolCount -eq $ExpectedToolCount) {

    Write-SysinternalsResult `
        -Status "PASS" `
        -Check "Toolkit completeness" `
        -Details "$PresentToolCount of $ExpectedToolCount expected utilities found"
}
else {

    Write-SysinternalsResult `
        -Status "FAIL" `
        -Check "Toolkit completeness" `
        -Details "$PresentToolCount of $ExpectedToolCount expected utilities found"
}


# ------------------------------------------------------------
# Known-Good Windows Validation Target
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Known-Good Validation Target ---" -ForegroundColor Cyan

$KnownGoodWindowsFile = Join-Path `
    $env:WINDIR `
    "System32\notepad.exe"

if (Test-Path $KnownGoodWindowsFile) {

    Write-SysinternalsResult `
        -Status "PASS" `
        -Check "Known-good Windows binary" `
        -Details "notepad.exe available for manual Sigcheck/Strings testing"
}
else {

    Write-SysinternalsResult `
        -Status "WARN" `
        -Check "Known-good Windows binary" `
        -Details "Expected notepad.exe path was not found"
}


# ------------------------------------------------------------
# External Reputation Services
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- External Reputation Services ---" -ForegroundColor Cyan

Write-SysinternalsResult `
    -Status "INFO" `
    -Check "VirusTotal integration" `
    -Details "Not queried by this validation script"

Write-SysinternalsResult `
    -Status "INFO" `
    -Check "External uploads" `
    -Details "No files or hashes are transmitted"


# ------------------------------------------------------------
# Privilege State
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- PowerShell Privilege ---" -ForegroundColor Cyan

try {

    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()

    $CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new(
        $CurrentIdentity
    )

    $IsAdministrator = $CurrentPrincipal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )

    if ($IsAdministrator) {

        Write-SysinternalsResult `
            -Status "INFO" `
            -Check "PowerShell privilege" `
            -Details "Running as Administrator; elevation is not required for this script"
    }
    else {

        Write-SysinternalsResult `
            -Status "PASS" `
            -Check "PowerShell privilege" `
            -Details "Running as standard user"
    }
}
catch {

    Write-SysinternalsResult `
        -Status "WARN" `
        -Check "PowerShell privilege" `
        -Details "Unable to determine privilege state"
}


# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Sysinternals Validation Summary" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

Write-Host "PASS : $PassCount" -ForegroundColor Green
Write-Host "WARN : $WarnCount" -ForegroundColor Yellow
Write-Host "FAIL : $FailCount" -ForegroundColor Red
Write-Host "INFO : $InfoCount" -ForegroundColor Cyan
Write-Host ""

if ($FailCount -gt 0) {

    Write-Host "Overall Result: SYSINTERNALS TOOLKIT NOT READY" `
        -ForegroundColor Red
}
elseif ($WarnCount -gt 0) {

    Write-Host "Overall Result: REVIEW WARNINGS" `
        -ForegroundColor Yellow
}
else {

    Write-Host "Overall Result: SYSINTERNALS TOOLKIT READY" `
        -ForegroundColor Green
}

Write-Host ""
Write-Host "This validation is read-only." `
    -ForegroundColor DarkGray

Write-Host "No Sysinternals utilities were launched and no external reputation services were queried." `
    -ForegroundColor DarkGray

Write-Host ""