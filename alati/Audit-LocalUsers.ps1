[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Audit-LocalUsers.ps1 - Sigurnosni pregled lokalnih naloga i grupa
Write-Host "Pokrećem sigurnosnu reviziju lokalnih korisničkih naloga..." -ForegroundColor Cyan

try {
    # Dobijanje svih lokalnih korisnika
    $users = Get-LocalUser
    
    Write-Host "`nLOKALNI KORISNIČKI NALOZI:" -ForegroundColor Yellow
    $userList = @()
    foreach ($u in $users) {
        $status = if ($u.Enabled) { "AKTIVAN" } else { "Onemogućen" }
        $color = if ($u.Enabled) { "Green" } else { "DarkGray" }
        
        Write-Host "Korisnik: " -NoNewline -ForegroundColor White
        Write-Host "$($u.Name.PadRight(15))" -ForegroundColor Cyan -NoNewline
        Write-Host " | Status: " -NoNewline -ForegroundColor White
        Write-Host "$status" -ForegroundColor $color -NoNewline
        Write-Host " | Opis: $($u.Description)" -ForegroundColor Gray
    }
    
    # Dobijanje članova grupe Administratori
    Write-Host "`nČLANOVI GRUPE ADMINISTRATORI (Povišene privilegije):" -ForegroundColor Red
    $adminMembers = Get-LocalGroupMember -Group "Administrators"
    foreach ($m in $adminMembers) {
        Write-Host "  - $($m.Name) ($($m.ObjectClass))" -ForegroundColor White
    }
    Write-Host "`nSavet: Uklonite članove iz grupe Administrators koji ne bi smeli da imaju potpuni pristup sistemu." -ForegroundColor Yellow
} catch {
    Write-Host "Greška pri proveri lokalnih naloga: $($_.Exception.Message)" -ForegroundColor Red
}