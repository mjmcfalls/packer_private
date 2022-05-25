
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
Write-Log -Level "INFO" -Message "Fetching Nuget Provider info"
$nugetProviderInfo = Find-PackageProvider -Name Nuget -Force

if($nugetProviderInfo){
    Write-Log -Level "INFO" -Message "Nuget Package Provider Installed - Version $($nugetProviderInfo.Version)"
}
else{
    Write-Log -Level "INFO" -Message "Installing Nuget Package Provider"
    Install-PackageProvider -Name NuGet -Force
}

Write-Log -Level "INFO" -Message "Installing PSWindowsUpdate"
Install-Module -Name PSWindowsUpdate -Force

Write-Log -Level "INFO" -Message "Validate PSWindowsUpdate Installation"
$pswinupdateInfo = Get-Package -Name PSWindowsUpdate

if($pswinupdateInfo){
    Write-Log -Level "INFO" -Message "PSWindowsUpdate - Version: $($pswinupdateInfo.Version); Source: $($pswinupdateInfo.Source)"
}
else{
    Write-Log -Level "INFO" -Message "PSWindowsUpdate - Not Installed"
}