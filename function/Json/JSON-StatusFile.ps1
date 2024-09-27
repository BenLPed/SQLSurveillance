# Funktion til at sikre, at statusmappen eksisterer
function JSON-StatusFile {
    param (
        [string]$statusFilePath
    )

    $statusFolder = Split-Path -Path $statusFilePath
    if (-not (Test-Path $statusFolder)) {
        New-Item -ItemType Directory -Path $statusFolder -Force
    }

    if (-not (Test-Path $statusFilePath)) {
        # Opret en standard status fil, hvis den ikke findes
        $status = @{
            Installation = @{ Installed = $false }
            SQL = @{
                DatabaseCreated = $false
            }
        }
        $status | ConvertTo-Json | Set-Content -Path $statusFilePath
    }
}