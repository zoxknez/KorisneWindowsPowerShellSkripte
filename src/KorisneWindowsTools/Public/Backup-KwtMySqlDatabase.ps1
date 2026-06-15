function Backup-KwtMySqlDatabase {
    <#
    .SYNOPSIS
    Bezbedan i automatizovan bekap MySQL/MariaDB baze podataka.

    .DESCRIPTION
    Kreira SQL arhivu (.sql) izabrane baze podataka koristeći 'mysqldump' uslužni program.
    Podržava sigurne lozinke putem SecureString parametra, proverava izlazni kod procesa
    i vraća strukturisane metapodatke o bekapu (putanja, veličina, SHA-256 heš).

    .PARAMETER DatabaseName
    Naziv MySQL/MariaDB baze podataka koja se bekapuje.

    .PARAMETER Username
    Korisničko ime za pristup bazi podataka. Podrazumevano je "root".

    .PARAMETER Password
    Lozinka kao SecureString. Preporučena sigurna opcija.

    .PARAMETER Host
    Adresa servera baze podataka. Podrazumevano je "localhost".

    .PARAMETER OutputDirectory
    Direktorijum u koji će se smestiti bekap fajl. Podrazumevano je trenutni direktorijum.

    .OUTPUTS
    [PSCustomObject] sa detaljima o kreiranom bekapu.

    .EXAMPLE
    $secPass = Read-Host -AsSecureString
    Backup-KwtMySqlDatabase -DatabaseName "mojabaza" -Password $secPass
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DatabaseName,

        [Parameter(Mandatory = $false)]
        [string]$Username = "root",

        [Parameter(Mandatory = $false)]
        [System.Security.SecureString]$Password,

        [Parameter(Mandatory = $false)]
        [string]$Host = "localhost",

        [Parameter(Mandatory = $false)]
        [string]$OutputDirectory = (Get-Location)
    )

    begin {
        $started = Get-Date
        $success = $false
        $exitCode = $null
        $skipped = $false
        $tempDefaultsFile = $null

        # Provera da li je mysqldump dostupan u PATH-u
        $mysqldump = Get-Command mysqldump -ErrorAction SilentlyContinue
        if (-not $mysqldump) {
            Write-Error "Alat 'mysqldump' nije pronađen u sistemskom PATH-u. Instalirajte MySQL/MariaDB klijent."
            return
        }

        # Provera izlaznog direktorijuma
        if (-not (Test-Path $OutputDirectory -PathType Container)) {
            try {
                New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
            } catch {
                Write-Error "Nije moguće kreirati izlazni direktorijum: $($_.Exception.Message)"
                return
            }
        }

        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $outFile = Join-Path $OutputDirectory "mysql_${DatabaseName}_backup_${timestamp}.sql"
    }

    process {
        Write-Verbose "Započinjem bekap baze: $DatabaseName na hostu: $Host..."
        
        try {
            $argList = @()
            if ($null -ne $Password) {
                $plainPassword = [System.Net.NetworkCredential]::new("", $Password).Password
                $tempDefaultsFile = Join-Path ([System.IO.Path]::GetTempPath()) ("kwt-mysql-{0}.cnf" -f ([guid]::NewGuid().ToString("N")))
                $defaultsContent = @(
                    "[client]"
                    "host=$Host"
                    "user=$Username"
                    "password=$plainPassword"
                )
                Set-Content -Path $tempDefaultsFile -Value $defaultsContent -Encoding ASCII -Force
                $argList += "--defaults-extra-file=$tempDefaultsFile"
            } else {
                $argList += @("-h", $Host, "-u", $Username)
            }

            $argList += @("--databases", $DatabaseName)

            if ($PSCmdlet.ShouldProcess($DatabaseName, "Bekap MySQL/MariaDB baze u '$outFile'")) {
                $process = Start-Process -FilePath $mysqldump.Source -ArgumentList $argList -RedirectStandardOutput $outFile -Wait -NoNewWindow -PassThru
                $exitCode = $process.ExitCode
                $success = ($exitCode -eq 0 -and (Test-Path $outFile) -and (Get-Item $outFile).Length -gt 0)
            } else {
                $skipped = $true
            }
        } catch {
            Write-Error "Greška pri izvršavanju bekapa: $($_.Exception.Message)"
            $success = $false
            $exitCode = -1
        } finally {
            if ($plainPassword) {
                $plainPassword = $null
            }
            if ($tempDefaultsFile -and (Test-Path -LiteralPath $tempDefaultsFile)) {
                Remove-Item -LiteralPath $tempDefaultsFile -Force -ErrorAction SilentlyContinue
            }
        }
    }

    end {
        $finished = Get-Date
        $fileSize = 0
        $sha256 = ""

        if ($success) {
            $fileSize = (Get-Item $outFile).Length
            $sha256 = (Get-FileHash -Path $outFile -Algorithm SHA256).Hash
            Write-Verbose "Bekap MySQL baze je uspešno završen: $outFile"
        } elseif (-not $skipped) {
            Write-Error "Bekap MySQL baze nije uspeo. Izlazni kod: $exitCode"
        }

        return [PSCustomObject]@{
            DatabaseName    = $DatabaseName
            BackupFile      = $outFile
            FileSizeBytes   = $fileSize
            FileSizeMB      = [Math]::Round($fileSize / 1MB, 2)
            SHA256          = $sha256
            StartedAt       = $started
            FinishedAt      = $finished
            ExitCode        = $exitCode
            Skipped         = $skipped
            Success         = $success
        }
    }
}


