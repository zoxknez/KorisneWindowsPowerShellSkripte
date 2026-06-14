function Backup-KwtMySqlDatabase {
    <#
    .SYNOPSIS
    Bezbedan i automatizovan bekap MySQL/MariaDB baze podataka.

    .DESCRIPTION
    Kreira SQL arhivu (.sql) izabrane baze podataka koristeći 'mysqldump' uslužni program.
    Podržava sigurne lozinke putem SecureString parametra, proverava izlazni kod procesa ($LASTEXITCODE)
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
    [CmdletBinding()]
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

        # Provera da li je mysqldump dostupan u PATH-u
        if (-not (Get-Command mysqldump -ErrorAction SilentlyContinue)) {
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
            # Konverzija SecureString u plain text za prosleđivanje mysqldump komandi
            $passArg = ""
            if ($null -ne $Password) {
                $plainPassword = [System.Net.NetworkCredential]::new("", $Password).Password
                $passArg = "-p$plainPassword"
            }

            # Izvršavanje mysqldump
            # Koristimo cmd.exe za redirekciju izlaza kako bismo izbegli PowerShell kodni encoding problem
            $cmdArgs = "/c mysqldump -h $Host -u $Username $passArg --databases $DatabaseName > `"$outFile`""
            
            Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArgs -Wait -NoNewWindow
            
            $exitCode = $LASTEXITCODE
            $success = ($exitCode -eq 0 -and (Test-Path $outFile) -and (Get-Item $outFile).Length -gt 0)
        } catch {
            Write-Error "Greška pri izvršavanju bekapa: $($_.Exception.Message)"
            $success = $false
            $exitCode = -1
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
        } else {
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
            Success         = $success
        }
    }
}


