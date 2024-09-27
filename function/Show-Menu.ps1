# Menu-funktion
function Show-Menu {

    param (
        [Parameter(Mandatory = $true, HelpMessage = "Path to JSON file.")]
        [string]$statusFilePath
    )

    Clear-Host
    Write-Host "====================================" -ForegroundColor Yellow
    Write-Host "          VALGMULIGHEDER            " -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Yellow

    if (-not (Get-InstallStatus -statusFilePath $statusFilePath)) {
        Write-Host "1. Install" -ForegroundColor Green
    } else {
        Write-Host "2. Run" -ForegroundColor Green
        Write-Host "3. Update" -ForegroundColor Green
    }

    Write-Host "4. Exit" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Yellow
    $choice = Read-Host "Vælg en handling"
    return $choice
}
