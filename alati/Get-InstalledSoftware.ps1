[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-InstalledSoftware.ps1 - Prikaz instaliranog softvera na Windows-u
Write-Host "Prikupljam listu instaliranih programa na računaru (ovo može potrajati)..." -ForegroundColor Cyan

$regPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

try {
    $software = Get-ItemProperty $regPaths -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -and $_.SystemComponent -ne 1 } |
                Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
                Sort-Object DisplayName
                
    Write-Host "`nUkupno pronađeno programa: $($software.Count)`n" -ForegroundColor Yellow
    
    if ($software.Count -gt 0) {
        $software | Format-Table -Property DisplayName, DisplayVersion, Publisher -AutoSize
    } else {
        Write-Host "Nisu pronađeni instalirani programi u registru." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška pri čitanju registra instaliranog softvera: $($_.Exception.Message)" -ForegroundColor Red
}