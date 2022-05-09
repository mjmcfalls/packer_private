[CmdletBinding()]
Param (
    [string]$uri = "",
    [string]$outpath = $env:temp,
    [switch]$install,
    [string]$installParams = "/quiet /norestart",
    [switch]$public,
    [string]$appuri = "/apps/Chrome/",
    [string]$installername = "GoogleChromeEnterpriseBundle64.zip",
    [string]$fileFilter = "GoogleChromeStandaloneEnterprise64.msi",
    [string]$preferenceFile = "chrome_master_preferences",
    [string]$preferenceFileDest = "C:\Program Files\Google\Chrome\Application\initial_preferences",
    [string]$preferenceFilter = "*"
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
$installerPath = Join-Path -Path $outpath -ChildPath $installername

if ($public.IsPresent) {
    Write-Log -Level "INFO" -Message "Chrome - Install from Web"
    Invoke-WebRequest -Uri "$($uri)" -OutFile $installerPath  -UseBasicParsing
}
else {
    Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile $installerPath  -UseBasicParsing
}

if ($install.IsPresent) {
    $archiveDestination = Join-Path -Path $outpath -ChildPath ($installername -Split ".zip")[0]
    
    Write-Log -Level "INFO" -Message "Search for preference file: $($preferenceFile)"
    $preferenceFileState = Get-ChildItem $outpath -recurse | Where-Object { $_.FullName -Like "$($preferenceFilter)$($preferenceFile)" }

    Write-Log -Level "INFO" -Message "Unzipping $($installername) to $($archiveDestination)"
    Expand-Archive -Path "$($installerPath)" -Destination $archiveDestination -Force

    if ($preferenceFileState) {
        Write-Log -Level "INFO" -Message "Found - $($preferenceFileState.FullName)"
        Write-Log -Level "INFO" -Message "Copy-Item -Path $($preferenceFileState.FullName) -Destination $($preferenceFileDest) -Force"
        Copy-Item -Path $preferenceFileState.FullName -Destination $archiveDestination -Force

        Write-Log -Level "INFO" -Message "Copy-Item -Path $($preferenceFileState.FullName) -Destination $(Join-Path -Path $installerPath -ChildPath "master_preferences") -Force"
        Copy-Item -Path $preferenceFileState.FullName -Destination (Join-Path -Path $archiveDestination -ChildPath "master_preferences") -Force
        # $preferenceData = [System.Web.HTTPUtility]::UrlEncode((Get-Content $preferenceFileState.FullName | ConvertFrom-Json | ConvertTo-Json -Compress))
        # $preferenceData | Set-Content $preferenceFileDest
    }
    else {
        Write-Log -Level "INFO" -Message "No preference file found."
    }

    Write-Log -Level "INFO" -Message "Finding Chrome Installer"
    $installer = Get-Childitem $archiveDestination -Filter $fileFilter -recurse
    
    Write-Log -Level "INFO" -Message "Starting Install"
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($env:systemroot)\system32\msiexec.exe -ArgumentList `"/package $($installer.FullName) $($installParams)`""
    Start-Process -NoNewWindow -FilePath "$($env:systemroot)\system32\msiexec.exe" -ArgumentList "/package $($installer.FullName) $($installParams)"  -Wait

    if ($preferenceFileState) {
        Write-Log -Level "INFO" -Message "Found - $($preferenceFileState.FullName)"
        Write-Log -Level "INFO" -Message "Copy-Item -Path $($preferenceFileState.FullName) -Destination $($preferenceFileDest) -Force"
        Copy-Item -Path $preferenceFileState.FullName -Destination $preferenceFileDest -Force
    }
}