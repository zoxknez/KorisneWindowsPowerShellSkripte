# Convert-ImageFormat.ps1 - Masovna konverzija slika i promena veličine
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Low")]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),

    [Parameter(Mandatory = $true)]
    [ValidateSet("png", "jpg", "jpeg", "gif", "bmp", "tiff")]
    [string]$TargetFormat,

    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 100000)]
    [int]$Width = 0,

    [Parameter(Mandatory = $false)]
    [string]$OutputFolder,

    [Parameter(Mandatory = $false)]
    [switch]$Recurse,

    [Parameter(Mandatory = $false)]
    [switch]$Overwrite
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-UniqueOutputPath {
    param(
        [string]$Folder,
        [string]$BaseName,
        [string]$Extension,
        [switch]$AllowOverwrite
    )

    $candidate = Join-Path $Folder ($BaseName + $Extension)
    if ($AllowOverwrite -or -not (Test-Path -LiteralPath $candidate)) {
        return $candidate
    }

    $counter = 1
    do {
        $candidate = Join-Path $Folder ("{0}_{1}{2}" -f $BaseName, $counter, $Extension)
        $counter++
    } while (Test-Path -LiteralPath $candidate)

    return $candidate
}

if (-not (Test-Path -LiteralPath $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

$root = (Get-Item -LiteralPath $Path).FullName

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
$files = foreach ($filter in $extensions) {
    Get-ChildItem -LiteralPath $root -File -Filter $filter -Force -Recurse:$Recurse -ErrorAction SilentlyContinue
}
$files = $files | Sort-Object FullName -Unique

if (-not $files -or $files.Count -eq 0) {
    Write-Host "Nisu pronađene slike u folderu: $root" -ForegroundColor Yellow
    return
}

if ([string]::IsNullOrWhiteSpace($OutputFolder)) {
    $OutputFolder = Join-Path $root "konvertovano"
}

New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
Write-Host "Pronađeno $($files.Count) slika. Konvertovani fajlovi će biti sačuvani u: $OutputFolder`n" -ForegroundColor Cyan

$successCount = 0
$errorCount = 0
$targetExtension = "." + $TargetFormat.ToLower()

foreach ($file in $files) {
    $targetBaseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $outputPath = Get-UniqueOutputPath -Folder $OutputFolder -BaseName $targetBaseName -Extension $targetExtension -AllowOverwrite:$Overwrite

    if (-not $PSCmdlet.ShouldProcess($outputPath, "Konverzija slike '$($file.FullName)'")) {
        continue
    }

    Write-Host "Procesiram: $($file.Name)..." -ForegroundColor DarkGray
    $img = $null
    $bmp = $null
    $graphics = $null

    try {
        $img = [System.Drawing.Image]::FromFile($file.FullName)

        if ($Width -gt 0) {
            $ratio = $Width / $img.Width
            $newHeight = [Math]::Max(1, [int]($img.Height * $ratio))

            $bmp = New-Object System.Drawing.Bitmap($Width, $newHeight)
            $graphics = [System.Drawing.Graphics]::FromImage($bmp)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.DrawImage($img, 0, 0, $Width, $newHeight)
            $bmp.Save($outputPath, $imageFormat)
            Write-Host "  [+] Rezolucija: $($img.Width)x$($img.Height) -> ${Width}x${newHeight}" -ForegroundColor Green
        } else {
            $img.Save($outputPath, $imageFormat)
        }

        Write-Host "  [+] Sačuvano kao: $(Split-Path $outputPath -Leaf)" -ForegroundColor Green
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
