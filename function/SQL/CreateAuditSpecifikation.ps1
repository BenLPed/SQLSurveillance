# Opret en audit, der definerer, hvor logdataene skal gemmes:

function CreateAuditSpecifikation {
    param(
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]$statusFilePath, # Stig til

        # Parameter help description
        [Parameter(Mandatory = $false)]
        [string]$auditSpecName = "Login_Audit_Spec"
    )

    if($auditSpecName -eq "") {
        $auditSpecName = "Login_Audit_Spec"
    } else {
        $auditSpecName = $auditSpecName
    }

    # Læs JSON-filen og konverter til PowerShell-objekt
    $status = Get-Json -statusFilePath $statusFilePath

    # Hent serverinstansen fra JSON-filen
    $serverInstance = $status.SQL.ServerInstance

    # Læs og valider auditLogPath
    $auditName = $status.SQL.AuditName
    
    try {
        Invoke-Sqlcmd -Query "
        CREATE SERVER AUDIT SPECIFICATION [$auditSpecName]
        FOR SERVER AUDIT [$auditName]
        ADD (FAILED_LOGIN_GROUP),
        ADD (SUCCESSFUL_LOGIN_GROUP);
        " -ServerInstance $serverInstance

        # Tilføjer AuditSpecName
        $status.SQL | Add-Member -MemberType NoteProperty -Name "AuditSpecName" -Value $auditSpecName

        # Gem opdateringerne tilbage til JSON-filen
        $status | ConvertTo-Json -Depth 10 | Set-Content -Path $statusFilePath -Force

        Write-Host "Audit-specifikation $auditSpecName created successfully on server '$serverInstance'." -ForegroundColor Yellow
            
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "Cant find the database." -ForegroundColor Red
    }
}