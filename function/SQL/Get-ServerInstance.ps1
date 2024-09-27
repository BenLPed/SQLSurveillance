function Get-ServerInstance {

    try {
        $serverInstance = Invoke-Sqlcmd -Query "SELECT @@SERVERNAME" -ServerInstance "localhost" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Column1
    }
    catch {
        <#Do this if a terminating exception happens#>
        Return "NoDatabase"
    }

    return $serverInstance
}