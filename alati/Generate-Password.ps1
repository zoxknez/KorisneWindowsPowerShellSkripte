# Generate-Password.ps1 - Generator sigurnih lozinki i ključeva
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$Length = 16,
    [Parameter(Mandatory = $false)]
    [switch]$NoSpecial,
    [Parameter(Mandatory = $false)]
    [switch]$NoNumbers
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if ($Length -lt 4) {
    Write-Host "Dužina lozinke mora biti najmanje 4 karaktera!" -ForegroundColor Red
    return
}

$upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
$lower = "abcdefghijklmnopqrstuvwxyz"
$numbers = "0123456789"
$special = "!@#$%^&*()_+-=[]{}|;:,.<>?"

$charSet = $upper + $lower
if (-not $NoNumbers) { $charSet += $numbers }
if (-not $NoSpecial) { $charSet += $special }

$rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
$chars = $charSet.ToCharArray()
$password = New-Object System.Text.StringBuilder

$requiredChars = @()
$requiredChars += $upper[(Get-Random -Maximum $upper.Length)]
$requiredChars += $lower[(Get-Random -Maximum $lower.Length)]
if (-not $NoNumbers) { $requiredChars += $numbers[(Get-Random -Maximum $numbers.Length)] }
if (-not $NoSpecial) { $requiredChars += $special[(Get-Random -Maximum $special.Length)] }

$bytes = New-Object byte[] ($Length - $requiredChars.Count)
$rng.GetBytes($bytes)

foreach ($byte in $bytes) {
    $index = $byte % $chars.Count
    $password.Append($chars[$index]) | Out-Null
}

foreach ($char in $requiredChars) {
    $password.Append($char) | Out-Null
}

$shuffledPassword = ($password.ToString().ToCharArray() | Sort-Object { Get-Random }) -join ""

Write-Host "`nGenerisana lozinka:" -ForegroundColor Yellow
Write-Host "$shuffledPassword" -ForegroundColor Green -BackgroundColor Black

try {
    if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
        Set-Clipboard -Value $shuffledPassword
    } else {
        $shuffledPassword | clip.exe
    }
    Write-Host "`nLozinka je uspešno kopirana u Clipboard!" -ForegroundColor Cyan
} catch {
    Write-Host "`nGreška pri kopiranju u Clipboard. Kopirajte lozinku ručno." -ForegroundColor Red
}