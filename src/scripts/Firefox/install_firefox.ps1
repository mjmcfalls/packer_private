[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath = $env:temp,
    [switch]$install,
    [string]$installParams = "/S /INI=INIPATH",
    [string]$ininame = "Firefox_install.ini",
    [switch]$public,
    [string]$appuri = "/apps/firefox/",
    [string]$installername = "firefox_installer.exe"
)

function Create-TempFolder {
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

$ProgressPreference = 'SilentlyContinue'

Create-TempFolder -Path $outpath

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
    $inipath = Get-FirefoxIni -Path $outpath -inifile $ininame

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
        Start-Process -NoNewWindow -FilePath $installerPath -ArgumentList "$($installParams)"    
    }

    
}