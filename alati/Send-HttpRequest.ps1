# Send-HttpRequest.ps1 - Slanje prilagođenih HTTP zahteva (cURL zamena)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Url,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("GET", "POST", "PUT", "DELETE")]
    [string]$Method = "GET",
    
    [Parameter(Mandatory = $false)]
    [string]$Body = ""
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Slanje HTTP zahteva..." -ForegroundColor Cyan
Write-Host "Metoda : $Method" -ForegroundColor White
Write-Host "Cilj   : $Url" -ForegroundColor White

# Isključujemo progres bar
$oldProgress = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

try {
    $headers = @{ "Content-Type" = "application/json" }
    
    $start = Get-Date
    if ($Method -eq "GET" -or $Method -eq "DELETE") {
        $response = Invoke-WebRequest -Uri $Url -Method $Method -Headers $headers -UseBasicParsing -ErrorAction Stop
    } else {
        $response = Invoke-WebRequest -Uri $Url -Method $Method -Headers $headers -Body $Body -UseBasicParsing -ErrorAction Stop
    }
    $duration = [Math]::Round(((Get-Date) - $start).TotalMilliseconds)
    
    $ProgressPreference = $oldProgress
    
    # Prikaz izveštaja
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "                   HTTP ODGOVOR                   " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    
    $statusColor = if ([int]$response.StatusCode -lt 300) { "Green" } else { "Red" }
    Write-Host "Status Kod     : " -NoNewline -ForegroundColor White
    Write-Host "$([int]$response.StatusCode) $($response.StatusDescription)" -ForegroundColor $statusColor
    Write-Host "Vreme trajanja : $duration ms" -ForegroundColor White
    
    Write-Host "`nSadržaj (Body):" -ForegroundColor Yellow
    $content = $response.Content
    if ($content.Length -gt 1000) { $content = $content.Substring(0, 997) + "..." }
    Write-Host $content -ForegroundColor White
    Write-Host "==================================================" -ForegroundColor Cyan
} catch {
    $ProgressPreference = $oldProgress
    Write-Host "`n[-] Zahtev nije uspeo!" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Kod: $([int]$_.Exception.Response.StatusCode)" -ForegroundColor Red
    } else {
        Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
    }
}