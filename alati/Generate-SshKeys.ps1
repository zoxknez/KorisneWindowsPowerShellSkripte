# Generate-SshKeys.ps1 - Generisanje SSH ključeva (ED25519)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CommentEmail
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


$sshDir = Join-Path $env:USERPROFILE ".ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

$keyPath = Join-Path $sshDir "id_ed25519"
Write-Host "Generišem kriptografski siguran SSH ključ (ED25519)..." -ForegroundColor Cyan
Write-Host "Email/Komentar : $CommentEmail" -ForegroundColor White
Write-Host "Lokacija ključa: $keyPath" -ForegroundColor White

try {
    # Pokretanje ssh-keygen
    if (Get-Command ssh-keygen -ErrorAction SilentlyContinue) {
        Write-Host "`nPokrećem ssh-keygen..." -ForegroundColor DarkGray
        # -t ed25519 (tip), -C (komentar), -f (izlazni fajl), -N "" (prazna lozinka po defaultu)
        & ssh-keygen -t ed25519 -C $CommentEmail -f $keyPath -N ""
        
        $publicKeyPath = $keyPath + ".pub"
        if (Test-Path $publicKeyPath) {
            $pubKey = Get-Content -Path $publicKeyPath -Raw
            # Kopiranje javnog ključa u clipboard za lakši uvoz na GitHub/GitLab
            $pubKey | clip.exe
            
            Write-Host "`n[+] SSH ključ uspešno generisan!" -ForegroundColor Green
            Write-Host "JAVNI KLJUČ (Kopiran je u Vaš Clipboard):" -ForegroundColor Gold
            Write-Host $pubKey -ForegroundColor Green
        }
    } else {
        Write-Host "Alat ssh-keygen nije instaliran na ovom sistemu (instalirajte Git ili OpenSSH)." -ForegroundColor Red
    }
} catch {
    Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
}