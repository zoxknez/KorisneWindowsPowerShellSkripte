[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Test-MonitorPixels.ps1 - Test monitora za mrtve piksele
Write-Host "Testiranje ekrana za mrtve piksele..." -ForegroundColor Cyan
Write-Host "Skripta će otvoriti seriju ekrana u punoj boji." -ForegroundColor DarkGray
Write-Host "Pritisnite bilo koji taster za promenu boje (Crvena -> Zelena -> Plava -> Bela -> Crna)." -ForegroundColor Yellow
Write-Host "Unesite 'exit' u konzoli za prekid ili pritisnite Enter za početak." -ForegroundColor White

$start = Read-Host "Započni test?"
if ($start -eq "exit") { return }

try {
    # Učitavanje Windows Forms sklopova
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Definicije boja za test
    $colors = @(
        [System.Drawing.Color]::Red,
        [System.Drawing.Color]::Green,
        [System.Drawing.Color]::Blue,
        [System.Drawing.Color]::White,
        [System.Drawing.Color]::Black
    )
    
    $colorIndex = 0
    
    # Kreiranje Forme preko celog ekrana (Borderless Fullscreen)
    $form = New-Object System.Windows.Forms.Form
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
    $form.BackColor = $colors[$colorIndex]
    $form.TopMost = $true
    
    # Klik ili pritisak tastera menja boju
    $form.Add_Click({
        script:colorIndex++
        if ($script:colorIndex -ge $colors.Count) {
            $form.Close()
        } else {
            $form.BackColor = $colors[$script:colorIndex]
        }
    })
    
    $form.Add_KeyDown({
        script:colorIndex++
        if ($script:colorIndex -ge $colors.Count) {
            $form.Close()
        } else {
            $form.BackColor = $colors[$script:colorIndex]
        }
    })
    
    # Pokretanje forme
    [System.Windows.Forms.Application]::Run($form)
    Write-Host "`nTest monitora završen!" -ForegroundColor Green
} catch {
    Write-Host "Greška pri kreiranju prozora: $($_.Exception.Message)" -ForegroundColor Red
}