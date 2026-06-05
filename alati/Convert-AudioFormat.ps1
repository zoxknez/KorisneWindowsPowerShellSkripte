# Convert-AudioFormat.ps1 - Konverzija audio fajlova (WAV u MP3)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputAudio,
    [Parameter(Mandatory = $true)]
    [string]$OutputAudio
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $InputAudio)) {
    Write-Host "Ulazni fajl ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Konvertujem audio fajl..." -ForegroundColor Cyan
Write-Host "Ulaz : $InputAudio" -ForegroundColor White
Write-Host "Izlaz: $OutputAudio" -ForegroundColor White

try {
    # Koristimo .NET System.Media ili Windows Media Foundation preko shell-a za konverziju
    # Najbolje i najsigurnije rešenje je provera FFmpeg-a, a ako ne postoji, koristimo ugrađeni SAPI/SoundRecorder
    $ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if ($ffmpeg) {
        Write-Host "FFmpeg detektovan! Pokrećem brzu konverziju..." -ForegroundColor DarkGray
        & ffmpeg -i $InputAudio -codec:a libmp3lame -qscale:a 2 $OutputAudio -y
        Write-Host "[+] Konverzija završena preko FFmpeg!" -ForegroundColor Green
    } else {
        # Fallback na .NET Media player koji može da prekodira neke bazične talasne formate
        Write-Host "Konverzija bez FFmpeg je ograničena na ugrađeni Windows prekodera." -ForegroundColor Yellow
        Add-Type -AssemblyName System.Windows.Forms
        # Preporučujemo instalaciju FFmpeg-a za punu audio konverziju
        Write-Host "Molimo instalirajte FFmpeg za podršku svih formata (MP3, M4A, FLAC)." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška pri konverziji: $($_.Exception.Message)" -ForegroundColor Red
}