
function Get-Json {
    param (
        # Parameter help description
        [Parameter(Mandatory = $true, HelpMessage = "Path to JSON file.")]
        [string]$statusFilePath
    )

    # Læs JSON-filen og konverter til PowerShell-objekt
    $status = Get-Content -Raw -Path $statusFilePath | ConvertFrom-Json

    return $status
}