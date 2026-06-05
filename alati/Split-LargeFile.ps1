# Split-LargeFile.ps1 - Deljenje velikih fajlova na manje delove
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [Parameter(Mandatory = $false)]
    [int]$LinesPerFile = 50000 # Default 50,000 linija po fajlu
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $FilePath)) {
    Write-Host "Fajl ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Delim fajl: $FilePath..." -ForegroundColor Cyan
Write-Host "Broj linija po izlaznom fajlu: $LinesPerFile`n" -ForegroundColor White

try {
    $fileStream = [System.IO.File]::OpenText($FilePath)
    $fileIndex = 1
    $lineCount = 0
    $writer = $null
    
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $ext = [System.IO.Path]::GetExtension($FilePath)
    $dir = [System.IO.Path]::GetDirectoryName($FilePath)
    
    while (($line = $fileStream.ReadLine()) -ne $null) {
        if ($lineCount % $LinesPerFile -eq 0) {
            # Zatvaramo prethodni pisac
            if ($writer) {
                $writer.Close()
                $writer.Dispose()
            }
            
            # Otvaramo novi fajl
            $partName = "${baseName}_part${fileIndex}${ext}"
            $partPath = Join-Path $dir $partName
            Write-Host "Kreiram deo $($fileIndex): $partName..." -ForegroundColor DarkGray
            
            $writer = New-Object System.IO.StreamWriter($partPath, $false, [System.Text.Encoding]::UTF8)
            $fileIndex++
        }
        
        $writer.WriteLine($line)
        $lineCount++
    }
    
    if ($writer) {
        $writer.Close()
        $writer.Dispose()
    }
    $fileStream.Close()
    $fileStream.Dispose()
    
    Write-Host "`n[+] Fajl je uspešno podeljen na $($fileIndex - 1) delova!" -ForegroundColor Green
    Write-Host "Ukupno procesirano linija: $lineCount" -ForegroundColor Gold
} catch {
    Write-Host "Greška pri deljenju fajla: $($_.Exception.Message)" -ForegroundColor Red
}