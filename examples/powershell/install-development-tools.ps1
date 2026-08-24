<#
.SYNOPSIS
    Installs and optionally upgrades the core development tools used by
    the Windows 11 Cybersecurity Workstation project.

.DESCRIPTION
    Uses Windows Package Manager (winget) to evaluate and manage:

    - PowerShell 7
    - Git for Windows
    - Python
    - Visual Studio Code
    - GitHub CLI
    - 7-Zip

    Normal behavior:
    - Missing packages are installed.
    - Installed packages are checked for updates.
    - Available updates are reported but NOT automatically installed.

    With -Upgrade:
    - Missing packages are installed.
    - Installed packages with available updates are upgraded.

    With -WhatIf:
    - Proposed installations and upgrades are previewed without
      changing the workstation.

    This script intentionally does NOT:
    - Configure Git identity
    - Generate SSH keys
    - Authenticate to GitHub
    - Enable ssh-agent
    - Enable sshd
    - Modify Microsoft Defender
    - Modify Windows Firewall
    - Modify BitLocker
    - Weaken PowerShell execution policy

.EXAMPLE
    .\install-development-tools.ps1 -WhatIf

    Preview installation of missing packages.

.EXAMPLE
    .\install-development-tools.ps1

    Install missing tools and report available updates.

.EXAMPLE
    .\install-development-tools.ps1 -Upgrade -WhatIf

    Preview both missing installations and available upgrades.

.EXAMPLE
    .\install-development-tools.ps1 -Upgrade

    Install missing tools and explicitly upgrade supported installed packages.

.NOTES
    Project: Windows 11 Cybersecurity Workstation
    Author: QuantumByt3
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch]$Upgrade
)

# ------------------------------------------------------------
# Package Manifest
# ------------------------------------------------------------

$Packages = @(
    [PSCustomObject]@{
        Name = "PowerShell 7"
        Id   = "Microsoft.PowerShell"
        Note = "Current stable PowerShell release"
    },
    [PSCustomObject]@{
        Name = "Git for Windows"
        Id   = "Git.Git"
        Note = "Current stable Git for Windows release"
    },
    [PSCustomObject]@{
        Name = "Python 3.14"
        Id   = "Python.Python.3.14"
        Note = "Tracks the Python 3.14 release family"
    },
    [PSCustomObject]@{
        Name = "Visual Studio Code"
        Id   = "Microsoft.VisualStudioCode"
        Note = "Current stable Visual Studio Code release"
    },
    [PSCustomObject]@{
        Name = "GitHub CLI"
        Id   = "GitHub.cli"
        Note = "Current stable GitHub CLI release"
    },
    [PSCustomObject]@{
        Name = "7-Zip"
        Id   = "7zip.7zip"
        Note = "Current stable 7-Zip release"
    }
)


# ------------------------------------------------------------
# Output Helper
# ------------------------------------------------------------

function Write-InstallMessage {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("INFO", "PASS", "UPDATE", "WARN", "FAIL")]
        [string]$Status,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $Color = switch ($Status) {
        "INFO"   { "Cyan" }
        "PASS"   { "Green" }
        "UPDATE" { "Yellow" }
        "WARN"   { "Yellow" }
        "FAIL"   { "Red" }
    }

    Write-Host "[$Status] $Message" -ForegroundColor $Color
}


# ------------------------------------------------------------
# Get WinGet Package State
# ------------------------------------------------------------

