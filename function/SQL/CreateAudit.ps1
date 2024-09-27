# Opret en audit, der definerer, hvor logdataene skal gemmes:

function CreateAudit {
    param(
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]$auditLogPath, # Sti til audit-loggen

        [string]$auditName = "Login_Audit", #Navn på audit
        [string]$statusFilePath # Stig til
    )

    if($auditName -eq "") {
        $auditName = "Login_Audit"
    } else {
        $auditName = $auditSpecName
    }

    $Status = Get-Json -statusFilePath $statusFilePath

    # Hent serverinstansen fra JSON-filen
    $serverInstance = $status.SQL.ServerInstance

    try {
        Invoke-Sqlcmd -Query "
        CREATE SERVER AUDIT [$auditName]
        TO FILE (FILEPATH = N'$auditLogPath')
        WITH (ON_FAILURE = CONTINUE);
        " -ServerInstance $serverInstance

        # Opdater JSON-filen med auditLogPath, hvis det er angivet
        if ($auditLogPath) {
            $status.SQL | Add-Member -MemberType NoteProperty -Name "AuditLogPath" -Value $auditLogPath
        }

        # Opdater JSON-filen med auditName, hvis det er angivet, ellers brug standardværdien
        if ($auditName) {
            $status.SQL | Add-Member -MemberType NoteProperty -Name "AuditName" -Value $auditName
        }
        #else {
        #    $status.SQL.AuditName = "Login_Audit"  # Brug standard auditnavn
        #}

        # Gem opdateringerne tilbage til JSON-filen
        $status | ConvertTo-Json | Set-Content -Path $statusFilePath

        Write-Host "Audit '$auditName' created successfully on server '$serverInstance'. Logs will be stored at '$auditLogPath'." -ForegroundColor Yellow
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "Cant find the database." -ForegroundColor Red
    }
}