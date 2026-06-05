# Encrypt-DecryptFile.ps1 - Šifrovanje i dešifrovanje fajlova uz proveru integriteta
[CmdletBinding(DefaultParameterSetName = "Encrypt", SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(Mandatory = $false, ParameterSetName = "Encrypt")]
    [switch]$Encrypt,

    [Parameter(Mandatory = $false, ParameterSetName = "Decrypt")]
    [switch]$Decrypt,

    [Parameter(Mandatory = $false)]
    [ValidateRange(100000, 2000000)]
    [int]$Iterations = 310000,

    [Parameter(Mandatory = $false)]
    [securestring]$Password
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$Magic = [System.Text.Encoding]::ASCII.GetBytes("WUTENC2")
$SaltSize = 16
$IvSize = 16
$MacSize = 32

function Convert-SecureStringToBytes {
    param([securestring]$SecureValue)

    $bstr = [IntPtr]::Zero
    try {
        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureValue)
        $plain = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        return [System.Text.Encoding]::UTF8.GetBytes($plain)
    } finally {
        if ($bstr -ne [IntPtr]::Zero) {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

function New-RandomBytes {
    param([int]$Length)

    $bytes = New-Object byte[] $Length
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $rng.GetBytes($bytes)
        return $bytes
    } finally {
        $rng.Dispose()
    }
}

function New-KeyMaterial {
    param(
        [byte[]]$PasswordBytes,
        [byte[]]$Salt,
        [int]$IterationCount
    )

    try {
        $derive = New-Object System.Security.Cryptography.Rfc2898DeriveBytes(
            $PasswordBytes,
            $Salt,
            $IterationCount,
            [System.Security.Cryptography.HashAlgorithmName]::SHA256
        )
    } catch {
        Write-Host "Upozorenje: Ovaj .NET runtime ne podržava PBKDF2-SHA256 konstruktor; koristi se kompatibilni PBKDF2 fallback." -ForegroundColor Yellow
        $derive = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($PasswordBytes, $Salt, $IterationCount)
    }

    try {
        return [PSCustomObject]@{
            EncKey = $derive.GetBytes(32)
            MacKey = $derive.GetBytes(32)
        }
    } finally {
        $derive.Dispose()
    }
}

function Join-ByteArrays {
    param([byte[][]]$Parts)

    $length = 0
    foreach ($part in $Parts) { if ($part) { $length += $part.Length } }

    $result = New-Object byte[] $length
    $offset = 0
    foreach ($part in $Parts) {
        if (-not $part) { continue }
        [Array]::Copy($part, 0, $result, $offset, $part.Length)
        $offset += $part.Length
    }
    return $result
}

function Test-FixedTimeEquals {
    param([byte[]]$A, [byte[]]$B)

    if (-not $A -or -not $B -or $A.Length -ne $B.Length) { return $false }

    $cryptoOps = [type]::GetType("System.Security.Cryptography.CryptographicOperations")
    if ($cryptoOps) {
        return [System.Security.Cryptography.CryptographicOperations]::FixedTimeEquals($A, $B)
    }

    $diff = 0
    for ($i = 0; $i -lt $A.Length; $i++) {
        $diff = $diff -bor ($A[$i] -bxor $B[$i])
    }
    return ($diff -eq 0)
}

function Protect-File {
    param(
        [string]$InFile,
        [string]$OutFile,
        [byte[]]$PasswordBytes,
        [int]$IterationCount
    )

    $salt = New-RandomBytes -Length $SaltSize
    $iv = New-RandomBytes -Length $IvSize
    $keys = New-KeyMaterial -PasswordBytes $PasswordBytes -Salt $salt -IterationCount $IterationCount
    $plainBytes = [System.IO.File]::ReadAllBytes($InFile)

    $aes = [System.Security.Cryptography.Aes]::Create()
    $encryptor = $null
    try {
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        $aes.Key = $keys.EncKey
        $aes.IV = $iv
        $encryptor = $aes.CreateEncryptor()
        $cipherBytes = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
    } finally {
        if ($encryptor) { $encryptor.Dispose() }
        $aes.Dispose()
        [Array]::Clear($plainBytes, 0, $plainBytes.Length)
    }

    $header = Join-ByteArrays -Parts @($Magic, $salt, $iv)
    $macInput = Join-ByteArrays -Parts @($header, $cipherBytes)
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $keys.MacKey
    try {
        $tag = $hmac.ComputeHash($macInput)
    } finally {
        $hmac.Dispose()
    }

    $finalBytes = Join-ByteArrays -Parts @($macInput, $tag)
    [System.IO.File]::WriteAllBytes($OutFile, $finalBytes)

    [Array]::Clear($keys.EncKey, 0, $keys.EncKey.Length)
    [Array]::Clear($keys.MacKey, 0, $keys.MacKey.Length)
}

function Unprotect-File {
    param(
        [string]$InFile,
        [string]$OutFile,
        [byte[]]$PasswordBytes,
        [int]$IterationCount
    )

    $allBytes = [System.IO.File]::ReadAllBytes($InFile)
    $minimumLength = $Magic.Length + $SaltSize + $IvSize + $MacSize + 1
    if ($allBytes.Length -lt $minimumLength) {
        throw "Fajl je prekratak ili nije validan WUTENC2 format."
    }

    for ($i = 0; $i -lt $Magic.Length; $i++) {
        if ($allBytes[$i] -ne $Magic[$i]) {
            throw "Fajl nema WUTENC2 zaglavlje. Stari .enc format bez integriteta više nije podržan za automatsko dešifrovanje."
        }
    }

    $offset = $Magic.Length
    $salt = New-Object byte[] $SaltSize
    [Array]::Copy($allBytes, $offset, $salt, 0, $SaltSize)
    $offset += $SaltSize

    $iv = New-Object byte[] $IvSize
    [Array]::Copy($allBytes, $offset, $iv, 0, $IvSize)
    $offset += $IvSize

    $cipherLength = $allBytes.Length - $offset - $MacSize
    if ($cipherLength -le 0) { throw "Fajl nema šifrovani sadržaj." }

    $cipherBytes = New-Object byte[] $cipherLength
    [Array]::Copy($allBytes, $offset, $cipherBytes, 0, $cipherLength)

    $storedTag = New-Object byte[] $MacSize
    [Array]::Copy($allBytes, $allBytes.Length - $MacSize, $storedTag, 0, $MacSize)

    $macInput = New-Object byte[] ($allBytes.Length - $MacSize)
    [Array]::Copy($allBytes, 0, $macInput, 0, $macInput.Length)

    $keys = New-KeyMaterial -PasswordBytes $PasswordBytes -Salt $salt -IterationCount $IterationCount
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $keys.MacKey
    try {
        $computedTag = $hmac.ComputeHash($macInput)
    } finally {
        $hmac.Dispose()
    }

    if (-not (Test-FixedTimeEquals -A $storedTag -B $computedTag)) {
        throw "Provera integriteta nije uspela. Lozinka je netačna ili je fajl izmenjen."
    }

    $aes = [System.Security.Cryptography.Aes]::Create()
    $decryptor = $null
    try {
        $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
        $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
        $aes.Key = $keys.EncKey
        $aes.IV = $iv
        $decryptor = $aes.CreateDecryptor()
        $plainBytes = $decryptor.TransformFinalBlock($cipherBytes, 0, $cipherBytes.Length)
        [System.IO.File]::WriteAllBytes($OutFile, $plainBytes)
    } finally {
        if ($plainBytes) { [Array]::Clear($plainBytes, 0, $plainBytes.Length) }
        if ($decryptor) { $decryptor.Dispose() }
        $aes.Dispose()
        [Array]::Clear($keys.EncKey, 0, $keys.EncKey.Length)
        [Array]::Clear($keys.MacKey, 0, $keys.MacKey.Length)
    }
}

if (-not (Test-Path -LiteralPath $FilePath)) {
    Write-Host "Fajl ne postoji: $FilePath" -ForegroundColor Red
    return
}

$fileItem = Get-Item -LiteralPath $FilePath
if ($fileItem.PSIsContainer) {
    Write-Host "Navedena putanja je direktorijum. Skripta podržava samo pojedinačne fajlove." -ForegroundColor Red
    return
}

if (-not $Password) {
    $Password = Read-Host -AsSecureString "Unesite lozinku za šifrovanje/dešifrovanje"
}

if (-not $Password -or $Password.Length -eq 0) {
    Write-Host "Lozinka ne može biti prazna!" -ForegroundColor Red
    return
}

$passwordBytes = Convert-SecureStringToBytes -SecureValue $Password

try {
    if ($PSCmdlet.ParameterSetName -eq "Encrypt" -or $Encrypt) {
        $outFile = $FilePath + ".enc"
        if ($PSCmdlet.ShouldProcess($outFile, "Šifrovanje fajla '$FilePath'")) {
            Protect-File -InFile $fileItem.FullName -OutFile $outFile -PasswordBytes $passwordBytes -IterationCount $Iterations
            Write-Host "`nFajl je uspešno šifrovan i zaštićen HMAC proverom integriteta!" -ForegroundColor Green
            Write-Host "Izlazni fajl: $outFile" -ForegroundColor Yellow
        }
    } else {
        if ($FilePath.EndsWith(".enc")) {
            $outFile = $FilePath.Substring(0, $FilePath.Length - 4)
        } else {
            $outFile = Join-Path $fileItem.DirectoryName ($fileItem.BaseName + "_decrypted" + $fileItem.Extension)
        }

        if ($PSCmdlet.ShouldProcess($outFile, "Dešifrovanje fajla '$FilePath'")) {
            try {
                Unprotect-File -InFile $fileItem.FullName -OutFile $outFile -PasswordBytes $passwordBytes -IterationCount $Iterations
                Write-Host "`nFajl je uspešno dešifrovan!" -ForegroundColor Green
                Write-Host "Izlazni fajl: $outFile" -ForegroundColor Yellow
            } catch {
                if (Test-Path -LiteralPath $outFile) {
                    Remove-Item -LiteralPath $outFile -Force -ErrorAction SilentlyContinue
                }
                throw
            }
        }
    }
} catch {
    Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($passwordBytes) { [Array]::Clear($passwordBytes, 0, $passwordBytes.Length) }
}
