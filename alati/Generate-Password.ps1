# Generate-Password.ps1 - Generator sigurnih lozinki i ključeva
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(4, 4096)]
    [int]$Length = 16,

    [Parameter(Mandatory = $false)]
    [switch]$NoSpecial,

    [Parameter(Mandatory = $false)]
    [switch]$NoNumbers,

    [Parameter(Mandatory = $false)]
    [switch]$NoClipboard,

    [Parameter(Mandatory = $false)]
    [switch]$Hide,

    [Parameter(Mandatory = $false)]
    [ValidateRange(0, 3600)]
    [int]$ClearClipboardAfterSeconds = 0
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Get-SecureIndex {
    param(
        [System.Security.Cryptography.RandomNumberGenerator]$Rng,
        [int]$MaxExclusive
    )

    if ($MaxExclusive -le 0) { throw "MaxExclusive mora biti veći od nule." }

    $bytes = New-Object byte[] 4
    $max = [uint32]::MaxValue
    $limit = $max - ($max % [uint32]$MaxExclusive)

    do {
        $Rng.GetBytes($bytes)
        $value = [BitConverter]::ToUInt32($bytes, 0)
    } while ($value -ge $limit)

    return [int]($value % [uint32]$MaxExclusive)
}

function Get-SecureChar {
    param(
        [System.Security.Cryptography.RandomNumberGenerator]$Rng,
        [char[]]$Chars
    )

    return $Chars[(Get-SecureIndex -Rng $Rng -MaxExclusive $Chars.Count)]
}

$upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".ToCharArray()
$lower = "abcdefghijklmnopqrstuvwxyz".ToCharArray()
$numbers = "0123456789".ToCharArray()
$special = "!@#$%^&*()_+-=[]{}|;:,.<>?".ToCharArray()

$charSet = New-Object System.Collections.Generic.List[char]
$upper | ForEach-Object { $charSet.Add($_) }
$lower | ForEach-Object { $charSet.Add($_) }
if (-not $NoNumbers) { $numbers | ForEach-Object { $charSet.Add($_) } }
if (-not $NoSpecial) { $special | ForEach-Object { $charSet.Add($_) } }

$requiredCount = 2
if (-not $NoNumbers) { $requiredCount++ }
if (-not $NoSpecial) { $requiredCount++ }

if ($Length -lt $requiredCount) {
    Write-Host "Dužina lozinke mora biti najmanje $requiredCount za izabrane uslove." -ForegroundColor Red
    return
}

$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try {
    $passwordChars = New-Object System.Collections.Generic.List[char]
    $passwordChars.Add((Get-SecureChar -Rng $rng -Chars $upper))
    $passwordChars.Add((Get-SecureChar -Rng $rng -Chars $lower))
    if (-not $NoNumbers) { $passwordChars.Add((Get-SecureChar -Rng $rng -Chars $numbers)) }
    if (-not $NoSpecial) { $passwordChars.Add((Get-SecureChar -Rng $rng -Chars $special)) }

    while ($passwordChars.Count -lt $Length) {
        $passwordChars.Add($charSet[(Get-SecureIndex -Rng $rng -MaxExclusive $charSet.Count)])
    }

    for ($i = $passwordChars.Count - 1; $i -gt 0; $i--) {
        $j = Get-SecureIndex -Rng $rng -MaxExclusive ($i + 1)
        $tmp = $passwordChars[$i]
        $passwordChars[$i] = $passwordChars[$j]
        $passwordChars[$j] = $tmp
    }

    $generated = -join $passwordChars

    if (-not $Hide) {
        Write-Host "`nGenerisana lozinka:" -ForegroundColor Yellow
        Write-Host $generated -ForegroundColor Green -BackgroundColor Black
    } else {
        Write-Host "`nLozinka je generisana. Prikaz je sakriven zbog -Hide." -ForegroundColor Yellow
    }

    if (-not $NoClipboard) {
        try {
            if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
                Set-Clipboard -Value $generated
            } else {
                $generated | clip.exe
            }
            Write-Host "Lozinka je kopirana u Clipboard." -ForegroundColor Cyan

            if ($ClearClipboardAfterSeconds -gt 0) {
                Start-Sleep -Seconds $ClearClipboardAfterSeconds
                if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
                    Set-Clipboard -Value ""
                } else {
                    "" | clip.exe
                }
                Write-Host "Clipboard je očišćen posle $ClearClipboardAfterSeconds sekundi." -ForegroundColor DarkGray
            }
        } catch {
            Write-Host "Greška pri kopiranju u Clipboard. Kopirajte lozinku ručno." -ForegroundColor Red
        }
    }
} finally {
    $rng.Dispose()
}
