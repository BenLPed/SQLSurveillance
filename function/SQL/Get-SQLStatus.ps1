# Funktion til at læse SQL-status fra JSON-fil
function Get-SQLStatus {

    JSON-StatusFile

    $status = Get-Content -Raw -Path $statusFilePath | ConvertFrom-Json
    return $status.SQL.DatabaseCreated
}