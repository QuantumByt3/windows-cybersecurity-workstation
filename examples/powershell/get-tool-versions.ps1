# Windows 11 Cybersecurity Workstation
# Tool Version Inventory
#
# Read-only inventory helper.
# Missing applications are reported rather than causing the script to stop.

function Write-Section {
    param(
        [Parameter(Mandatory)]
        [string]$Title
    )

    Write-Host ""
    Write-Host "=== $Title ===" -ForegroundColor Cyan
}

function Test-CommandVersion {
    param(
        [Parameter(Mandatory)]
        [string]$Command,

        [Parameter(Mandatory)]
        [scriptblock]$VersionCommand
    )

    if (Get-Command $Command -ErrorAction SilentlyContinue) {
        & $VersionCommand
    }
    else {
        Write-Warning "$Command was not found."
    }
}


Write-Section "Development Tools"

Test-CommandVersion "pwsh" {
    pwsh --version
}

Test-CommandVersion "python" {
    python --version
}

Test-CommandVersion "git" {
    git --version
}

Test-CommandVersion "code" {
    code --version
}

Test-CommandVersion "gh" {
    gh --version
}


Write-Section "Windows Platform"

Test-CommandVersion "ssh" {
    ssh -V
}

Test-CommandVersion "winget" {
    winget --version
}


Write-Section "7-Zip"

$SevenZip = "C:\Program Files\7-Zip\7z.exe"

if (Test-Path $SevenZip) {
    & $SevenZip i | Select-Object -First 3
}
else {
    Write-Warning "7-Zip was not found."
}


Write-Section "Wireshark"

$TShark = "C:\Program Files\Wireshark\tshark.exe"

if (Test-Path $TShark) {
    & $TShark --version | Select-Object -First 1
}
else {
    Write-Warning "TShark was not found."
}


Write-Section "Npcap"

$NpcapDriverPath = "$env:SystemRoot\System32\drivers\npcap.sys"

if (Test-Path $NpcapDriverPath) {
    $NpcapDriver = Get-Item $NpcapDriverPath

    [PSCustomObject]@{
    Component      = "Npcap"
    ProductVersion = $NpcapDriver.VersionInfo.ProductVersion
    FileVersion    = $NpcapDriver.VersionInfo.FileVersion
} | Format-List | Out-Host
}
else {
    Write-Warning "Npcap driver was not found."
}


Write-Section "VMware Workstation"

$VmwarePaths = @(
    "C:\Program Files\VMware\VMware Workstation\vmware.exe",
    "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe"
)

$VmwareFound = $false

foreach ($VmwarePath in $VmwarePaths) {
    if (Test-Path $VmwarePath) {
        $VmwareFound = $true
        $Vmware = Get-Item $VmwarePath

        [PSCustomObject]@{
    Component      = "VMware Workstation"
    ProductVersion = $Vmware.VersionInfo.ProductVersion
    FileVersion    = $Vmware.VersionInfo.FileVersion
} | Format-List | Out-Host
    }
}

if (-not $VmwareFound) {
    Write-Warning "VMware Workstation was not found."
}


Write-Section "Microsoft Sysinternals"

$SysinternalsTools = @(
    @{
        Name = "Process Explorer"
        Path = "$HOME\Tools\Sysinternals\ProcessExplorer\procexp64.exe"
    },
    @{
        Name = "Process Monitor"
        Path = "$HOME\Tools\Sysinternals\ProcessMonitor\Procmon64.exe"
    },
    @{
        Name = "Autoruns"
        Path = "$HOME\Tools\Sysinternals\Autoruns\Autoruns64.exe"
    },
    @{
        Name = "TCPView"
        Path = "$HOME\Tools\Sysinternals\TCPView\tcpview64.exe"
    },
    @{
        Name = "Sigcheck"
        Path = "$HOME\Tools\Sysinternals\Sigcheck\sigcheck64.exe"
    },
    @{
        Name = "Strings"
        Path = "$HOME\Tools\Sysinternals\Strings\strings64.exe"
    }
)

$SysinternalsResults = foreach ($SysinternalsTool in $SysinternalsTools) {
    if (Test-Path $SysinternalsTool.Path) {
        $Item = Get-Item $SysinternalsTool.Path

        [PSCustomObject]@{
            Component      = $SysinternalsTool.Name
            ProductVersion = $Item.VersionInfo.ProductVersion
            FileVersion    = $Item.VersionInfo.FileVersion
        }
    }
    else {
        Write-Warning "$($SysinternalsTool.Name) was not found."
    }
}

$SysinternalsResults |
    Format-Table -AutoSize |
    Out-Host