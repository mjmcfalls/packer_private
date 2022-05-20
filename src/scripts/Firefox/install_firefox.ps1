[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath = $env:temp,
    [switch]$install,
    [string]$installParams = "/S /INI=INIPATH",
    [string]$ininame = "Firefox_install.ini",
    [switch]$public,
    [string]$appuri = "/apps/firefox/",
    [string]$installername = "firefox_installer.exe",
    [switch]$cleanup,
    [string]$policyFile = "Firefox_policies.json",
    [string]$policyDestFileName = "policies.json",
    [string]$preferenceFilter = "*",
    [string]$uninstallRegKeyPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
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

Function Get-FirefoxIni {
    [CmdletBinding(
        SupportsShouldProcess = $True
    )]
    param(
        [string]$Path,
        [string]$ininame
    )

    $files = Get-ChildItem -Path $Path -Recurse -File | Where-Object { $_.name -like $ininame }
    $files
}


Add-Type -AssemblyName System.Web

$ProgressPreference = 'SilentlyContinue'

New-TempFolder -Path $outpath

# Check if URL Encoded
$decodeUri = [System.Web.HTTPUtility]::UrlDecode($uri)

Write-Log -Level "INFO" -Message "Checking if URL is encoded - $($uri); decoded: $($decodeUri)"
if ($uri -Notlike $decodeUri) {
    Write-Log -Level "INFO" -Message "Setting decodeduri to uri"
    $uri = $decodeUri
}

if ($public.IsPresent) {
    Write-Log -Level "INFO" -Message "Install from Web - $($uri)"
    Invoke-WebRequest -Uri "$($uri)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
}
else {
    Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
}

if ($install.IsPresent) {
    Write-Log -Level "INFO" -Message "Searching for $($ininame) in $($outpath)"
    $inipath = Get-FirefoxIni -Path $outpath -ininame $ininame

    $installParams = $installParams.replace("INIPATH", $inipath.fullname)
    Write-Log -Level "INFO" -Message "Updated Install parameters: $($inipath)"

    $installerPath = Join-Path -Path $outpath -ChildPath $installername
    Write-Log -Level "INFO" -Message "Installer Path: $($installerPath)"

    Write-Log -Level "INFO" -Message "Getting Extension of $($installername)"
    $installerExtension = [System.IO.Path]::GetExtension("$($installerPath)")

    Write-Log -Level "INFO" -Message "Extension is: $($installerExtension)"

    if ($installerExtension -like ".msi") {
        Write-Log -Level "INFO" -Message "MSI Install of $($installerPath)"
        # Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($env:systemroot)\system32\msiexec.exe -ArgumentList `"/package $($installerPath) $($installParams)`""
        # Start-Process -NoNewWindow -FilePath "$($env:systemroot)\system32\msiexec.exe" -ArgumentList "/package $($installerPath) $($installParams)" -Wait
    }
    elseif ($installerExtension -like ".exe") {
        Write-Log -Level "INFO" -Message "EXE Install of $($installername)"
        Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($installerPath) -ArgumentList `"$($installParams)`""
        Start-Process -NoNewWindow -FilePath $installerPath -ArgumentList "$($installParams)" -Wait    
    }

    # Copy policies.json to Distribution folder in Firefox installation directory
    $policyFilePath = Get-ChildItem $outpath -recurse | Where-Object { $_.FullName -Like "$($preferenceFilter)$($policyFile)" }

    if ($policyFilePath) {
        Write-Log -Level "INFO" -Message "Found Policy File- $($policyFilePath.FullName)"
        Write-Log -Level "INFO" -Message "Finding Installation path"
        # Find Firefox Installation directory
        if (Test-Path $uninstallRegKeyPath) {
            $uninstallKey = Get-ChildItem $uninstallRegKeyPath | Where-Object { $_.Name -Like "*Firefox*" }
            $installLocation = Get-ItemProperty -Path $uninstallKey.PSPath -Name "InstallLocation"
            Write-Log -Level "INFO" -Message "Firefox installed at $($installLocation.InstallLocation)"
        }

        $distributionPath = Join-Path -Path $installLocation -ChildPath "distribution"
        Write-Log -Level "INFO" -Message "Verifying Distibution path exists - $($distributionPath)"
        if (-Not (Test-Path -Path $distributionPath)) {
            Write-Log -Level "INFO" -Message "Creating $($distributionPath)"
            New-Item -ItemType Directory -Path $distributionPath
        }
        else {
            Write-Log -Level "DEBUG" -Message "Exists - $($distributionPath)"
        }

        Write-Log -Level "INFO" -Message "Copy-Item -Path $($policyFilePath.FullName) -Destination $(Join-Path -Path $distributionPath -ChildPath $policyDestFileName) -Force"
        Copy-Item -Path $policyFilePath.FullName -Destination (Join-Path -Path $distributionPath -ChildPath $policyDestFileName) -Force
    }
    else {
        Write-Log -Level "INFO" -Message "$($policyFile) not found."
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