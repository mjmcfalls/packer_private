[CmdletBinding()]
Param (
    [string]$searchPath = $env:temp,
    [string]$app = "sysinternals",
    [string]$installDest = "C:\Program Files\Sysinternals\",
    [string]$startupLocation = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp",
    [string]$installParams = "/timer:0 /nolicprompt /silent",
    [string]$configFile = "bginfo.bgi",
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

# New-TempFolder -Path $outpath

# if ($public.IsPresent) {
#     Write-Log -Level "INFO" -Message "BGInfo install from Web"
#     Invoke-WebRequest -Uri "$($uri)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
# }
# else {
#     Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
#     Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
# }
$appSrcPath = Get-ChildItem -Directory -Path $searchPath | Where-Object { $_.Name -match $app }


Write-Log -Level "INFO" -Message "Installer Path: $($appSrcPath.FullName)"

Write-Log -Level "INFO" -Message "Creating Directories: $($installDest)"
New-Item -ItemType Directory $installDest -Force

Write-Log -Level "INFO" -Message "Copying $($appSrcPath.FullName) to $($installDest)"
Move-Item -Path $appSrcPath.FullName -Destination $installDest -Force

Write-Log -Level "INFO" -Message "Searching $($searchPath) for $($configFile)"
$configSrc = Get-Childitem -Path $searchPath -Recurse | Where-Object { $_.name -match $configFile }

if ($configSrc) {
    Write-Log -Level "INFO" -Message "Copy $($configSrc.FullName) to $(Split-Path $installDest -Parent)"
    Copy-Item -Path $configSrc.FullName -Destination (Split-Path $installDest -Parent) -Force
}

Write-Log -Level "INFO" -Message "Create Startup Link"
$WshShell = New-Object -comObject WScript.Shell

Write-Log -Level "INFO" -Message "BGInfo.lnk path: $startupLocation\BGInfo.lnk"
$Shortcut = $WshShell.CreateShortcut("$($startupLocation)\BGInfo.lnk")

Write-Log -Level "INFO" -Message "Lnk TargetPath: $(Join-Path -Path $installDest -ChildPath $installername)"
$Shortcut.TargetPath = "$(Join-Path -Path $installDest -ChildPath $installername)"

$bgInfoConfigPath = Join-Path -Path $installDest -ChildPath $configSrc.Name
Write-Log -Level "INFO" -Message "BGInfo config located at $($bgInfoConfigPath)"
Write-Log -Level "INFO" -Message "Link Arguments: /timer:0 /nolicprompt /silent `"$($bgInfoConfigPath)`""
$Shortcut.Arguments = "$($installParams) `"$($bgInfoConfigPath)`""

Write-Log -Level "INFO" -Message "Creating Startup link in $startupLocation\BGInfo.lnk"
$Shortcut.Save()   
