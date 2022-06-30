[CmdletBinding()]
Param (
    [string]$uri = "",
    [string]$outpath = $env:temp,
    [switch]$install,
    [string]$installParams = "/silent /loadinf=TARGETINF",
    [string]$inf_file = "vscode.inf",
    [switch]$public,
    [string]$appuri = "/apps/VSCode/",
    [string]$installername = "VSCodeSetup-x64-1.67.0.exe",
    [switch]$disableAutoUpdate,
    [switch]$disableTelemetry,
    [switch]$disableCrashReporting,
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

# VSCodeSetup-x64-1.38.1.exe /verysilent /mergetasks='!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath' /saveinf=vscode.inf
# VSCodeSetup-x64-1.38.1.exe /silent /loadinf=vscode.inf

if ($public.IsPresent) {
    # Write-Log -Level "INFO" -Message "Fetching from $($uri)"
    # $installername = ($uri -Split "/")[-1]
    # $installerPath = Join-Path -Path $outpath -ChildPath $installername
    # Invoke-WebRequest -Uri $uri -OutFile $installerPath -UseBasicParsing
}
else {
    $installerPath = Join-Path -Path $outpath -ChildPath $installername

    Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile $installerPath -UseBasicParsing
}

if ($install.IsPresent) {

    Write-Log -Level "INFO" -Message "Searching $($outpath) for $($inf_file)"
    $infpath = Get-Childitem -Path $outpath -Filter $inf_file -Recurse

    $installParams = $installParams.replace("TARGETINF",$infpath.FullName)

    Write-Log -Level "INFO" -Message "Installing of $($installerPath)"
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($installerPath) -ArgumentList `"$($installParams)`""
    Start-Process -NoNewWindow -FilePath $($installerPath) -ArgumentList "$($installParams)" -Wait
 
    if($disableAutoUpdate.IsPresent){
        Write-Log -Level "INFO" -Message "Disabling VSCode AutoUpdate"
    }

    if($disableTelemetry.IsPresent){
        Write-Log -Level "INFO" -Message "Disabling VSCode Telemetry"
    }

    if($disableCrashReporting.IsPresent){
        Write-Log -Level "INFO" -Message "Disabling VSCode Crash reporting"
    }
}

if ($cleanup.IsPresent) {
    Write-Log -Level "INFO" -Message "Cleaning up installer"
    if (Test-Path (Join-Path -Path $outpath -ChildPath $installername)) {
        Write-Log -Level "INFO" -Message "Removing $(Join-Path -Path $outpath -ChildPath $installername)"
        (Join-Path -Path $outpath -ChildPath $installername).Delete()
    }
    else {
        Write-Log -Level "INFO" -Message "Cannot find $(Join-Path -Path $outpath -ChildPath $installername)"
    }
}