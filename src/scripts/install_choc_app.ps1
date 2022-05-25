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

Function Copy-ChromePreferenceFile {

}

# $ProgressPreference = 'SilentlyContinue'
$appsToInstall = New-Object System.Collections.Generic.List[System.String]
Write-Log -Level "INFO" -Message "Found - $($packagesPath)"

if (Test-Path $packagesPath) {
    [xml]$xml = Get-Content $packagesPath
    foreach ($p in $xml.Packages) {
        $appsToInstall.Add($p.package.id)
    
    }

    Write-Log -Level "INFO" -Message "Chocolately - Installing $($appsToInstall -Join ",")"
    choco install -y --no-progress "$($packagesPath)"


    foreach ($p in $xml.Packages) {
        Switch -wildcard ($p.package.id) {
            "chrome" { Write-Log -Level "INFO" -Message "Copy Preference file for Chrome" }
            "firefox" { Write-Log -Level "INFO" -Message "Copy Preference file for Firefox" }
            "edge" { Write-Log -Level "INFO" -Message "Copy Preference file for Edge" }
        }
    }
}
else {
    Write-Log -Level "ERROR" -Message "Cannot find $($packagesPath)"
}