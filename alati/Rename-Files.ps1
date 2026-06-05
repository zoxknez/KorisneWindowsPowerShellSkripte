# Rename-Files.ps1 - Masovno preimenovanje fajlova
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),
    [Parameter(Mandatory = $false)]
    [string]$Prefix,
    [Parameter(Mandatory = $false)]
    [string]$Suffix,
    [Parameter(Mandatory = $false)]
    [string]$ReplaceText,
    [Parameter(Mandatory = $false)]
    [string]$WithText = ""
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

$files = Get-ChildItem -Path $Path -File -Force -ErrorAction SilentlyContinue

if ($files.Count -eq 0) {
    Write-Host "Nema fajlova za preimenovanje u folderu: $Path" -ForegroundColor Yellow
    return
}

Write-Host "Pronađeno $($files.Count) fajlova za analizu.`n" -ForegroundColor Cyan

$renameList = @()

foreach ($file in $files) {
    $oldName = $file.Name
    $ext = $file.Extension
    $baseName = $file.BaseName
    
    $newName = $baseName
    
    if (-not [string]::IsNullOrEmpty($ReplaceText)) {
        $newName = $newName.Replace($ReplaceText, $WithText)
    }
    
    if (-not [string]::IsNullOrEmpty($Prefix)) {
        $newName = $Prefix + $newName
    }
    if (-not [string]::IsNullOrEmpty($Suffix)) {
        $newName = $newName + $Suffix
    }
    
    $newName = $newName + $ext
    
    if ($oldName -ne $newName) {
        $renameList += [PSCustomObject]@{
            Original = $oldName
            Novo     = $newName
            Putanja  = $file.FullName
        }
    }
}

if ($renameList.Count -eq 0) {
    Write-Host "Nijedan fajl ne ispunjava uslove za preimenovanje (nazivi bi ostali isti)." -ForegroundColor Green
    return
}

Write-Host "Predlog preimenovanja:" -ForegroundColor Yellow
$renameList | Format-Table -Property Original, Novo -AutoSize

$confirm = Read-Host "Da li želite da primenite ove izmene? (Y/N)"
if ($confirm.ToUpper() -eq "Y") {
    $success = 0
    $errors = 0
    foreach ($item in $renameList) {
        try {
            Rename-Item -Path $item.Putanja -NewName $item.Novo -Force -ErrorAction Stop
            $success++
        } catch {
            Write-Host "Greška pri preimenovanju $($item.Original): $($_.Exception.Message)" -ForegroundColor Red
            $errors++
        }
    }
    Write-Host "`nPreimenovanje završeno!" -ForegroundColor Green
    Write-Host "Uspešno preimenovano: $success fajlova." -ForegroundColor Green
    if ($errors -gt 0) {
        Write-Host "Greške pri preimenovanju: $errors fajlova." -ForegroundColor Red
    }
} else {
    Write-Host "Operacija otkazana." -ForegroundColor Red
}