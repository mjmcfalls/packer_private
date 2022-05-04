[CmdletBinding()]

Param (
    [string]$uri = "",
    [string]$outpath,
    [switch]$install,
    [string]$installParams = "/quiet /norestart",
    [switch]$public,
    [string]$appuri = "/apps/Chrome/",
    [string]$installername = "GoogleChromeEnterpriseBundle64.zip",
    [string]$fileFilter = "GoogleChromeStandaloneEnterprise64.msi"
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

$ProgressPreference = 'SilentlyContinue'

Create-TempFolder -Path $outpath

if ($public.IsPresent) {
    Write-Log -Level "INFO" -Message "Chrome - Install from Web"
    Invoke-WebRequest -Uri "$($uri)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
}
else {
    Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
}

if ($install.IsPresent) {
    $ = $installername -Split ".zip"

    Write-Log -Level "INFO" -Message "Unzipping $($installername) to $(Join-Path -Path $outpath -ChildPath $archiveDestination)"
    Expand-Archive -Path "$($installername)" -Destination (Join-Path -Path $outpath -ChildPath $archiveDestination) -Force

    Write-Log -Level "INFO" -Message "Finding Chrome Installer"
    $installer = Get-Childitem (Join-Path -Path $outpath -ChildPath $installername) -Filter $fileFilter
    

    Write-Log -Level "INFO" -Message "Starting Install"
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($env:systemroot)\system32\msiexec.exe -ArgumentList `"/package $($installer.FullName) $($installParams)`""
    Start-Process -NoNewWindow -FilePath "$($env:systemroot)\system32\msiexec.exe" -ArgumentList "/package $($installer.FullName) $($installParams)"

    # Not sure why this is here?
    # Write-Log -Level "INFO" -Message "Installing of $($installername)"
    # Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($installer.FullName) -ArgumentList `"$($installParams)`""
    # Start-Process -NoNewWindow -FilePath $installer.FullName -ArgumentList "$($installParams)"
}