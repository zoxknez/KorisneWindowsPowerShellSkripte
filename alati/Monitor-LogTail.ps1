# Monitor-LogTail.ps1 - Praćenje log fajlova u realnom vremenu sa bojama
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LogFile
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $LogFile)) {
    Write-Host "Log fajl ne postoji: $LogFile" -ForegroundColor Red
    return
}

Write-Host "Pratim log fajl u realnom vremenu: $LogFile" -ForegroundColor Cyan
Write-Host "Boje: ERROR=Crveno | WARN=Žuto | SUCCESS=Zeleno | INFO=Plavo" -ForegroundColor DarkGray
Write-Host "Pritisnite Ctrl+C za izlaz.`n" -ForegroundColor Yellow

try {
    # Otvaramo fajl sa FileShare.ReadWrite pravima (tail -f emulator)
    $stream = New-Object System.IO.FileStream($LogFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    $reader = New-Object System.IO.StreamReader($stream)
    
    # Prvo se pozicioniramo na kraj fajla
    $null = $stream.Seek(0, [System.IO.SeekOrigin]::End)
    
    while ($true) {
        $line = $reader.ReadLine()
        if ($line -ne $null) {
            # Bojenje u zavisnosti od ključnih reči
            if ($line -match '(?i)\b(error|fail|exception|critical)\b') {
                Write-Host $line -ForegroundColor Red
            } elseif ($line -match '(?i)\b(warn|warning|alert)\b') {
                Write-Host $line -ForegroundColor Yellow
            } elseif ($line -match '(?i)\b(success|ok|passed|done)\b') {
                Write-Host $line -ForegroundColor Green
            } elseif ($line -match '(?i)\b(info|information|debug)\b') {
                Write-Host $line -ForegroundColor Blue
            } else {
                Write-Host $line -ForegroundColor White
            }
        } else {
            Start-Sleep -Milliseconds 200
        }
    }
} catch {
    Write-Host "`nPraćenje loga zaustavljeno." -ForegroundColor Red
} finally {
    if ($reader) { $reader.Close() }
    if ($stream) { $stream.Close() }
}