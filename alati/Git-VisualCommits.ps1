# Git-VisualCommits.ps1 - Prikaz prelepe Git istorije u konzoli
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$Count = 15
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
    Write-Host "Trenutni folder nije Git repozitorijum!" -ForegroundColor Red
    return
}

Write-Host "Prikazujem poslednjih $Count Git commit-a sa strukturom grana:`n" -ForegroundColor Cyan

try {
    # Pokretanje git loga sa bogatim formatom boja
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit -n $Count
    Write-Host ""
} catch {
    Write-Host "Greška pri čitanju Git istorije: $($_.Exception.Message)" -ForegroundColor Red
}