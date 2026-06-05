# Watch-Folder.ps1 - Praćenje izmena u folderu u realnom vremenu
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location)
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Pokretanje praćenja foldera: $Path" -ForegroundColor Cyan
Write-Host "Sve promene (kreiranje, izmena, brisanje i preimenovanje) će biti prikazane u realnom vremenu.`n" -ForegroundColor DarkGray
Write-Host "Pritisnite bilo koji taster u konzoli da zaustavite praćenje..." -ForegroundColor Yellow

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $Path
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$subCreated = Register-ObjectEvent -InputObject $watcher -EventName Created -SourceIdentifier "Watcher_Created" -Action {
    $path = $event.SourceEventArgs.FullPath
    Write-Host "[KREIRAN]  " -NoNewline -ForegroundColor Green
    Write-Host "$path u $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
}

$subChanged = Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier "Watcher_Changed" -Action {
    $path = $event.SourceEventArgs.FullPath
    Write-Host "[IZMENJEN] " -NoNewline -ForegroundColor Yellow
    Write-Host "$path u $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
}

$subDeleted = Register-ObjectEvent -InputObject $watcher -EventName Deleted -SourceIdentifier "Watcher_Deleted" -Action {
    $path = $event.SourceEventArgs.FullPath
    Write-Host "[OBRISAN]  " -NoNewline -ForegroundColor Red
    Write-Host "$path u $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
}

$subRenamed = Register-ObjectEvent -InputObject $watcher -EventName Renamed -SourceIdentifier "Watcher_Renamed" -Action {
    $oldPath = $event.SourceEventArgs.OldFullPath
    $newPath = $event.SourceEventArgs.FullPath
    Write-Host "[PREIMEN]  " -NoNewline -ForegroundColor Cyan
    Write-Host "$oldPath -> $newPath u $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor White
}

try {
    while (-not [System.Console]::KeyAvailable) {
        Start-Sleep -Milliseconds 200
    }
    $null = [System.Console]::ReadKey($true)
} catch {
    Write-Host "Pritisnite Ctrl+C za zaustavljanje." -ForegroundColor Yellow
    while ($true) { Start-Sleep -Seconds 1 }
} finally {
    $watcher.EnableRaisingEvents = $false
    Unregister-Event -SourceIdentifier "Watcher_Created" -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier "Watcher_Changed" -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier "Watcher_Deleted" -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier "Watcher_Renamed" -ErrorAction SilentlyContinue
    $watcher.Dispose()
    Write-Host "`nPraćenje foldera je zaustavljeno." -ForegroundColor Red
}