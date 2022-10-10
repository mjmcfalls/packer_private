[CmdletBinding()]
Param (
    [string]$app,
    [string]$searchPath = $env:temp,
    [string]$installParams,
    [string]$installerName,
    [string]$msiexec = "$($env:systemroot)\system32\msiexec.exe"
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

$installerExtension = [System.IO.Path]::GetExtension("$($installerName)")
$installerName = [io.path]::GetFileNameWithoutExtension($installerName)

Write-Log -Level "INFO" -Message "$($app) - Installer file Name: $($installerName); Installer File Extension: $($installerExtension)"
Write-Log -Level "INFO" -Message "$($app) - Parameters: $($installParams)"
Write-Log -Level "INFO" -Message "$($app) - Searching for $($installerName) in $($searchPath)"
$appSrcPath = Get-ChildItem -File -Path $searchPath -Recurse | Where-Object { $_.name -match $installerName }

if ($appSrcPath) {
    if ($appSrcPath -is [array]) {
        Write-Log -Level "INFO" -Message "$($app) - Found multiple installers; selecting [0]: $($appSrcPath[0])"
        $appSrcPath = $appSrcPath[0]
        Write-Log -Level "INFO" -Message "$($app) - Using $($appSrcPath.FullName)"
    }
    else {
        Write-Log -Level "INFO" -Message "$($app) - Using $($appSrcPath.FullName)"
    }


    Write-Log -Level "INFO" -Message "$($app) - Current Working Directory: $(Get-Location)"

    Write-Log -Level "INFO" -Message "$($app) - Switching to Directory: $($appSrcPath.Directoryname)"

    Push-Location $appSrcPath.Directoryname 

    Write-Log -Level "INFO" -Message "$($app) - Current Working Directory: $(Get-Location)"

    if ($installerExtension -like ".msi") {
        Write-Log -Level "INFO" -Message "$($app) - $($installerExtension) Install of $($appSrcPath.FullName)"
        Write-Log -Level "INFO" -Message "$($app) - MSIExec: $($msiexec); Package: $($appSrcPath.FullName); Parameters: $($installParams)"
        $installInfo = Start-Process -NoNewWindow -FilePath "$($msiexec)" -ArgumentList "/package $($appSrcPath.FullName) $($installParams)" -Wait -PassThru
    }
    elseif ($installerExtension -like ".exe") {
        Write-Log -Level "INFO" -Message "$($app) - $($installerExtension) Install of $($appSrcPath.FullName)"
        Write-Log -Level "INFO" -Message "$($app) - Installer: $($appSrcPath.FullName); Parameters: $($installParams)"
        $installInfo = Start-Process -NoNewWindow -FilePath "$($appSrcPath.FullName)" -ArgumentList "$($installParams)" -Wait -PassThru    
    }

    Pop-Location
    Write-Log -Level "INFO" -Message "$($app) - Current Working Directory: $(Get-Location)"
}
else {
    Write-Log -Level "INFO" -Message "$($app) - $($installerName) not found"
}

$installStopWatch.Stop()

Write-Log -Level "INFO" -Message "$($app) - End of install; Elapsed Time: $($installStopWatch.Elapsed)"


"Start-Process -NoNewWindow -Wait -FilePath \"${var.win_temp_dir}\\apps\\vmware\\vmtools\\windows\\setup.exe\" -ArgumentList \"/S /v /qn REBOOT=R ADDLOCAL=ALL REMOVE=Hgfs,FileIntrospection,NetworkIntrospection,BootCamp,CBHelper\"",