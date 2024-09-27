
function Update-ServerInstance {
    param (
        [Parameter(Mandatory = $true)]
        [string]$statusFilePath,
        [Parameter(Mandatory = $true)]
        [string]$serverInstance
    )

    # Læs den eksisterende JSON-fil
    $status = Get-Json -statusFilePath $statusFilePath

    # Tjek om SQL-sektionen eksisterer
    if (-not $status.SQL.ServerInstance) {
        # Hvis SQL-sektionen ikke eksisterer, opret den med en tom struktur
        Write-Host "ServerInstance-sektionen eksisterer ikke. Opdaterer..." -ForegroundColor Green -NoNewline
        $status.SQL | Add-Member -MemberType NoteProperty -Name "ServerInstance" -Value $serverInstance
    } else {
        # Opdater ServerInstance-værdien, hvis det allerede eksisterer
        $status.SQL.ServerInstance = $serverInstance
    }

    # Gem den opdaterede JSON tilbage til filen
    $status | ConvertTo-Json -Depth 10 | Set-Content -Path $statusFilePath -Force
    Write-Host "ServerInstance gemt... $($serverInstance)" -ForegroundColor Green
}