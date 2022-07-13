[CmdletBinding()]

Param (
    [string]$app = "Docker Customize",
    [string]$searchPath = $env:temp,
    [string]$settingsFile = "settings.json",
    [string]$serviceName = "com.docker.service",
    [string]$serviceStartupType = "delayed-auto",
    [string]$settingsFileDest = "C:\users\Default User\Appdata\Roaming\Docker"
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
$installStopWatch = [System.Diagnostics.StopWatch]::StartNew()

Write-Log -Level "INFO" -Message "$($app) - Starting Docker Customization"

Write-Log -Level "INFO" -Message "$($app) - Testing for $($serviceName)"

if (Get-Service $serviceName) {
    Write-Log -Level "INFO" -Message "$($app) - Found $($serviceName)"
    Write-Log -Level "INFO" -Message "$($app) - Stopping $($serviceName)"
    Stop-Service "$($serviceName)"

    $serviceArgs = "config `"$($serviceName)`" start= $($serviceStartupType)"
    Write-Log -Level "INFO" -Message "$($app) - Create service Arguments: $($serviceArgs)"
    Write-Log -Level "INFO" -Message "$($app) - Setting $($serviceName) to $($serviceStartupType)"
    Start-Process -FilePath sc.exe -ArgumentList $serviceArgs

}

Write-Log -Level "INFO" -Message "$($app) - Searching for $($settingsFile) in $($searchPath)"
$settingsFileState = Get-ChildItem $searchPath -Recurse -File | Where-Object { $_.Name -Like "$($settingsFile)" }

if ($settingsFileState) {
    Write-Log -Level "INFO" -Message "$($app) - Found: $($settingsFileState.FullName)"

    Write-Log -Level "INFO" -Message "$($app) - Copy-Item -Path `"$($settingsFileState.FullName)`" -Destination `"$(Join-Path -Path $settingsFileDest -ChildPath $settingsFile)`" -Force"
    Copy-Item -Path $settingsFileState.FullName -Destination "$($settingsFileDest)" -Force

}
else {
    Write-Log -Level "INFO" -Message "$($app) - $($settingsFile) file not found."
}

$installStopWatch.Stop()

Write-Log -Level "INFO" -Message "$($app) - End of install; Elapsed Time: $($installStopWatch.Elapsed)"