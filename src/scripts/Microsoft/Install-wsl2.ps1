[CmdletBinding()]

Param (
    [string]$app = "WSL2",
    [string]$searchPath = $env:temp,
    [string]$installParams = "--install",
    [string]$installername = "wsl.exe",
    [string]$distrourl = "https://aka.ms/wslubuntu2004",
    [string]$distroName = "Ubuntu-20.04",
    [string]$patchName = "wsl_update_x64.msi",
    [string]$patchInstallParams = "/q",
    [switch]$install,
    [switch]$configure
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
# $installStopWatch = [System.Diagnostics.StopWatch]::StartNew()

if ($install.IsPresent) {
    Write-Log -Level "INFO" -Message "Installing $($app)"
    # Start-Process -Wait -Passthru -NoNewWindow -FilePath $installername -ArgumentList "$($installParams)"
    Start-Proces -Wait -Passthru -NoNewWindows -FilePath "dism.exe" -ArgumentList "/online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart"
    Start-Proces -Wait -Passthru -NoNewWindows -FilePath "dism.exe" -ArgumentList "/online /enable-feature /featurename:VirtualMachinePlatform /all /norestart"
    # Restart-Computer
}

# Post reboot configuration
if ($configure.IsPresent) {
    Write-Log -Level "INFO" -Message "$($app) - Starting Patch Install"
    
    $installerExtension = [System.IO.Path]::GetExtension("$($patchName)")
    $installerName = [io.path]::GetFileNameWithoutExtension($patchName)
    
    Write-Log -Level "INFO" -Message "$($app) - Installer file Name: $($patchName); Installer File Extension: $($installerExtension)"
    Write-Log -Level "INFO" -Message "$($app) - Parameters: $($installParams)"
    Write-Log -Level "INFO" -Message "$($app) - Searching for $($patchName) in $($searchPath)"
    $appSrcPath = Get-ChildItem -File -Path $searchPath -Recurse | Where-Object { $_.name -match $patchName }
    
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

    Write-Log -Level "INFO" -Message "$($app) - Set WSL Default Version to 2"
    Start-Proces -Wait -Passthru -NoNewWindows -FilePath $installername -ArgumentList "--set-default-version 2"

    Write-Log -Level "INFO" -Message "$($app) - Installing $($distroName)"
    Start-Proces -Wait -Passthru -NoNewWindows -FilePath $installername -ArgumentList "--install -d $($distroName)"
}

# $installStopWatch.Stop()
Write-Log -Level "INFO" -Message "$($app) - End of install"