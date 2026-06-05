# Start-LocalApiMock.ps1 - Pokretanje lokalnog mock HTTP servera za testiranje API-ja
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [int]$Port = 8085
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


$url = "http://localhost:$Port/"
Write-Host "Pokrećem lokalni API Mock Server na adresi: $url" -ForegroundColor Cyan
Write-Host "Server će vraćati lažne JSON podatke za bilo koji zahtev." -ForegroundColor DarkGray
Write-Host "Pritisnite bilo koji taster u konzoli za gašenje servera...`n" -ForegroundColor Yellow

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)

try {
    $listener.Start()
    Write-Host "[+] Server je pokrenut i sluša..." -ForegroundColor Green
    
    # Asinhrona petlja koja sluša zahteve
    while (-not [System.Console]::KeyAvailable) {
        $contextAsync = $listener.BeginGetContext($null, $null)
        
        # Čekamo zahtev ili pritisak tastera (provera na svakih 500ms)
        while (-not $contextAsync.IsCompleted -and -not [System.Console]::KeyAvailable) {
            Start-Sleep -Milliseconds 200
        }
        
        if ($contextAsync.IsCompleted) {
            $context = $listener.EndGetContext($contextAsync)
            $request = $context.Request
            $response = $context.Response
            
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Zahtev primljen: $($request.HttpMethod) $($request.Url.PathAndQuery)" -ForegroundColor White
            
            # Lažni JSON odgovor
            $mockData = @{
                status = "success"
                timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                requestMethod = $request.HttpMethod
                requestPath = $request.Url.PathAndQuery
                message = "Pozdrav sa lokalnog Windows Utility Toolkit API servera!"
                data = @(
                    @{ id = 1; ime = "Marko"; uloga = "Developer" },
                    @{ id = 2; ime = "Ana"; uloga = "Dizajner" },
                    @{ id = 3; ime = "Petar"; uloga = "Menadžer" }
                )
            }
            
            $jsonString = ConvertTo-Json -InputObject $mockData
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($jsonString)
            
            $response.ContentType = "application/json"
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.OutputStream.Close()
        }
    }
    # Čišćenje bafera tastature
    $null = [System.Console]::ReadKey($true)
} catch {
    Write-Host "Greška na serveru: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($listener.IsListening) {
        $listener.Stop()
        $listener.Close()
        Write-Host "`nAPI Mock Server je ugašen." -ForegroundColor Red
    }
}