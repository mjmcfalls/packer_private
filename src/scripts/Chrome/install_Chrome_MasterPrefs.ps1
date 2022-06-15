[CmdletBinding()]
Param (
    [string]$searchPath = $env:temp,
    [string]$preferenceFile = "master_preferences",
    [string]$preferenceFileDest = "C:\Program Files\Google\Chrome\Application\initial_preferences",
    [string]$preferenceFilter = "*"
)


Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        [ValidateSet("INFO", "WARN", "ERROR", "FATAL", "DEBUG")]
        [String]
        $Level = "INFO",
        [Parameter(Mandatory = $True)]
        [string]
        $Message,
        [Parameter(Mandatory = $False)]
        [string]
        $logfile
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If ($logfile) {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}

$ProgressPreference = 'SilentlyContinue'
    
Write-Log -Level "INFO" -Message "Search for preference file: $($preferenceFile)"
$preferenceFileState = Get-ChildItem $searchPath -Recurse | Where-Object { $_.FullName -Like "$($preferenceFilter)$($preferenceFile)" }

if ($preferenceFileState) {
    Write-Log -Level "INFO" -Message "Found - $($preferenceFileState.FullName)"

    Write-Log -Level "INFO" -Message "Copy-Item -Path $($preferenceFileState.FullName) -Destination $(Join-Path -Path $preferenceFileDest -ChildPath "master_preferences") -Force"
    Copy-Item -Path $preferenceFileState.FullName -Destination (Join-Path -Path $archiveDestination -ChildPath "master_preferences") -Force

}
else {
    Write-Log -Level "INFO" -Message "No preference file found."
}
