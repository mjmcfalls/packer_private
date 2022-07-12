[CmdletBinding()]

Param (
    [string]$app = "WSL2",
    [string]$searchPath = $env:temp,
    [string]$installParams = "--install",
    [string]$installername = "wsl.exe"
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

Write-Log -Level "INFO" -Message "Installing $($app)"
Start-Process -Wait -Passthru -NoNewWindow -FilePath $installername -ArgumentList "$($installParams)"