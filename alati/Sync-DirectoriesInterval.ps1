# Sync-DirectoriesInterval.ps1 - Sinhronizacija foldera u određenom intervalu
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,
    [Parameter(Mandatory = $true)]
    [string]$DestinationPath,
    [Parameter(Mandatory = $false)]
    [int]$IntervalSeconds = 60
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $SourcePath)) {
    Write-Host "Izvorni folder ne postoji!" -ForegroundColor Red
    return
}

if (-not (Test-Path $DestinationPath)) {
    New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
}

Write-Host "Pokrećem periodičnu sinhronizaciju foldera..." -ForegroundColor Cyan
Write-Host "Izvor    : $SourcePath" -ForegroundColor White
Write-Host "Odredište: $DestinationPath" -ForegroundColor White
Write-Host "Interval : $IntervalSeconds sekundi" -ForegroundColor White
Write-Host "`nPritisnite Ctrl+C za prekid sinhronizacije.`n" -ForegroundColor Yellow

try {
    while ($true) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Sinhronizujem fajlove..." -ForegroundColor DarkGray
        
        # Robocopy /MIR - ogledalo (kopira nove, ažurira izmenjene, briše obrisane u destination)
        $process = Start-Process robocopy -ArgumentList @(
            $SourcePath,
            $DestinationPath,
            "/MIR",
            "/R:0",
            "/W:0",
            "/NFL",
            "/NDL",
            "/NJH",
            "/NJS"
        ) -Wait -NoNewWindow -PassThru
        
        # Robocopy exit kodovi manji od 8 označavaju uspešno kopiranje/sinhronizaciju
        if ($process.ExitCode -lt 8) {
            Write-Host "  [+] Sinhronizacija uspešna." -ForegroundColor Green
        } else {
            Write-Host "  [-] Greška tokom robocopy sinhronizacije (Exit Code: $($process.ExitCode))." -ForegroundColor Red
        }
        
        Start-Sleep -Seconds $IntervalSeconds
    }
} catch {
    Write-Host "`nSinhronizacija zaustavljena." -ForegroundColor Yellow
}