[CmdletBinding()]

Param (
    [string]$wgetPath = "c:\program files\"
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

$scriptName = $MyInvocation.MyCommand.Name
Write-Log -Level "INFO" -Message "Starting $($scriptName)"

Write-Log -Level "INFO" -Message "Wget path to create: $($wgetPath)"

if(Test-Path $wgetPath){
    Write-Log -Level "INFO" -Message "$($wgetPath) already exists"
}
else{
    Write-Log -Level "INFO" -Message "Creating $($wgetPath)"
    New-Item -Path $wgetPath -ItemType Directory
}

Write-Log -Level "INFO" -Message "End of $($scriptName)"