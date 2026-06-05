# Get-DnsRecords.ps1 - Čitanje DNS zapisa domena
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DomainName
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


$domain = $DomainName.Replace("https://", "").Replace("http://", "").Split("/")[0]
Write-Host "Čitam DNS zapise za domen: $domain..." -ForegroundColor Cyan

# Tipovi DNS zapisa koje proveravamo
$types = @("A", "AAAA", "MX", "TXT", "CNAME", "NS")

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "                  DNS ZAPISI (RECORDS)            " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

foreach ($t in $types) {
    try {
        $records = Resolve-DnsName -Name $domain -Type $t -ErrorAction SilentlyContinue
        if ($records) {
            Write-Host "[Type $t]:" -ForegroundColor Green
            foreach ($r in $records) {
                $value = switch ($t) {
                    "A" { $r.IPAddress }
                    "AAAA" { $r.IPAddress }
                    "MX" { "$($r.MailExchange) (Priority: $($r.Preference))" }
                    "TXT" { $r.Strings -join ' ' }
                    "CNAME" { $r.NameHost }
                    "NS" { $r.NameHost }
                }
                Write-Host "  - $value" -ForegroundColor White
            }
        }
    } catch {}
}
Write-Host "==================================================" -ForegroundColor Cyan