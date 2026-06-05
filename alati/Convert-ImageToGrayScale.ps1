# Convert-ImageToGrayScale.ps1 - Pretvaranje slika u crno-bele (Grayscale)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ImagePath
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $ImagePath)) {
    Write-Host "Slika ne postoji na putanji: $ImagePath" -ForegroundColor Red
    return
}

Write-Host "Pretvaram sliku u crno-belu (Grayscale) varijantu..." -ForegroundColor Cyan

try {
    # Učitavanje GDI+ sklopa
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    
    $original = [System.Drawing.Image]::FromFile($ImagePath)
    $bmp = New-Object System.Drawing.Bitmap($original.Width, $original.Height)
    
    # Kreiranje matrice boja za Grayscale konverziju
    # Standardni težinski koeficijenti za osvetljenje (luminance)
    # R=0.299, G=0.587, B=0.114
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    
    $colorMatrix = New-Object System.Drawing.Imaging.ColorMatrix
    $colorMatrix.Matrix00 = 0.299
    $colorMatrix.Matrix10 = 0.299
    $colorMatrix.Matrix20 = 0.299
    $colorMatrix.Matrix01 = 0.587
    $colorMatrix.Matrix11 = 0.587
    $colorMatrix.Matrix21 = 0.587
    $colorMatrix.Matrix02 = 0.114
    $colorMatrix.Matrix12 = 0.114
    $colorMatrix.Matrix22 = 0.114
    
    $attributes = New-Object System.Drawing.Imaging.ImageAttributes
    $attributes.SetColorMatrix($colorMatrix)
    
    $rect = New-Object System.Drawing.Rectangle(0, 0, $original.Width, $original.Height)
    $g.DrawImage($original, $rect, 0, 0, $original.Width, $original.Height, [System.Drawing.GraphicsUnit]::Pixel, $attributes)
    
    $g.Dispose()
    $original.Dispose()
    
    $dir = [System.IO.Path]::GetDirectoryName($ImagePath)
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($ImagePath)
    $ext = [System.IO.Path]::GetExtension($ImagePath)
    $outPath = Join-Path $dir "${fileName}_grayscale${ext}"
    
    # Određivanje formata za čuvanje
    $format = switch ($ext.ToLower()) {
        ".png"  { [System.Drawing.Imaging.ImageFormat]::Png }
        ".gif"  { [System.Drawing.Imaging.ImageFormat]::Gif }
        ".bmp"  { [System.Drawing.Imaging.ImageFormat]::Bmp }
        default { [System.Drawing.Imaging.ImageFormat]::Jpeg }
    }
    
    $bmp.Save($outPath, $format)
    $bmp.Dispose()
    
    Write-Host "`n[+] Slika uspešno konvertovana!" -ForegroundColor Green
    Write-Host "Crno-bela slika sačuvana na: $outPath" -ForegroundColor Yellow
} catch {
    Write-Host "Greška pri konverziji slike: $($_.Exception.Message)" -ForegroundColor Red
}