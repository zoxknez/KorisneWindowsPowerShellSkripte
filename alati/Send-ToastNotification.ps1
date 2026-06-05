# Send-ToastNotification.ps1 - Slanje Windows Toast notifikacija
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Title,
    [Parameter(Mandatory = $true)]
    [string]$Message,
    [Parameter(Mandatory = $false)]
    [string]$ImageUri = ""
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Slanje notifikacije..." -ForegroundColor Cyan

try {
    # Učitavanje potrebnih WinRT (Windows Runtime) tipova
    $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime]
    $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType=WindowsRuntime]
    
    # Izrada XML šablona za notifikaciju
    $template = [Windows.UI.Notifications.ToastTemplateType]::ToastImageAndText02
    $toastXml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
    
    # Postavljanje teksta (Naslov i Poruka)
    $textNodes = $toastXml.GetElementsByTagName("text")
    $textNodes.Item(0).AppendChild($toastXml.CreateTextNode($Title)) | Out-Null
    $textNodes.Item(1).AppendChild($toastXml.CreateTextNode($Message)) | Out-Null
    
    # Postavljanje slike ako je zadata
    if (-not [string]::IsNullOrEmpty($ImageUri) -and (Test-Path $ImageUri)) {
        $imageNodes = $toastXml.GetElementsByTagName("image")
        $imagePath = (Get-Item $ImageUri).FullName
        $imageNodes.Item(0).SetAttribute("src", "file:///$imagePath") | Out-Null
    }
    
    # Kreiranje i prikazivanje notifikacije
    # Koristimo generički AppId kako bismo prikazali sistemsku notifikaciju
    $appId = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"
    $toast = New-Object Windows.UI.Notifications.ToastNotification($toastXml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
    
    Write-Host "[+] Notifikacija uspešno poslata na desktop!" -ForegroundColor Green
} catch {
    Write-Host "Greška pri slanju notifikacije: $($_.Exception.Message)" -ForegroundColor Red
}