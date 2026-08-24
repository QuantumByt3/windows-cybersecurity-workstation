<#
.SYNOPSIS
    Performs a safety and sanitization review of the
    Windows 11 Cybersecurity Workstation repository.

.DESCRIPTION
    Performs read-only checks for potentially sensitive material before
    files are committed or pushed to a public GitHub repository.

    Checks include:

    - Private-key signatures
    - Common token formats
    - BitLocker-style recovery passwords
    - Credential-sensitive file extensions
    - Packet captures
    - Archives and binaries requiring review
    - User-specific Windows paths
    - Email addresses
    - IPv4 addresses
    - MAC addresses
    - Sanitized-image review reminders
    - Required repository safety files

    The scanner reports file locations and categories without printing
    detected secret values.

    This script does NOT modify, delete, stage, commit, or upload files.

.NOTES
    Project: Windows 11 Cybersecurity Workstation
    Author: QuantumByt3
#>

[CmdletBinding()]
param()

$PassCount = 0
$WarnCount = 0
$FailCount = 0
$InfoCount = 0

$RepositoryRoot = Split-Path -Parent $PSScriptRoot

$LocalOnlyDirectories = @(
    (Join-Path $RepositoryRoot "private"),
    (Join-Path $RepositoryRoot "assets\raw-screenshots"),
    (Join-Path $RepositoryRoot ".git")
)

$ScannerPath = $PSCommandPath


# ------------------------------------------------------------
# Output Helper
# ------------------------------------------------------------

function Write-SafetyResult {
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
# Relative Path Helper
# ------------------------------------------------------------

function Get-RepositoryRelativePath {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    return [System.IO.Path]::GetRelativePath(
        $RepositoryRoot,
        $Path
    )
}


# ------------------------------------------------------------
# Determine Whether Path Is Local-Only
# ------------------------------------------------------------

function Test-LocalOnlyPath {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    foreach ($Directory in $LocalOnlyDirectories) {

        $NormalizedDirectory = $Directory.TrimEnd(
            [char[]]@(
                [System.IO.Path]::DirectorySeparatorChar,
                [System.IO.Path]::AltDirectorySeparatorChar
            )
        )

        $DirectoryPrefix = $NormalizedDirectory +
            [System.IO.Path]::DirectorySeparatorChar

        if (
            $Path.Equals(
                $NormalizedDirectory,
                [System.StringComparison]::OrdinalIgnoreCase
            ) -or
            $Path.StartsWith(
                $DirectoryPrefix,
                [System.StringComparison]::OrdinalIgnoreCase
            )
        ) {
            return $true
        }
    }

    return $false
}


# ------------------------------------------------------------
# Header
# ------------------------------------------------------------

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Repository Safety and Sanitization Scanner" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

Write-SafetyResult `
    -Status "INFO" `
    -Check "Repository root" `
    -Details $RepositoryRoot


# ------------------------------------------------------------
# Required Safety Files
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Repository Safety Files ---" -ForegroundColor Cyan

$RequiredFiles = @(
    ".gitignore",
    "SECURITY.md",
    "docs\sanitization-guide.md"
)

foreach ($RequiredFile in $RequiredFiles) {

    $RequiredPath = Join-Path $RepositoryRoot $RequiredFile

    if (Test-Path $RequiredPath) {

        Write-SafetyResult `
            -Status "PASS" `
            -Check $RequiredFile
    }
    else {

        Write-SafetyResult `
            -Status "FAIL" `
            -Check $RequiredFile `
            -Details "Required repository safety file is missing"
    }
}


# ------------------------------------------------------------
# Verify Local-Only Directories
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Local-Only Directories ---" -ForegroundColor Cyan

$ExpectedLocalOnly = @(
    "private",
    "assets\raw-screenshots"
)

foreach ($Directory in $ExpectedLocalOnly) {

    $DirectoryPath = Join-Path $RepositoryRoot $Directory

    if (Test-Path $DirectoryPath) {

        Write-SafetyResult `
            -Status "PASS" `
            -Check $Directory `
            -Details "Local-only directory exists"
    }
    else {

        Write-SafetyResult `
            -Status "INFO" `
            -Check $Directory `
            -Details "Directory does not currently exist"
    }
}


