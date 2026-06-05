[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Clean-UnusedDocker.ps1 - Čišćenje Docker sistema
Write-Host "Provera Docker instalacije..." -ForegroundColor Cyan

$dockerCmd = Get-Command docker -ErrorAction SilentlyContinue

if (-not $dockerCmd) {
    Write-Host "Docker nije instaliran ili nije u PATH-u sistema!" -ForegroundColor Red
    return
}

# Provera da li je Docker daemon pokrenut
$dockerInfo = docker info 2>&1
if ($LastExitCode -ne 0) {
    Write-Host "Docker daemon nije pokrenut. Pokrenite Docker Desktop pa pokušajte ponovo." -ForegroundColor Red
    return
}

function Show-SubMenu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "               INTERAKTIVNI DOCKER ČISTAČ         " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "1. Obriši sve zaustavljene kontejnere"
    Write-Host "2. Obriši sve neiskorišćene (dangling) slike"
    Write-Host "3. Obriši sve neiskorišćene volumene (Volumes)"
    Write-Host "4. Obriši sve neiskorišćene mreže (Networks)"
    Write-Host "5. Sveobuhvatno čišćenje (Docker System Prune)"
    Write-Host "0. Nazad u glavni meni"
    Write-Host "==================================================" -ForegroundColor Cyan
}

do {
    Show-SubMenu
    $choice = Read-Host "Izbor"
    
    switch ($choice) {
        "1" {
            Write-Host "`nČistim zaustavljene kontejnere..." -ForegroundColor Yellow
            docker container prune -f
            Write-Host "Završeno!" -ForegroundColor Green
        }
        "2" {
            Write-Host "`nČistim dangling slike..." -ForegroundColor Yellow
            docker image prune -f
            Write-Host "Završeno!" -ForegroundColor Green
        }
        "3" {
            Write-Host "`nČistim neiskorišćene volumene..." -ForegroundColor Yellow
            docker volume prune -f
            Write-Host "Završeno!" -ForegroundColor Green
        }
        "4" {
            Write-Host "`nČistim neiskorišćene mreže..." -ForegroundColor Yellow
            docker network prune -f
            Write-Host "Završeno!" -ForegroundColor Green
        }
        "5" {
            Write-Host "`nPokrećem kompletno sistemsko čišćenje..." -ForegroundColor Red
            docker system prune -a --volumes -f
            Write-Host "Kompletno čišćenje završeno!" -ForegroundColor Green
        }
    }
    
    if ($choice -ne "0") {
        Write-Host ""
        Read-Host "Pritisnite Enter za nastavak..."
    }
} while ($choice -ne "0")