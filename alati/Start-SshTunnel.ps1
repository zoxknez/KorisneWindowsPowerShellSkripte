# Start-SshTunnel.ps1 - Kreiranje SSH tunela (Port Forwarding)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SshServer,
    [Parameter(Mandatory = $true)]
    [string]$SshUser,
    [Parameter(Mandatory = $true)]
    [int]$LocalPort,
    [Parameter(Mandatory = $true)]
    [string]$RemoteHost,
    [Parameter(Mandatory = $true)]
    [int]$RemotePort
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Pokrećem SSH tunel..." -ForegroundColor Cyan
Write-Host "Lokalni port: $LocalPort -> Udaljeni host: $($RemoteHost):$RemotePort" -ForegroundColor White
Write-Host "Kroz SSH server: $SshUser@$SshServer" -ForegroundColor White
Write-Host "`nPritisnite Ctrl+C za prekid tunela.`n" -ForegroundColor Yellow

if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Host "Greška: ssh klijent nije instaliran na ovom sistemu!" -ForegroundColor Red
    return
}

try {
    # SSH komanda za lokalni port forwarding
    # -N (bez pokretanja shell-a), -L [lokalniPort]:[udaljeniHost]:[udaljeniPort]
    & ssh -N -L "${LocalPort}:${RemoteHost}:${RemotePort}" "$SshUser@$SshServer"
} catch {
    Write-Host "Tunel prekinut: $($_.Exception.Message)" -ForegroundColor Red
}