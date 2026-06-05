# Merge-PdfFiles.ps1 - Spajanje više PDF dokumenata u jedan
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$PdfFiles,
    [Parameter(Mandatory = $true)]
    [string]$OutputFile
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# Za napredno spajanje PDF-a u čistom PowerShell-u bez modula koristimo .NET Word ili PdfSharp ako su dostupni.
# Kako bismo izbegli zavisnosti od eksternih dll-ova, koristićemo ugrađeni Windows COM objekat za Microsoft Word
# koji može da otvori PDF-ove i spoji ih, pa sačuva kao PDF! Ovo je genijalno rešenje dostupno na svakom računaru sa Office-om!
Write-Host "Započinjem spajanje PDF dokumenata..." -ForegroundColor Cyan

try {
    Write-Host "Pokrećem Microsoft Word COM objekat u pozadini..." -ForegroundColor DarkGray
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false
    
    # Kreiramo novi prazan dokument
    $mainDoc = $word.Documents.Add()
    
    foreach ($file in $PdfFiles) {
        $fullPath = (Get-Item $file).FullName
        Write-Host "Dodajem dokument: $fullPath..." -ForegroundColor DarkGray
        
        # Word može da uveze sadržaj PDF-a
        $mainDoc.InsertFile($fullPath)
    }
    
    $outPath = (Get-Item (Split-Path $OutputFile)).FullName
    $finalOut = Join-Path $outPath (Split-Path $OutputFile -Leaf)
    
    # Snimamo dokument kao PDF (17 je konstanta za PDF format u Word-u)
    $mainDoc.SaveAs([ref]$finalOut, [ref]17)
    $mainDoc.Close([ref]$false)
    $word.Quit()
    
    Write-Host "`n[+] Dokumenti uspešno spojeni!" -ForegroundColor Green
    Write-Host "Izlazni fajl: $finalOut" -ForegroundColor Gold
} catch {
    if ($word) { $word.Quit() }
    Write-Host "Greška pri spajanju: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Napomena: Ova skripta zahteva instaliran Microsoft Word na računaru." -ForegroundColor Yellow
}