# Check-CronFormat.ps1 - Validacija i sledeća izvršavanja standardnog 5-poljnog Cron izraza
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CronExpression,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 50)]
    [int]$Count = 5,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 3660)]
    [int]$SearchDays = 366
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$MonthNames = @{
    JAN = 1; FEB = 2; MAR = 3; APR = 4; MAY = 5; JUN = 6
    JUL = 7; AUG = 8; SEP = 9; OCT = 10; NOV = 11; DEC = 12
}
$DayNames = @{
    SUN = 0; MON = 1; TUE = 2; WED = 3; THU = 4; FRI = 5; SAT = 6
}

function Convert-CronToken {
    param(
        [string]$Token,
        [hashtable]$NameMap
    )

    $result = $Token.ToUpperInvariant()
    foreach ($key in $NameMap.Keys) {
        $result = $result -replace "\b$key\b", [string]$NameMap[$key]
    }
    return $result
}

function Parse-CronField {
    param(
        [string]$Field,
        [int]$Min,
        [int]$Max,
        [string]$Name,
        [switch]$NormalizeSunday
    )

    $values = New-Object System.Collections.Generic.SortedSet[int]
    $isWildcard = ($Field -eq "*")

    foreach ($part in ($Field -split ",")) {
        if ([string]::IsNullOrWhiteSpace($part)) {
            throw "Prazan segment u polju '$Name'."
        }

        $rangePart = $part
        $step = 1
        if ($part -match "^(.+)/(\d+)$") {
            $rangePart = $Matches[1]
            $step = [int]$Matches[2]
            if ($step -le 0) { throw "Korak u polju '$Name' mora biti veći od nule." }
        }

        if ($rangePart -eq "*") {
            $start = $Min
            $end = $Max
        } elseif ($rangePart -match "^(\d+)-(\d+)$") {
            $start = [int]$Matches[1]
            $end = [int]$Matches[2]
        } elseif ($rangePart -match "^\d+$") {
            $start = [int]$rangePart
            $end = [int]$rangePart
        } else {
            throw "Neispravan segment '$part' u polju '$Name'."
        }

        if ($NormalizeSunday) {
            if ($start -eq 7) { $start = 0 }
            if ($end -eq 7) { $end = 0 }
        }

        if ($start -lt $Min -or $start -gt $Max -or $end -lt $Min -or $end -gt $Max) {
            throw "Vrednost u polju '$Name' mora biti u opsegu $Min-$Max."
        }

        if ($start -gt $end) {
            throw "Opseg '$part' u polju '$Name' ide unazad."
        }

        for ($i = $start; $i -le $end; $i += $step) {
            [void]$values.Add($i)
        }
    }

    return [PSCustomObject]@{
        Values = $values
        IsWildcard = $isWildcard
    }
}

function Test-DayMatch {
    param(
        [datetime]$Date,
        $DayOfMonth,
        $DayOfWeek
    )

    $domMatch = $DayOfMonth.Values.Contains($Date.Day)
    $dowValue = [int]$Date.DayOfWeek
    $dowMatch = $DayOfWeek.Values.Contains($dowValue)

    if (-not $DayOfMonth.IsWildcard -and -not $DayOfWeek.IsWildcard) {
        return ($domMatch -or $dowMatch)
    }

    return ($domMatch -and $dowMatch)
}

Write-Host "Analiziram Cron izraz: $CronExpression..." -ForegroundColor Cyan

$normalizedExpression = ($CronExpression -replace "\s+", " ").Trim()
$parts = $normalizedExpression.Split(" ")
if ($parts.Length -ne 5) {
    Write-Host "Greška: Cron izraz mora imati tačno 5 polja razdvojenih razmakom!" -ForegroundColor Red
    Write-Host "Format: 'minut sat dan_u_mesecu mesec dan_u_nedelji'" -ForegroundColor Yellow
    return
}

try {
    $parts[3] = Convert-CronToken -Token $parts[3] -NameMap $MonthNames
    $parts[4] = Convert-CronToken -Token $parts[4] -NameMap $DayNames

    $minutes = Parse-CronField -Field $parts[0] -Min 0 -Max 59 -Name "minut"
    $hours = Parse-CronField -Field $parts[1] -Min 0 -Max 23 -Name "sat"
    $daysOfMonth = Parse-CronField -Field $parts[2] -Min 1 -Max 31 -Name "dan u mesecu"
    $months = Parse-CronField -Field $parts[3] -Min 1 -Max 12 -Name "mesec"
    $daysOfWeek = Parse-CronField -Field $parts[4] -Min 0 -Max 7 -Name "dan u nedelji" -NormalizeSunday

    Write-Host "`nCron izraz je validan. Sledeća vremena izvršavanja:" -ForegroundColor Yellow

    $found = 0
    $cursor = (Get-Date).AddMinutes(1)
    $cursor = Get-Date -Year $cursor.Year -Month $cursor.Month -Day $cursor.Day -Hour $cursor.Hour -Minute $cursor.Minute -Second 0
    $end = $cursor.AddDays($SearchDays)

    while ($cursor -le $end -and $found -lt $Count) {
        if ($months.Values.Contains($cursor.Month) -and
            $hours.Values.Contains($cursor.Hour) -and
            $minutes.Values.Contains($cursor.Minute) -and
            (Test-DayMatch -Date $cursor -DayOfMonth $daysOfMonth -DayOfWeek $daysOfWeek)) {
            Write-Host "  - $($cursor.ToString('dd.MM.yyyy HH:mm:00'))" -ForegroundColor Green
            $found++
        }

        $cursor = $cursor.AddMinutes(1)
    }

    if ($found -eq 0) {
        Write-Host "Nema izvršavanja u narednih $SearchDays dana." -ForegroundColor Yellow
    } elseif ($found -lt $Count) {
        Write-Host "Pronađeno je samo $found izvršavanja u narednih $SearchDays dana." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška pri analizi cron izraza: $($_.Exception.Message)" -ForegroundColor Red
}
