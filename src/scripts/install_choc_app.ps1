[CmdletBinding()]
Param (
    [string]$packagesPath
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

# $ProgressPreference = 'SilentlyContinue'
# "Name: $($app); Params: $($params)"
# choco install -y "$($app)"

# choco install -y "$($packagesPath)"

Write-Log -Level "INFO" -Message "Packages Path: $($packagesPath)"
[xml]$xml = Get-Content $packagesPath
foreach ($p in $xml.Packages) {
    Switch -wildcard ($p.package.id) {
        "chrome" { Write-Log -Level "INFO" -Message "Copy Preference file for Chrome" }
        "firefox" { Write-Log -Level "INFO" -Message "Copy Preference file for Firefox" }
        "edge" { Write-Log -Level "INFO" -Message "Copy Preference file for Edge" }
    }

}