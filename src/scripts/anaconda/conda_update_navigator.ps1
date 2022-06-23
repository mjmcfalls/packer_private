[CmdletBinding()]

Param (
    $condaBatPath = "C:\ProgramData\Anaconda3\Library\bin\conda.bat",
    $navigatorUpdateCmd = "update anaconda-navigator -y"
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

# Update Anaconda Navigator
Write-Log -Level "INFO" -Message "Updating Anaconda Navigator"
Write-Log -Level "INFO" -Message "Running: Start-Process -NoNewWindow -PassThru -Wait -FilePath `"$($condaBatPath)`" -ArgumentList `"$($navigatorUpdateCmd)`""
$navigatorUpdateResults = Start-Process -NoNewWindow -PassThru -Wait -FilePath $condaBatPath -ArgumentList "$($navigatorUpdateCmd)"

Write-Log -Level "INFO" -Message "Navigator Results: $($navigatorUpdateResults)"

Write-Log -Level "INFO" -Message "Conda Navigator update Script Finished"
