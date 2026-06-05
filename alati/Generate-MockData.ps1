# Generate-MockData.ps1 - Generisanje testnih lažnih podataka
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$Count = 50,
    [Parameter(Mandatory = $false)]
    [ValidateSet("json", "csv")]
    [string]$Format = "json"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Generišem $Count lažnih korisničkih zapisa (Format: $Format)..." -ForegroundColor Cyan

$firstNames = @("Marko", "Nikola", "Milan", "Luka", "Stefan", "Dragan", "Zoran", "Jovan", "Ana", "Marija", "Jelena", "Milica", "Ivana", "Dragana", "Olivera")
$lastNames = @("Jovanović", "Petrović", "Đorđević", "Ilić", "Stojanović", "Nikolić", "Popović", "Marković", "Kovačević", "Lukić", "Babić", "Mitrović")
$domains = @("gmail.com", "yahoo.com", "outlook.com", "company.local", "mail.ru")
$roles = @("Developer", "Designer", "Tester", "Project Manager", "DevOps Engineer", "Data Scientist")

$data = @()

for ($i = 1; $i -le $Count; $i++) {
    $fn = $firstNames[(Get-Random -Maximum $firstNames.Count)]
    $ln = $lastNames[(Get-Random -Maximum $lastNames.Count)]
    
    # Uklanjanje kvačica za email adresu
    $cleanFn = $fn.Replace("Đ","Dj").Replace("đ","dj").Replace("ć","c").Replace("č","c").Replace("š","s").Replace("ž","z").ToLower()
    $cleanLn = $ln.Replace("Đ","Dj").Replace("đ","dj").Replace("ć","c").Replace("č","c").Replace("š","s").Replace("ž","z").ToLower()
    $email = "$cleanFn.$cleanLn@$($domains[(Get-Random -Maximum $domains.Count)])"
    
    # Generisanje telefona +381
    $phone = "+381 6" + (Get-Random -Minimum 0 -Maximum 9) + " " + (Get-Random -Minimum 1000000 -Maximum 9999999)
    $role = $roles[(Get-Random -Maximum $roles.Count)]
    $salary = (Get-Random -Minimum 600 -Maximum 3500)
    
    $data += [PSCustomObject]@{
        ID = $i
        Ime = $fn
        Prezime = $ln
        Email = $email
        Telefon = $phone
        Uloga = $role
        PlataEur = $salary
    }
}

$destPath = Join-Path (Get-Location) "mock_users.$Format"

if ($Format -eq "json") {
    $json = ConvertTo-Json -InputObject $data -Depth 5
    $json | Set-Content -Path $destPath -Encoding utf8 -Force
} else {
    $data | Export-Csv -Path $destPath -NoTypeInformation -Encoding utf8 -Force
}

Write-Host "`n[+] Podaci uspešno generisani!" -ForegroundColor Green
Write-Host "Sačuvano u: $destPath" -ForegroundColor Gold