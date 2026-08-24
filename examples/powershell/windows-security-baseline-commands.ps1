# Windows 11 Cybersecurity Workstation
# Security Baseline Verification Commands
#
# Read-only validation commands unless otherwise stated.

Write-Host "`n=== Microsoft Defender ===" -ForegroundColor Cyan

Get-MpComputerStatus |
    Select-Object `
        AntivirusEnabled,
        RealTimeProtectionEnabled,
        BehaviorMonitorEnabled,
        IoavProtectionEnabled,
        NISEnabled,
        AntispywareEnabled,
        AntivirusSignatureLastUpdated


Write-Host "`n=== Windows Firewall ===" -ForegroundColor Cyan

Get-NetFirewallProfile |
    Select-Object `
        Name,
        Enabled,
        DefaultInboundAction,
        DefaultOutboundAction


Write-Host "`n=== Administrator Session ===" -ForegroundColor Cyan

$CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()

$CurrentPrincipal = [Security.Principal.WindowsPrincipal]::new(
    $CurrentIdentity
)

$IsAdmin = $CurrentPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

Write-Host "Running as Administrator: $IsAdmin"


Write-Host "`n=== TPM ===" -ForegroundColor Cyan

try {
    Get-Tpm |
        Select-Object `
            TpmPresent,
            TpmReady,
            TpmEnabled,
            TpmActivated
}
catch {
    Write-Warning "TPM status could not be queried."
}


Write-Host "`n=== Secure Boot ===" -ForegroundColor Cyan

try {
    $SecureBoot = Confirm-SecureBootUEFI
    Write-Host "Secure Boot Enabled: $SecureBoot"
}
catch {
    Write-Warning "Secure Boot status could not be queried."
}


Write-Host "`n=== BitLocker ===" -ForegroundColor Cyan
Write-Host "BitLocker status may require an Administrator terminal."

manage-bde -status C: