
# Funktion til at læse status fra JSON-fil
function Get-InstallStatus {

    param(
        [Parameter(Mandatory = $true, HelpMessage = "Path to JSON file.")]
        [string]$statusFilePath
    )

    JSON-StatusFile -statusFilePath $statusFilePath

    $status = Get-Json -statusFilePath $statusFilePath

    return $status.Installation.Installed
}