function Get-WingetPackageState {
    param(
        [Parameter(Mandatory)]
        [string]$Id
    )

    $EscapedId = [regex]::Escape($Id)

    # --------------------------------------------------------
    # Determine whether the exact package is installed.
    # --------------------------------------------------------

    $InstalledOutput = @(
        winget list `
            --id $Id `
            -e `
            --accept-source-agreements `
            --disable-interactivity `
            2>$null
    )

    $InstalledText = $InstalledOutput -join "`n"

    # Match the exact package ID and capture the version
    # immediately following it.
    $InstalledPattern = "$EscapedId\s+(\S+)"

    if ($InstalledText -notmatch $InstalledPattern) {
        return [PSCustomObject]@{
            Installed        = $false
            InstalledVersion = $null
            UpdateAvailable  = $false
            AvailableVersion = $null
        }
    }

    $InstalledVersion = $Matches[1]


    # --------------------------------------------------------
    # Determine whether WinGet reports an available upgrade.
    # --------------------------------------------------------

    $UpgradeOutput = @(
        winget list `
            --id $Id `
            -e `
            --upgrade-available `
            --accept-source-agreements `
            --disable-interactivity `
            2>$null
    )

    $UpgradeText = $UpgradeOutput -join "`n"

    # With --upgrade-available, a matching package row contains:
    #
    # ID   InstalledVersion   AvailableVersion   Source
    #
    # If the package ID is absent, WinGet is not reporting
    # an available upgrade for that package.
    $UpgradePattern = "$EscapedId\s+(\S+)\s+(\S+)"

    if ($UpgradeText -match $UpgradePattern) {
        return [PSCustomObject]@{
            Installed        = $true
            InstalledVersion = $InstalledVersion
            UpdateAvailable  = $true
            AvailableVersion = $Matches[2]
        }
    }

    return [PSCustomObject]@{
        Installed        = $true
        InstalledVersion = $InstalledVersion
        UpdateAvailable  = $false
        AvailableVersion = $null
    }
}


# ------------------------------------------------------------
# Header
# ------------------------------------------------------------

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Windows Cybersecurity Development Tool Installer" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""


# ------------------------------------------------------------
# Verify WinGet
# ------------------------------------------------------------

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {

    Write-InstallMessage `
        -Status "FAIL" `
        -Message "Windows Package Manager (winget) was not found."

    Write-Host ""
    Write-Host "Install or repair Microsoft App Installer before continuing." `
        -ForegroundColor Yellow

    return
}

$WingetVersion = winget --version

Write-InstallMessage `
    -Status "INFO" `
    -Message "Windows Package Manager detected: $WingetVersion"

if ($Upgrade) {
    Write-InstallMessage `
        -Status "INFO" `
        -Message "Upgrade mode is ENABLED."
}
else {
    Write-InstallMessage `
        -Status "INFO" `
        -Message "Upgrade mode is disabled. Available updates will only be reported."
}


# ------------------------------------------------------------
# Evaluate Packages
# ------------------------------------------------------------

foreach ($Package in $Packages) {

    Write-Host ""
    Write-Host "--- $($Package.Name) ---" -ForegroundColor Cyan

    Write-InstallMessage `
        -Status "INFO" `
        -Message $Package.Note

    $PackageState = Get-WingetPackageState `
        -Id $Package.Id


    # --------------------------------------------------------
    # Package is missing
    # --------------------------------------------------------

    if (-not $PackageState.Installed) {

        Write-InstallMessage `
            -Status "INFO" `
            -Message "$($Package.Name) is not currently detected."

        if (
            $PSCmdlet.ShouldProcess(
                $Package.Name,
                "Install package $($Package.Id)"
            )
        ) {

            Write-InstallMessage `
                -Status "INFO" `
                -Message "Installing current package from WinGet..."

            winget install `
                --id $Package.Id `
                -e `
                --source winget `
                --accept-package-agreements `
                --accept-source-agreements

            if ($LASTEXITCODE -eq 0) {

                Write-InstallMessage `
                    -Status "PASS" `
                    -Message "$($Package.Name) installation completed."
            }
            else {

                Write-InstallMessage `
                    -Status "WARN" `
                    -Message "$($Package.Name) returned WinGet exit code $LASTEXITCODE."
            }
        }

        continue
    }


    # --------------------------------------------------------
    # Package is installed and has an update
    # --------------------------------------------------------

    if ($PackageState.UpdateAvailable) {

        $InstalledVersion = $PackageState.InstalledVersion
        $AvailableVersion = $PackageState.AvailableVersion

        Write-InstallMessage `
            -Status "UPDATE" `
            -Message "$($Package.Name): installed $InstalledVersion; available $AvailableVersion."

        if (-not $Upgrade) {

            Write-InstallMessage `
                -Status "INFO" `
                -Message "No upgrade performed. Re-run with -Upgrade to approve updates."

            continue
        }

        if (
            $PSCmdlet.ShouldProcess(
                $Package.Name,
                "Upgrade $InstalledVersion to $AvailableVersion"
            )
        ) {

            Write-InstallMessage `
                -Status "INFO" `
                -Message "Upgrading $($Package.Name)..."

            winget upgrade `
                --id $Package.Id `
                -e `
                --source winget `
                --accept-package-agreements `
                --accept-source-agreements

            if ($LASTEXITCODE -eq 0) {

                Write-InstallMessage `
                    -Status "PASS" `
                    -Message "$($Package.Name) upgrade completed."
            }
            else {

                Write-InstallMessage `
                    -Status "WARN" `
                    -Message "$($Package.Name) upgrade returned WinGet exit code $LASTEXITCODE."
            }
        }

        continue
    }


    # --------------------------------------------------------
    # Package is installed and current
    # --------------------------------------------------------

    Write-InstallMessage `
        -Status "PASS" `
        -Message "$($Package.Name) is installed and WinGet reports no available upgrade. Installed version: $($PackageState.InstalledVersion)"
}


# ------------------------------------------------------------
# Visual Studio Code Extensions
# ------------------------------------------------------------

Write-Host ""
Write-Host "--- Visual Studio Code Extensions ---" -ForegroundColor Cyan

$CodeCommand = Get-Command code -ErrorAction SilentlyContinue

if (-not $CodeCommand) {

    Write-InstallMessage `
        -Status "WARN" `
        -Message "The code command is not available in this terminal."

    Write-Host ""
    Write-Host "If VS Code was just installed, restart the terminal before installing extensions." `
        -ForegroundColor Yellow
}
else {

    $Extensions = @(
        "ms-python.python",
        "ms-python.vscode-pylance",
        "yzhang.markdown-all-in-one",
        "ms-vscode.powershell"
    )

    $InstalledExtensions = code --list-extensions

    foreach ($Extension in $Extensions) {

        if ($InstalledExtensions -contains $Extension) {

            Write-InstallMessage `
                -Status "PASS" `
                -Message "VS Code extension installed: $Extension"

            continue
        }

        if (
            $PSCmdlet.ShouldProcess(
                $Extension,
                "Install VS Code extension"
            )
        ) {

            code --install-extension $Extension

            if ($LASTEXITCODE -eq 0) {

                Write-InstallMessage `
                    -Status "PASS" `
                    -Message "Installed VS Code extension: $Extension"
            }
            else {

                Write-InstallMessage `
                    -Status "WARN" `
                    -Message "Extension installation returned exit code $LASTEXITCODE for $Extension."
            }
        }
    }

    if ($Upgrade) {

        Write-InstallMessage `
            -Status "INFO" `
            -Message "VS Code extension upgrades are not performed automatically by this script."

        Write-InstallMessage `
            -Status "INFO" `
            -Message "Review extension updates separately inside Visual Studio Code."
    }
}


# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host " Development Tool Evaluation Complete" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Recommended next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart the terminal if software was installed or upgraded."
Write-Host "  2. Run examples\powershell\get-tool-versions.ps1."
Write-Host "  3. Configure Git identity."
Write-Host "  4. Configure a dedicated GitHub SSH key."
Write-Host "  5. Authenticate GitHub CLI."
Write-Host "  6. Create Python virtual environments per project."
Write-Host ""

Write-Host "Account-specific authentication was intentionally not automated." `
    -ForegroundColor DarkGray

Write-Host "Installed packages were not silently upgraded unless -Upgrade was supplied." `
    -ForegroundColor DarkGray