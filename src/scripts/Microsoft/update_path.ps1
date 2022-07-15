[CmdletBinding()]

Param (
    [string]$appname = "julia",
    [string]$path
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

            
Write-Log -Level "INFO" -Message "$($app) - Append $($path) to Machine Environmental variables"
[Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";$($path)", [EnvironmentVariableTarget]::Machine)

