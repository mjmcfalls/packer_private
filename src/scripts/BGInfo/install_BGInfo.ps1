[CmdletBinding()]
Param (
    [string]$uri,
    [string]$outpath = $env:temp,
    [switch]$install,
    [string]$installDest = "C:\Program Files\Sysinternals\BGInfo",
    [string]$startupLocation = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp",
    [string]$installParams = "/S",
    [switch]$public,
    [string]$appuri = "/apps/SysInternals/",
    [string]$installername = "Bginfo.exe",
    [string]$configFile = "HomeLab_202205250940.bgi",
    [switch]$cleanup
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

New-TempFolder -Path $outpath

if ($public.IsPresent) {
    Write-Log -Level "INFO" -Message "BGInfo install from Web"
    Invoke-WebRequest -Uri "$($uri)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
}
else {
    Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
}

if ($install.IsPresent) {
    $installerPath = Join-Path -Path $outpath -ChildPath $installername
    Write-Log -Level "INFO" -Message "Installer Path: $($installerPath)"

    Write-Log -Level "INFO" -Message "Creating Directories: $($installDest)"
    New-Item -ItemType Directory $installDest -Force

    Write-Log -Level "INFO" -Message "Copying $($installerPath) to $($installDest)"
    Move-Item -Path $installerPath -Destination $installDest -Force

    Write-Log -Level "INFO" -Message "Searching $($outpath) for $($configFile)"
    $configSrc = Get-Childitem -Path $outpath -Filter $configFile -Recurse

    if ($configSrc) {
        Write-Log -Level "INFO" -Message "Copy $($configSrc.FullName) to $($installDest)"
        Copy-Item -Path $configSrc.FullName -Destination $installDest -Force
    }

    Write-Log -Level "INFO" -Message "Create Startup Link"
    $WshShell = New-Object -comObject WScript.Shell

    Write-Log -Level "INFO" -Message "BGInfo.lnk path: $startupLocation\BGInfo.lnk"
    $Shortcut = $WshShell.CreateShortcut("$($startupLocation)\BGInfo.lnk")

    Write-Log -Level "INFO" -Message "Lnk TargetPath: $(Join-Path -Path $installDest -ChildPath $installername) /timer:0 /nolicprompt /silent '$(Join-Path -Path $installDest -ChildPath $configSrc.Name)'"
    $Shortcut.TargetPath = "$(Join-Path -Path $installDest -ChildPath $installername) /timer:0 /nolicprompt /silent '$(Join-Path -Path $installDest -ChildPath $configSrc.Name)'"
    
    Write-Log -Level "INFO" -Message "Creating Startup link in $startupLocation\BGInfo.lnk"
    $Shortcut.Save()
    
}

if ($cleanup.IsPresent) {
    if (Test-Path (Join-Path -Path $outpath -ChildPath $installername)) {
        (Join-Path -Path $outpath -ChildPath $installername).Delete()
    }
}