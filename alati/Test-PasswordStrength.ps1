# Test-PasswordStrength.ps1 - Analiza jačine lozinke
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Password
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Analiziram unetu lozinku..." -ForegroundColor Cyan

$score = 0
$feedbacks = @()

# 1. Provera dužine
if ($Password.Length -ge 16) { $score += 3 }
elseif ($Password.Length -ge 12) { $score += 2 }
elseif ($Password.Length -ge 8) { $score += 1 }
else { $feedbacks += "  [-] Lozinka je prekratka (manje od 8 karaktera)." }

# 2. Provera velikih slova
if ($Password -match '[A-Z]') { $score += 1 }
else { $feedbacks += "  [-] Nedostaju velika slova." }

# 3. Provera malih slova
if ($Password -match '[a-z]') { $score += 1 }
else { $feedbacks += "  [-] Nedostaju mala slova." }

# 4. Provera brojeva
if ($Password -match '[0-9]') { $score += 1 }
else { $feedbacks += "  [-] Nedostaju cifre/brojevi." }

# 5. Provera specijalnih karaktera
if ($Password -match '[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]') { $score += 2 }
else { $feedbacks += "  [-] Nedostaju specijalni karakteri." }

# Prikaz izveštaja
Write-Host "`nRezultati analize:" -ForegroundColor Yellow
Write-Host "  Jačina (Score): $score / 8" -ForegroundColor White

Write-Host "  Ocena lozinke : " -NoNewline -ForegroundColor White
if ($score -ge 7) {
    Write-Host "IZUZETNO JAKO" -ForegroundColor Green
} elseif ($score -ge 5) {
    Write-Host "Srednja jačina" -ForegroundColor Yellow
} else {
    Write-Host "SLABO / NEBEZBEDNO" -ForegroundColor Red
}

if ($feedbacks.Count -gt 0) {
    Write-Host "`nPredlozi za poboljšanje:" -ForegroundColor Yellow
    $feedbacks | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }
}