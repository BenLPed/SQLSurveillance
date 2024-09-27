function UpdateWindowsEvent {
    param(
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]$statusFilePath, # Stig til

        [Parameter(Mandatory = $true)]
        [string]$SQLAuditMonitor = "SQLAuditMonitor"
    )

    if($SQLAuditMonitor -eq "") {
        $SQLAuditMonitor = "SQLAuditMonitor"
    } else {
        $SQLAuditMonitor = $SQLAuditMonitor
    }

    $Status = Get-Json -statusFilePath $statusFilePath

    # Opdater JSON-filen 

    if(-not $Status.Windows) {
        $Windows = @{
            LogEvent = "SQLAuditMonitor"
        }

        $Status | Add-Member -MemberType NoteProperty -Name Windows -Value $Windows
    } else {
        $Status.Windows | Add-Member -MemberType NoteProperty -Name "WindowsEvent" -Value $SQLAuditMonitor
    }

    # Gem opdateringerne tilbage til JSON-filen
    $Status | ConvertTo-Json | Set-Content -Path $statusFilePath

    Write-Host "Audit '$auditName' created successfully on server '$serverInstance'. Logs will be stored at '$auditLogPath'." -ForegroundColor Yellow



}