# ------------------------------------------------------------
# Check .gitignore Protection
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- .gitignore Guardrails ---" -ForegroundColor Cyan

$GitIgnorePath = Join-Path $RepositoryRoot ".gitignore"

if (Test-Path $GitIgnorePath) {

    $GitIgnoreContent = Get-Content $GitIgnorePath

    $RequiredIgnoreRules = @(
        "private/",
        "assets/raw-screenshots/",
        ".ssh/",
        "*.pem",
        "*.pfx",
        "*.p12",
        "*.ovpn",
        "*.pcap",
        "*.pcapng"
    )

    foreach ($Rule in $RequiredIgnoreRules) {

        if ($GitIgnoreContent -contains $Rule) {

            Write-SafetyResult `
                -Status "PASS" `
                -Check ".gitignore rule" `
                -Details $Rule
        }
        else {

            Write-SafetyResult `
                -Status "WARN" `
                -Check ".gitignore rule" `
                -Details "Missing expected rule: $Rule"
        }
    }
}


# ------------------------------------------------------------
# Collect Public-Facing Files
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Repository File Inventory ---" -ForegroundColor Cyan

$AllFiles = Get-ChildItem `
    -Path $RepositoryRoot `
    -Recurse `
    -File `
    -Force `
    -ErrorAction SilentlyContinue

$PublicFiles = @(
    $AllFiles |
        Where-Object {
            -not (Test-LocalOnlyPath $_.FullName)
        }
)

Write-SafetyResult `
    -Status "INFO" `
    -Check "Public-facing files scanned" `
    -Details "$($PublicFiles.Count)"


# ------------------------------------------------------------
# Risky File Types
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Risky File Types ---" -ForegroundColor Cyan

$ForbiddenExtensions = @(
    ".pem",
    ".pfx",
    ".p12",
    ".key",
    ".ovpn",
    ".pcap",
    ".pcapng",
    ".cap",
    ".etl",
    ".dmp",

    # Forensic / Windows artifacts
    ".pml",
    ".evtx",
    ".reg",
    ".hiv",
    ".raw",
    ".mem",

    # Virtual machine disks and state
    ".vmdk",
    ".vhd",
    ".vhdx",
    ".qcow2",
    ".vmem",
    ".vmss",
    ".vmsn",
    ".nvram"
)

$ReviewExtensions = @(
    ".exe",
    ".dll",
    ".sys",
    ".msi",
    ".zip",
    ".7z",
    ".rar"
)

$ForbiddenFilesFound = $false

