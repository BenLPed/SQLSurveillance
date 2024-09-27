#
# Scriptet køres ved at man f.eks skriver:
#   Powershell.exe -File index.ps1 install
#   Index.ps1
#   Index.ps1 install
#   Index.ps1 -Action install osv.
#
#

# Definer parametre
param (
    [string]$Action

)
<#
    $Action = "install"
    $Action = "Test"
    $Action = "Run"
    $Action = ""
#>

$RootPath = $PSScriptRoot

# Import af alle funktioner
$PSRoot = Join-Path $RootPath function

<#
    # Manualt

    $RootPath = "\\localhost\PowerShell$\Github\Script\SQL\Overvågning"
    $PSRoot = Join-Path \\localhost\PowerShell$\Github\Script\SQL\Overvågning function
#>


# Få stien til brugerens PowerShell profilmappe
# $statusFilePath = Join-Path -Path $env:USERPROFILE -ChildPath ".psloadmodule\status.json"

# Systemomfattende placering i ProgramData
$statusFilePath = "C:\ProgramData\PowerShellScript\SQLSurveillance\status.json"

# Import of all ps1 files
Get-ChildItem -Path $PSRoot -Filter *.ps1 -Recurse | ForEach-Object {
    # Dot-source hver funktion for at indlæse den i den aktuelle session
    . $_.FullName
}

# Installer PSLoadModule her
if (-not (Get-Module -Name PSLoadModule -ListAvailable)) {
    Write-Host "PSLoadModule ikke installeret. Installer..." -ForegroundColor Yellow -NoNewline
    Install-Module -Name PSLoadModule -Force
    Write-Host " " -NoNewline
    Write-Host "Installation fuldført." -ForegroundColor Green
    Write-Host "PSLoadModule importeret." -ForegroundColor Green
    import-module -name PSLoadModule
} else {
    Write-Host "PSLoadModule importeres." -ForegroundColor Green
    import-module -name PSLoadModule
    Write-host "PSLoadModule importeret." -ForegroundColor Green
}

# Import of Module
Ensure-Module -ModuleName "SQLserver"

Ensure-Module -ModuleName "BurntToast"

