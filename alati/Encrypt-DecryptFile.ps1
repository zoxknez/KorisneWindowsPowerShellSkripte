# Encrypt-DecryptFile.ps1 - Šifrovanje i dešifrovanje fajlova (AES-256)
[CmdletBinding(DefaultParameterSetName = "Encrypt")]
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [Parameter(Mandatory = $false, ParameterSetName = "Encrypt")]
    [switch]$Encrypt,
    [Parameter(Mandatory = $false, ParameterSetName = "Decrypt")]
    [switch]$Decrypt
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $FilePath)) {
    Write-Host "Fajl ne postoji: $FilePath" -ForegroundColor Red
    return
}

$fileItem = Get-Item $FilePath
if ($fileItem.PSIsContainer) {
    Write-Host "Navedena putanja je direktorijum. Skripta podržava samo pojedinačne fajlove." -ForegroundColor Red
    return
}

$password = Read-Host -AsSecureString "Unesite lozinku za šifrovanje/dešifrovanje"
if (-not $password) {
    Write-Host "Lozinka ne može biti prazna!" -ForegroundColor Red
    return
}

$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

function Encrypt-File {
    param($InFile, $OutFile, $Pass)
    
    $salt = New-Object byte[] 16
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
    $rng.GetBytes($salt)
    
    $derive = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Pass, $salt, 10000)
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $derive.GetBytes(32)
    $aes.IV = $derive.GetBytes(16)
    
    $fsOut = New-Object System.IO.FileStream($OutFile, [System.IO.FileMode]::Create)
    $fsOut.Write($salt, 0, $salt.Length)
    
    $encryptor = $aes.CreateEncryptor()
    $cs = New-Object System.Security.Cryptography.CryptoStream($fsOut, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
    $fsIn = New-Object System.IO.FileStream($InFile, [System.IO.FileMode]::Open)
    
    $buffer = New-Object byte[] 4096
    while (($bytesRead = $fsIn.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $cs.Write($buffer, 0, $bytesRead)
    }
    
    $fsIn.Close()
    $cs.Close()
    $fsOut.Close()
    $aes.Dispose()
}

function Decrypt-File {
    param($InFile, $OutFile, $Pass)
    
    $fsIn = New-Object System.IO.FileStream($InFile, [System.IO.FileMode]::Open)
    
    $salt = New-Object byte[] 16
    $fsIn.Read($salt, 0, 16) | Out-Null
    
    $derive = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Pass, $salt, 10000)
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $derive.GetBytes(32)
    $aes.IV = $derive.GetBytes(16)
    
    $decryptor = $aes.CreateDecryptor()
    $fsOut = New-Object System.IO.FileStream($OutFile, [System.IO.FileMode]::Create)
    $cs = New-Object System.Security.Cryptography.CryptoStream($fsIn, $decryptor, [System.Security.Cryptography.CryptoStreamMode]::Read)
    
    try {
        $buffer = New-Object byte[] 4096
        while (($bytesRead = $cs.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $fsOut.Write($buffer, 0, $bytesRead)
        }
    } catch {
        throw $_
    } finally {
        $fsOut.Close()
        $cs.Close()
        $fsIn.Close()
        $aes.Dispose()
    }
}

if ($PSCmdlet.ParameterSetName -eq "Encrypt" -or $Encrypt) {
    $outFile = $FilePath + ".enc"
    Write-Host "`nŠifrujem fajl: $FilePath..." -ForegroundColor Cyan
    try {
        Encrypt-File -InFile $FilePath -OutFile $outFile -Pass $plainPassword
        Write-Host "Fajl je uspešno šifrovan!" -ForegroundColor Green
        Write-Host "Izlazni fajl: $outFile" -ForegroundColor Gold
    } catch {
        Write-Host "Greška pri šifrovanju: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    $outFile = ""
    if ($FilePath.EndsWith(".enc")) {
        $outFile = $FilePath.Substring(0, $FilePath.Length - 4)
    } else {
        $outFile = Join-Path $fileItem.DirectoryName ($fileItem.BaseName + "_decrypted" + $fileItem.Extension)
    }
    
    Write-Host "`nDešifrujem fajl: $FilePath..." -ForegroundColor Cyan
    try {
        Decrypt-File -InFile $FilePath -OutFile $outFile -Pass $plainPassword
        Write-Host "Fajl je uspešno dešifrovan!" -ForegroundColor Green
        Write-Host "Izlazni fajl: $outFile" -ForegroundColor Gold
    } catch {
        if (Test-Path $outFile) { Remove-Item $outFile -Force }
        Write-Host "Greška pri dešifrovanju! Lozinka je verovatno netačna ili je fajl oštećen." -ForegroundColor Red
    }
}