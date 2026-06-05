# Convert-ImageFormat.ps1 - Masovna konverzija slika i promena veličine
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),
    [Parameter(Mandatory = $true)]
    [ValidateSet("png", "jpg", "jpeg", "gif", "bmp", "tiff")]
    [string]$TargetFormat,
    [Parameter(Mandatory = $false)]
    [int]$Width = 0
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

try {
    Add-Type -AssemblyName System.Drawing
} catch {
    Write-Host "Greška pri učitavanju GDI+ System.Drawing. Ova skripta zahteva Windows okruženje." -ForegroundColor Red
    return
}

$imageFormat = switch ($TargetFormat.ToLower()) {
    "png"  { [System.Drawing.Imaging.ImageFormat]::Png }
    "jpg"  { [System.Drawing.Imaging.ImageFormat]::Jpeg }
    "jpeg" { [System.Drawing.Imaging.ImageFormat]::Jpeg }
    "gif"  { [System.Drawing.Imaging.ImageFormat]::Gif }
    "bmp"  { [System.Drawing.Imaging.ImageFormat]::Bmp }
    "tiff" { [System.Drawing.Imaging.ImageFormat]::Tiff }
}

$extensions = @("*.png", "*.jpg", "*.jpeg", "*.gif", "*.bmp", "*.tiff")
$files = Get-ChildItem -Path $Path -File -Include $extensions -Force -ErrorAction SilentlyContinue

if ($files.Count -eq 0) {
    Write-Host "Nisu pronađene slike u folderu: $Path" -ForegroundColor Yellow
    return
}

$outputFolder = Join-Path $Path "konvertovano"
New-Item -ItemType Directory -Path $outputFolder -Force | Out-Null
Write-Host "Pronađeno $($files.Count) slika. Konvertovani fajlovi će biti sačuvani u: $outputFolder`n" -ForegroundColor Cyan

$successCount = 0
$errorCount = 0

foreach ($file in $files) {
    Write-Host "Procesiram: $($file.Name)..." -ForegroundColor DarkGray
    $targetFileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name) + "." + $TargetFormat.ToLower()
    $outputPath = Join-Path $outputFolder $targetFileName
    
    $img = $null
    $bmp = $null
    $graphics = $null
    
    try {
        $img = [System.Drawing.Image]::FromFile($file.FullName)
        
        if ($Width -gt 0) {
            $ratio = $Width / $img.Width
            $newHeight = [int]($img.Height * $ratio)
            
            $bmp = New-Object System.Drawing.Bitmap($Width, $newHeight)
            $graphics = [System.Drawing.Graphics]::FromImage($bmp)
            
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            
            $graphics.DrawImage($img, 0, 0, $Width, $newHeight)
            $bmp.Save($outputPath, $imageFormat)
            Write-Host "  [+] Promenjena rezolucija: $($img.Width)x$($img.Height) -> ${Width}x${newHeight}" -ForegroundColor Green
        } else {
            $img.Save($outputPath, $imageFormat)
        }
        
        Write-Host "  [+] Sačuvano kao: $targetFileName" -ForegroundColor Green
        $successCount++
    } catch {
        Write-Host "  [-] Greška pri obradi: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    } finally {
        if ($graphics) { $graphics.Dispose() }
        if ($bmp) { $bmp.Dispose() }
        if ($img) { $img.Dispose() }
    }
}

Write-Host "`nObrada slika završena!" -ForegroundColor Green
Write-Host "Uspešno konvertovano: $successCount slika." -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "Greške pri konverziji: $errorCount slika." -ForegroundColor Red
}