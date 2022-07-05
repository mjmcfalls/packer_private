
[CmdletBinding()]
Param (
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


# Install dot Net 3.5
Write-Log -logfile $logfile -Level "INFO" -Message "Installing .NET 3.5"
$dismDotNetThreeFiveResults = Start-Process -NoNewWindow -Wait -PassThru -FilePath "Dism.exe" -ArgumentList "/online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart /Quiet"