# Tjek om brugeren er administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Scriptet skal køres som administrator !" -ForegroundColor Red
    Start-Sleep -Seconds 3
    Exit
} else {

    # Hovedscriptet
    if (-not $Action) {
        $userChoice = Show-Menu -statusFilePath $statusFilePath

        switch ($userChoice) {
            1 { $Action = "install" }
            2 { $Action = "run" }
            3 { $Action = "update" }
            4 { Write-Host "Afslutter..." -ForegroundColor Red; exit }
            default { Write-Host "Ugyldigt valg" -ForegroundColor Red; exit }
        }
    }

    switch ($Action.ToLower()) {
        "install" {
            Write-Host "Installation påbegyndt..." -ForegroundColor Green
            Start-Sleep -Seconds 1
<#
            # Is JSON file already created?
            Write-Host "Installerer statusfil..." -ForegroundColor Green
            Get-InstallStatus -statusFilePath $statusFilePath
            Write-Host "Statusfil gemt..." -ForegroundColor Green
#>

            # Find server instance
            Write-Host "Finder serverinstance..." -ForegroundColor Green -NoNewline
            $serverInstance = Get-ServerInstance
            # $serverInstance = "SQL01"

            if($serverInstance -eq "NoDatabase") {
                Write-Host "Ingen Database blev fundet, vi stopper her." -ForegroundColor Green

                # // TODO skal vi evt. lave en menu, hvor man får mulighed for at angive en ServerInstance, hvis man mener at det er en fejl.
                Exit;
            } else {

                Write-Host "ServerInstance: $serverInstance" -ForegroundColor Green

                Write-Host "Gemmer ServerInstance..." -ForegroundColor Green
                Update-ServerInstance -serverInstance $serverInstance -statusFilePath $statusFilePath

                # Install SQLAudit i SQL Server
                Write-Host "Installerer SQLAudit..." -ForegroundColor Green
                Write-Host "Du skal nu angiv en sti til audit-loggen... f.eks. kunne den ligger samme sted som databasen eller logfilen. Angiv en gyldig stig her." -ForegroundColor Green
                Write-Host "Sikre dig at du har write & create access til denne sti. Ellers kan du ikke oprette en audit." -ForegroundColor Green

                # Læs og valider auditLogPath
                do {
                    $auditLogPath = Read-Host "Indtast her: (kan ikke være tom)"
                    if (-not $auditLogPath) {
                        Write-Host "Sti til audit-log må ikke være tom. Prøv igen." -ForegroundColor Red
                    }
                } while (-not $auditLogPath)

                Write-Host "Som default vil din Audio hedder Login_Audit. Hvis du ønsker at ændre navnet, skriv den her. (f.eks. Login_logging) Ellers tryk enter" -ForegroundColor Green
                $AuditName = Read-Host "Indtast her"

                #CreateSQLAudit($Answer)($statusFilePath)
                CreateAudit -auditLogPath $auditLogPath -auditName $AuditName -statusFilePath $statusFilePath

                Write-Host "Opretter Audit-specifikation..." -ForegroundColor Green
                Write-Host "Som default vil din Audit-specifikation hedder Login_Audit_Spec. Hvis du ønsker at ændre navnet, skriv den her. (f.eks. Login_Audit_logging) Ellers tryk enter" -ForegroundColor Green
                $auditSpecName = Read-Host "Indtast her"
                CreateAuditSpecifikation -statusFilePath $statusFilePath -auditSpecName $auditSpecName

                Write-Host "Aktiverer Audit and Audit Specifikation..." -ForegroundColor Green
                AktivateAudit -statusFilePath $statusFilePath

                Write-Host "Opretter Log i eventlog..." -ForegroundColor Green
                Write-Host "Hvis du har et navne ønske, tast det her eller tryk enter, default er SQLAuditMonitor" -ForegroundColor Green
                $SQLAuditMonitor = Read-Host "Skriv her" 

                UpdateWindowsEvent -statusFilePath $statusFilePath -SQLAuditMonitor $SQLAuditMonitor

                Write-Host "Installation fuldføres." -ForegroundColor Green
                Update-InstallStatus -installed $true -statusFilePath $statusFilePath
            }

            Write-Host "Installation afsluttet. for at gå videre, skal du køre scriptet igen og vælg næste punkt du ønsker." -ForegroundColor Green
            Write-Host "Tryk på en hvilken som helst tast for at afslutte..."
            [System.Console]::ReadKey($true)
        }

        "Run" {
            Write-Host "Overvågning påbegynder..." -ForegroundColor Green
            $JsonFile = Get-Json -statusFilePath $statusFilePath
            $JsonFile.SQL
            if($JsonFile.SQL.DatabaseCreated) {
                $auditLogPath = $JsonFile.SQL.AuditLogPath
                $auditName = $JsonFile.SQL.AuditName
                $logPath = Get-ChildItem -Path $auditLogPath -filter "$auditName*"
                # Join-Path $auditLogPath $auditName # "{0}\{1}" -f $auditLogPath, $auditName

            }

            $previousLog = Get-Content $logPath
            
            while ($true) {
                $currentLog = Get-Content $logPath
                if ($currentLog -ne $previousLog) {
                    
<#
                    # 1.
                    # Log hændelsen til en ekstern logfil
                    $logMessage = "$(Get-Date): Ændring opdaget i SQL Server Audit-loggen."
                    $logFilePath = Join-Path $auditLogPath AuditMonitorLog.txt
                    
                    # Tilføj hændelsen til en logfil
                    Add-Content -Path $logFilePath -Value $logMessage
#>

                    # 2.
                    # Definer e-mail parametre
                    $to = "blpe@eucsj.dk"
                    $from = "Sqlsurveillance@eucsj.dk"
                    $subject = "SQL Server Audit Logændring Opdaget"
                    $body = "Der er opdaget en ændring i SQL Server audit-loggen. Tjek loggen for detaljer."
                    $smtpServer = "eucsj-dk.mail.protection.outlook.com"
            
                    # Send e-mail
                    Send-MailMessage -To $to -From $from -Subject $subject -Body $body -SmtpServer $smtpServer
<#          
                    # 3. Windows Notifikation

                    # Install-Module -Name BurntToast -Scope CurrentUser

                    # Vis en notifikation på systemet
                    # New-BurntToastNotification -Text "SQL Server Audit", "Ændring opdaget i audit-loggen."

#>

<#
                    # 4. 
                    # Find forskellene mellem de to logfiler
                    $changes = Compare-Object -ReferenceObject $previousLog -DifferenceObject $currentLog

                    # Log forskellene til en ekstern fil eller vis på skærmen
                    $logFilePath = "C:\AuditLogs\DetailedChanges.txt"
                    $changes | Out-File -FilePath $logFilePath -Append

                    # Vis forskellene i konsollen
                    $changes | Format-Table -AutoSize
#>

<#
                    # 5.
                    # Log til Windows Event Log
                    $source = "SQLAuditMonitor"
                    $logName = "Application"

                    # Tjek om kilden allerede findes
                    if (-not [System.Diagnostics.EventLog]::SourceExists($source)) {
                        # Hvis kilden ikke eksisterer, opret den
                        New-EventLog -LogName $source -Source $source

                        Write-EventLog -LogName $source -Source $source -EventId 45000 -EntryType Information -Category 0 -Message "Denne Log er nu blevet operttet på $($env:COMPUTERNAME) af bruger $($env:USERNAME)."
                    } else {

                        Write-EventLog -LogName $source -Source $source -EventId 45000 -EntryType Warning -Category 0 -Message "Ændring opdaget i SQL Server Audit-loggen."
                        Write-EventLog -LogName $source -Source $source -EventId 45000 -EntryType Error -Category 0 -Message "Dette er en testbesked."
                    }

                    Get-EventLog -List
#>
                    # Opdater previousLog for at forhindre gentagelse af meddelelsen
                    $previousLog = $currentLog
                }
            Start-Sleep -Seconds 5  # Tjek hver minut
            }
            
            # Logik for opdatering her
        }

        "Update" {
            Write-Host "Indlæser status..." -ForegroundColor Green
            
            
        }

        default {
            Write-Host "Ugyldig handling 2: $Action" -ForegroundColor Red
            Start-Sleep -Seconds 3
            Show-Menu
        }
    }
}

# Overvåg Login-forsøg i PowerShell

# Få adgang til audit-loggen
Get-ChildItem "C:\SQLAuditLogs\LoginAudits"

$logPath = "C:\SQLAuditLogs\LoginAudits\auditlogfile"
$previousLog = Get-Content $logPath

while ($true) {
    $currentLog = Get-Content $logPath
    if ($currentLog -ne $previousLog) {
        # Her kan du sende en notifikation, logge hændelsen eller lignende
        $previousLog = $currentLog
    }
    Start-Sleep -Seconds 60  # Tjek hver minut
}