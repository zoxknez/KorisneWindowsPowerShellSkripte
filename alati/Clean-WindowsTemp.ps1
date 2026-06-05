[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Clean-WindowsTemp.ps1 - Generalno čišćenje Windows sistema
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Upozorenje: Ova skripta zahteva administratorske privilegije za čišćenje svih sistemskih privremenih fajlova." -ForegroundColor Yellow
    $confirm = Read-Host "Da li želite da pokrenete skriptu kao Administrator? (Y/N)"
    if ($confirm.ToUpper() -eq "Y") {
        try {
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        } catch {
            Write-Host "Nije moguće pokrenuti kao Administrator: $($_.Exception.Message)" -ForegroundColor Red
        }
        return
    } else {
        Write-Host "Nastavljam sa trenutnim privilegijama. Neki sistemski fajlovi neće moći da se obrišu.`n" -ForegroundColor Yellow
    }
}

Write-Host "Započinjem čišćenje privremenih Windows fajlova..." -ForegroundColor Cyan

function Clean-DirectoryContents {
    param([string]$dirPath)
    if (-not (Test-Path $dirPath)) { return 0 }
    
    $deletedBytes = 0
    Write-Host "Čišćenje foldera: $dirPath..." -ForegroundColor DarkGray
    
    try {
        $items = Get-ChildItem -Path $dirPath -Force -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            try {
                if (-not $item.PSIsContainer) {
                    $deletedBytes += $item.Length
                } else {
                    $subFiles = Get-ChildItem -Path $item.FullName -Recurse -File -Force -ErrorAction SilentlyContinue
                    foreach ($sf in $subFiles) { $deletedBytes += $sf.Length }
                }
                Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop | Out-Null
            } catch {}
        }
    } catch {}
    return $deletedBytes
}

$totalFreed = 0
$totalFreed += Clean-DirectoryContents -dirPath $env:TEMP
$totalFreed += Clean-DirectoryContents -dirPath "C:\Windows\Temp"

if ($isAdmin) {
    $totalFreed += Clean-DirectoryContents -dirPath "C:\Windows\Prefetch"
    $totalFreed += Clean-DirectoryContents -dirPath "C:\Windows\System32\LogFiles"
}

Write-Host "Pražnjenje kante za smeće..." -ForegroundColor DarkGray
try {
    Clear-RecycleBin -Force -ErrorAction Stop | Out-Null
    Write-Host "Kanta za smeće je ispražnjena." -ForegroundColor DarkGray
} catch {
    try {
        $sh = New-Object -ComObject Shell.Application
        $bin = $sh.Namespace(0xa)
        $bin.Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }
    } catch {}
}

$totalFreedMB = [Math]::Round($totalFreed / 1MB, 2)
Write-Host "`nČišćenje sistema je završeno!" -ForegroundColor Green
Write-Host "Oslobođeno oko $totalFreedMB MB prostora u privremenim folderima." -ForegroundColor Gold