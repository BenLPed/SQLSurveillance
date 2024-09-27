function AktivateAudit {
    param(
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]$statusFilePath # Stig til
    )

    $Status = Get-Json -statusFilePath $statusFilePath

    # Hent serverinstansen fra JSON-filen
    $serverInstance = $status.SQL.ServerInstance

    # Læs og valider auditLogPath
    $auditName = $status.SQL.AuditName

    # Læs og valider auditLogPath
    $auditSpecName = $status.SQL.AuditSpecName

    try {
        # Aktivér auditen
        Invoke-Sqlcmd -Query "
        ALTER SERVER AUDIT [$auditName] WITH (STATE = ON);
        " -ServerInstance $serverInstance

        Write-Host "Audit '$auditName' activated successfully on server '$serverInstance'." -ForegroundColor Yellow
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "Failed to activate audit '$auditName' on server '$serverInstance'." -ForegroundColor Red
        Write-Host "Tjek at du har Write and create access til mappen på serveren." -ForegroundColor Red
        Write-Host "Error: $_"
    }

    try {
        # Aktivér audit-specifikationen
        Invoke-Sqlcmd -Query "
        ALTER SERVER AUDIT SPECIFICATION [$auditSpecName] WITH (STATE = ON);
        " -ServerInstance $serverInstance

        Write-Host "Audit-specifikation '$auditSpecName' activated successfully on server '$serverInstance'." -ForegroundColor Yellow
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "Failed to activate audit specifikation '$auditSpecName' on server '$serverInstance'." -ForegroundColor Red
        Write-Host "Tjek at du har Write and create access til mappen på serveren." -ForegroundColor Red
        Write-Host "Error: $_"
    }
}