foreach ($File in $PublicFiles) {

    $Extension = $File.Extension.ToLowerInvariant()
    $RelativePath = Get-RepositoryRelativePath $File.FullName

    if ($ForbiddenExtensions -contains $Extension) {

        $ForbiddenFilesFound = $true

        Write-SafetyResult `
            -Status "FAIL" `
            -Check "Sensitive file type" `
            -Details $RelativePath
    }

    if ($ReviewExtensions -contains $Extension) {

        Write-SafetyResult `
            -Status "WARN" `
            -Check "Binary/archive requires review" `
            -Details $RelativePath
    }

    if (
        $File.Name -match '^id_(rsa|dsa|ecdsa|ed25519)$'
    ) {

        $ForbiddenFilesFound = $true

        Write-SafetyResult `
            -Status "FAIL" `
            -Check "Possible SSH private key file" `
            -Details $RelativePath
    }
}

if (-not $ForbiddenFilesFound) {

    Write-SafetyResult `
        -Status "PASS" `
        -Check "Sensitive file extensions" `
        -Details "No prohibited public-facing file types detected"
}


# ------------------------------------------------------------
# Text Files Eligible for Content Scanning
# ------------------------------------------------------------

$TextExtensions = @(
    ".md",
    ".ps1",
    ".psm1",
    ".psd1",
    ".txt",
    ".json",
    ".yaml",
    ".yml",
    ".xml",
    ".csv",
    ".ini",
    ".config"
)

$TextFiles = @(
    $PublicFiles |
        Where-Object {
            (
                $TextExtensions -contains $_.Extension.ToLowerInvariant()
            ) -or (
                $_.Name -eq ".gitignore"
            ) -or (
                $_.Name -eq "LICENSE"
            )
        } |
        Where-Object {
            $_.FullName -ne $ScannerPath
        }
)


# ------------------------------------------------------------
# High-Risk Secret Patterns
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Secret Pattern Scan ---" -ForegroundColor Cyan

$SecretPatterns = @(
    @{
        Name = "OpenSSH private key"
        Regex = '-----BEGIN OPENSSH PRIVATE KEY-----'
    },
    @{
        Name = "RSA private key"
        Regex = '-----BEGIN RSA PRIVATE KEY-----'
    },
    @{
        Name = "EC private key"
        Regex = '-----BEGIN EC PRIVATE KEY-----'
    },
    @{
        Name = "Generic private key"
        Regex = '-----BEGIN PRIVATE KEY-----'
    },
    @{
        Name = "GitHub classic token"
        Regex = '\bghp_[A-Za-z0-9]{30,}\b'
    },
    @{
        Name = "GitHub fine-grained token"
        Regex = '\bgithub_pat_[A-Za-z0-9_]{20,}\b'
    },
    @{
        Name = "AWS access key ID"
        Regex = '\bAKIA[0-9A-Z]{16}\b'
    },
    @{
        Name = "Bearer authorization value"
        Regex = '(?i)\bAuthorization\s*:\s*Bearer\s+[A-Za-z0-9._~+/\-=]{16,}'
    },
    @{
        Name = "BitLocker-style recovery password"
        Regex = '\b\d{6}(?:-\d{6}){7}\b'
    }
)

$SecretFindings = 0

foreach ($File in $TextFiles) {

    $RelativePath = Get-RepositoryRelativePath $File.FullName

    $LineNumber = 0

    foreach ($Line in Get-Content $File.FullName -ErrorAction SilentlyContinue) {

        $LineNumber++

        foreach ($Pattern in $SecretPatterns) {

            if ($Line -match $Pattern.Regex) {

                $SecretFindings++

                Write-SafetyResult `
                    -Status "FAIL" `
                    -Check $Pattern.Name `
                    -Details "$RelativePath : line $LineNumber"
            }
        }
    }
}

if ($SecretFindings -eq 0) {

    Write-SafetyResult `
        -Status "PASS" `
        -Check "High-risk secret patterns" `
        -Details "No matches detected"
}


# ------------------------------------------------------------
# User-Specific Windows Paths
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Windows User Path Review ---" -ForegroundColor Cyan

$UserPathPattern = '(?i)C:\\Users\\([^\\<>]+)\\'

$AllowedPathNames = @(
    "ActualUsername"
)

$UserPathFindings = 0

foreach ($File in $TextFiles) {

    $RelativePath = Get-RepositoryRelativePath $File.FullName
    $LineNumber = 0

    foreach ($Line in Get-Content $File.FullName -ErrorAction SilentlyContinue) {

        $LineNumber++

        $MatchesFound = [regex]::Matches(
            $Line,
            $UserPathPattern
        )

        foreach ($Match in $MatchesFound) {

            $PathUser = $Match.Groups[1].Value

            if ($AllowedPathNames -contains $PathUser) {
                continue
            }

            $UserPathFindings++

            Write-SafetyResult `
                -Status "WARN" `
                -Check "User-specific Windows path" `
                -Details "$RelativePath : line $LineNumber"
        }
    }
}

if ($UserPathFindings -eq 0) {

    Write-SafetyResult `
        -Status "PASS" `
        -Check "Windows user paths" `
        -Details "No unexpected literal user-profile paths detected"
}


# ------------------------------------------------------------
# Current Windows Username
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Local Username Review ---" -ForegroundColor Cyan

$CurrentUsername = $env:USERNAME

$UsernameFindings = 0

if ($CurrentUsername) {

    foreach ($File in $TextFiles) {

        $RelativePath = Get-RepositoryRelativePath $File.FullName
        $LineNumber = 0

        foreach ($Line in Get-Content $File.FullName -ErrorAction SilentlyContinue) {

            $LineNumber++

            if (
                $Line.IndexOf(
                    $CurrentUsername,
                    [System.StringComparison]::OrdinalIgnoreCase
                ) -ge 0
            ) {

                $UsernameFindings++

                Write-SafetyResult `
                    -Status "WARN" `
                    -Check "Current Windows username detected" `
                    -Details "$RelativePath : line $LineNumber"
            }
        }
    }
}

if ($UsernameFindings -eq 0) {

    Write-SafetyResult `
        -Status "PASS" `
        -Check "Current Windows username" `
        -Details "No literal local username detected"
}


# ------------------------------------------------------------
# Email Address Review
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Email Address Review ---" -ForegroundColor Cyan

$EmailPattern = '\b[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}\b'

$AllowedEmailLikeValues = @(
    "git@github.com"
)

$EmailFindings = 0

foreach ($File in $TextFiles) {

    $RelativePath = Get-RepositoryRelativePath $File.FullName
    $LineNumber = 0

    foreach ($Line in Get-Content $File.FullName -ErrorAction SilentlyContinue) {

        $LineNumber++

        $EmailMatches = [regex]::Matches(
            $Line,
            $EmailPattern,
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        )

        foreach ($EmailMatch in $EmailMatches) {

            $Email = $EmailMatch.Value

if (
    $Email -match '(?i)@example\.com$'
) {
    continue
}

if (
    $AllowedEmailLikeValues -contains $Email
) {
    continue
}

            $EmailFindings++

            Write-SafetyResult `
                -Status "WARN" `
                -Check "Email address requires review" `
                -Details "$RelativePath : line $LineNumber"
        }
    }
}

if ($EmailFindings -eq 0) {

    Write-SafetyResult `
        -Status "PASS" `
        -Check "Email addresses" `
        -Details "No non-placeholder email addresses detected"
}


# ------------------------------------------------------------
# IPv4 Address Review
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- IPv4 Address Review ---" -ForegroundColor Cyan

$IPv4Pattern = '\b(?:\d{1,3}\.){3}\d{1,3}\b'

$IPv4Findings = 0

foreach ($File in $TextFiles) {

    $RelativePath = Get-RepositoryRelativePath $File.FullName
    $LineNumber = 0

    foreach ($Line in Get-Content $File.FullName -ErrorAction SilentlyContinue) {

        $LineNumber++

        $IPMatches = [regex]::Matches(
            $Line,
            $IPv4Pattern
        )

        foreach ($IPMatch in $IPMatches) {

            $IPAddress = $IPMatch.Value

            $AllowedAddress = (
                $IPAddress -eq "127.0.0.1" -or
                $IPAddress -eq "0.0.0.0" -or
                $IPAddress -like "192.0.2.*" -or
                $IPAddress -like "198.51.100.*" -or
                $IPAddress -like "203.0.113.*"
            )

            if ($AllowedAddress) {
                continue
            }

            $IPv4Findings++

            Write-SafetyResult `
                -Status "WARN" `
                -Check "IPv4 address requires review" `
                -Details "$RelativePath : line $LineNumber"
        }
    }
}

if ($IPv4Findings -eq 0) {

    Write-SafetyResult `
        -Status "PASS" `
        -Check "IPv4 addresses" `
        -Details "Only approved documentation/loopback addresses detected"
}


# ------------------------------------------------------------
# MAC Address Review
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- MAC Address Review ---" -ForegroundColor Cyan

$MacPattern = '\b(?:[0-9A-F]{2}[:-]){5}[0-9A-F]{2}\b'

$MacFindings = 0

foreach ($File in $TextFiles) {

    $RelativePath = Get-RepositoryRelativePath $File.FullName
    $LineNumber = 0

    foreach ($Line in Get-Content $File.FullName -ErrorAction SilentlyContinue) {

        $LineNumber++

        if (
            $Line -match $MacPattern
        ) {

            $MacFindings++

            Write-SafetyResult `
                -Status "WARN" `
                -Check "MAC address requires review" `
                -Details "$RelativePath : line $LineNumber"
        }
    }
}

if ($MacFindings -eq 0) {

    Write-SafetyResult `
        -Status "PASS" `
        -Check "MAC addresses" `
        -Details "No MAC-address patterns detected"
}


# ------------------------------------------------------------
# Sanitized Image Review
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Sanitized Image Review ---" -ForegroundColor Cyan

$SanitizedImageDirectory = Join-Path `
    $RepositoryRoot `
    "assets\sanitized-images"

$ImageExtensions = @(
    ".png",
    ".jpg",
    ".jpeg",
    ".webp",
    ".gif"
)

$SanitizedImages = @()

if (Test-Path $SanitizedImageDirectory) {

    $SanitizedImages = @(
        Get-ChildItem `
            $SanitizedImageDirectory `
            -File `
            -Recurse `
            -ErrorAction SilentlyContinue |
            Where-Object {
                $ImageExtensions -contains $_.Extension.ToLowerInvariant()
            }
    )
}

if ($SanitizedImages.Count -eq 0) {

    Write-SafetyResult `
        -Status "PASS" `
        -Check "Sanitized images" `
        -Details "No public images currently require review"
}
else {

    Write-SafetyResult `
        -Status "WARN" `
        -Check "Sanitized images" `
        -Details "$($SanitizedImages.Count) image(s) require manual visual privacy review before publication"
}


# ------------------------------------------------------------
# Git State
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Git State ---" -ForegroundColor Cyan

$GitAvailable = [bool](
    Get-Command git -ErrorAction SilentlyContinue
)

$IsGitRepository = $false

if ($GitAvailable) {

    Push-Location $RepositoryRoot

    try {

        $GitResult = git rev-parse `
            --is-inside-work-tree `
            2>$null

        if ($GitResult -eq "true") {
            $IsGitRepository = $true
        }
    }
    finally {
        Pop-Location
    }
}

if ($IsGitRepository) {

    Write-SafetyResult `
        -Status "INFO" `
        -Check "Git repository" `
        -Details "Git tracking is active"

    Push-Location $RepositoryRoot

    try {

        $TrackedSensitivePaths = @(
            git ls-files |
                Where-Object {
                    $_ -like "private/*" -or
                    $_ -like "assets/raw-screenshots/*"
                }
        )

        if ($TrackedSensitivePaths.Count -gt 0) {

            foreach ($TrackedPath in $TrackedSensitivePaths) {

                Write-SafetyResult `
                    -Status "FAIL" `
                    -Check "Local-only file is tracked by Git" `
                    -Details $TrackedPath
            }
        }
        else {

            Write-SafetyResult `
                -Status "PASS" `
                -Check "Git local-only tracking" `
                -Details "No local-only files are currently tracked"
        }
    }
    finally {
        Pop-Location
    }
}
else {

    Write-SafetyResult `
        -Status "INFO" `
        -Check "Git repository" `
        -Details "Git has not been initialized yet"
}


# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Repository Safety Summary" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

Write-Host "PASS : $PassCount" -ForegroundColor Green
Write-Host "WARN : $WarnCount" -ForegroundColor Yellow
Write-Host "FAIL : $FailCount" -ForegroundColor Red
Write-Host "INFO : $InfoCount" -ForegroundColor Cyan
Write-Host ""

$ExitCode = 0

if ($FailCount -gt 0) {

    Write-Host "Overall Result: DO NOT PUBLISH" -ForegroundColor Red

    $ExitCode = 1
}
elseif ($WarnCount -gt 0) {

    Write-Host "Overall Result: MANUAL REVIEW REQUIRED" -ForegroundColor Yellow
}
else {

    Write-Host "Overall Result: SAFETY CHECKS PASSED" -ForegroundColor Green
}

Write-Host ""
Write-Host "This scanner is a guardrail, not a guarantee." `
    -ForegroundColor DarkGray

Write-Host "Always review git status and git diff before committing or pushing." `
    -ForegroundColor DarkGray

Write-Host ""

exit $ExitCode
