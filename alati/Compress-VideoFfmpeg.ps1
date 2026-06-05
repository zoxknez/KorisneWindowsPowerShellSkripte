# Compress-VideoFfmpeg.ps1 - Kompresija video fajlova preko FFmpeg-a
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputVideo,
    [Parameter(Mandatory = $true)]
    [string]$OutputVideo,
    [Parameter(Mandatory = $false)]
    [int]$TargetSizeMB = 25 # Default 25MB za slanje na Discord/Imejl
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $InputVideo)) {
    Write-Host "Ulazni video ne postoji!" -ForegroundColor Red
    return
}

$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
if (-not $ffmpeg) {
    Write-Host "Greška: Ova skripta zahteva instaliran FFmpeg u sistemu!" -ForegroundColor Red
    return
}

Write-Host "Započinjem kompresiju videa na ciljnu veličinu od: $TargetSizeMB MB..." -ForegroundColor Cyan

try {
    # Dobijanje trajanja videa u sekundama preko ffprobe
    Write-Host "Računam optimalan bitrate..." -ForegroundColor DarkGray
    $durationStr = & ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $InputVideo
    $duration = [double]$durationStr.Trim()
    
    # Računanje potrebnog bitrate-a (Veličina u bitovima / vreme)
    # Bitrate = (TargetSize * 8192) / Duration - oduzimamo 128kbps za audio
    $targetBitrate = [int]((($TargetSizeMB * 8192) / $duration) - 128)
    
    if ($targetBitrate -lt 100) { $targetBitrate = 100 } # Minimalna granica kvaliteta
    
    Write-Host "  Trajanje videa  : $duration sekundi" -ForegroundColor White
    Write-Host "  Proračunati video bitrate: $targetBitrate kbps" -ForegroundColor Green
    
    Write-Host "`nPokrećem dvoprolaznu kompresiju (2-pass encoding) za maksimalni kvalitet..." -ForegroundColor Yellow
    
    # Prvi prolaz
    Write-Host "  [+] Prolaz 1..." -ForegroundColor DarkGray
    & ffmpeg -y -i $InputVideo -c:v libx264 -b:v "${targetBitrate}k" -pass 1 -an -f null NUL
    
    # Drugi prolaz
    Write-Host "  [+] Prolaz 2..." -ForegroundColor DarkGray
    & ffmpeg -y -i $InputVideo -c:v libx264 -b:v "${targetBitrate}k" -pass 2 -c:a aac -b:a 128k $OutputVideo
    
    # Čišćenje ffmpeg log fajlova od prolaza
    Remove-Item "ffmpeg2pass-0.log" -ErrorAction SilentlyContinue
    Remove-Item "ffmpeg2pass-0.log.mbtree" -ErrorAction SilentlyContinue
    
    if (Test-Path $OutputVideo) {
        $finalSize = (Get-Item $OutputVideo).Length
        Write-Host "`n[+] Video uspešno kompresovan!" -ForegroundColor Green
        Write-Host "Konačna veličina: $([Math]::Round($finalSize / 1MB, 2)) MB" -ForegroundColor Gold
    }
} catch {
    Write-Host "Greška tokom kompresije: $($_.Exception.Message)" -ForegroundColor Red
}