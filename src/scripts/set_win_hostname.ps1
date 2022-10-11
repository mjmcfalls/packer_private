[CmdletBinding()]
Param (
    [string]$app,
    [string]$hostname
)

function New-TempFolder {
    [CmdletBinding(
        SupportsShouldProcess = $True
    )]
    param(
        [string]$Path
    )
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path
    }

}

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
$installStopWatch = [System.Diagnostics.StopWatch]::StartNew()

Write-Log -Level "INFO" -Message "$($app) - Starting Install"

Write-Log -Level "INFO" -Message "$($app) - Current Hostname: $($env:computername); New Hostname $($hostname)"

Try {
    Rename-Computer -NewName "$($hostname)" -Force -ErrorAction SilentlyContinue
    Write-Log -Level "INFO" -Message "$($app) - Computer will need to be restarted for changes to take effect."
}
Catch {
    Write-Log -Level "INFO" -Message "$($app) - Unable to Rename Computer to $($hostname)"
    Write-Log -Level "INFO" -Message "$($app) - Error: $($_)"
}


$installStopWatch.Stop()

Write-Log -Level "INFO" -Message "$($app) - End of install; Elapsed Time: $($installStopWatch.Elapsed)"