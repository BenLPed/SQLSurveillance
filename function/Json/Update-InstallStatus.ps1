
# Funktion til at opdatere status i JSON-fil

function Update-InstallStatus {

     [CmdletBinding()]
    param (
    [Parameter(Mandatory = $true, HelpMessage = "True or false. False is installation not is complete. True is installation is complete.")]
    [bool]$installed,

    [Parameter(Mandatory = $true, HelpMessage = "Path to JSON file.")]
    [string]$statusFilePath
)

    $status = Get-Json -statusFilePath $statusFilePath

    $status.Installation.Installed = $installed

    $status.SQL.DatabaseCreated = $installed

    $status | ConvertTo-Json | Set-Content -Path $statusFilePath

    if ($installed) {
        Write-Host "Installation status updated to: Installation fuldført" -ForegroundColor Yellow
        Write-Host "SQL Database status updated to: Database created" -ForegroundColor Yellow
    } else {
        Write-Host "Installation status updated to: Installation mislykkedes" -ForegroundColor Red
        Write-Host "SQL Database status updated to: Database ikke oprettet" -ForegroundColor Red
    }
}