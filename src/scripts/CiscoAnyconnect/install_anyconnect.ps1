[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath = "c:\temp",
    [string]$regexTarget = "release.html",
    $urlRegex = "(?<URL>URL=R-[0-9\.]*-win.exe)",
    [switch]$install,
    [string]$installParams = "/quiet /norestart",
    [switch]$public,
    [string]$appuri = "/apps/CiscoAnyconnect/",
    [string]$installername = "anyconnect-win-4.10.05095.zip",
    [string]$xmlProfilePathDest = "C:\ProgramData\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\",
    [string]$xmlProfile = "unc.xml",
    [string]$fileFilter = "*core-vpn*"
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

    $Stamp = (Get-Date).toString("yyyy-MM-dd HH:mm:ss")
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
$installerPath = Join-Path -Path $outpath -ChildPath $installername

Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile $installerPath -UseBasicParsing

if ($install.IsPresent) {
    $archiveDestination = Join-Path -Path $outpath -ChildPath ($installername -Split ".zip")[0]

    Write-Log -Level "INFO" -Message "Unzipping $($installername)"
    Expand-Archive -Path "$($installerPath)" -Destination $archiveDestination -Force

    Write-Log -Level "INFO" -Message "Finding AnyConnect Core installer"
    $installer = Get-Childitem $archiveDestination -Filter $fileFilter

    Write-Log -Level "INFO" -Message "Starting Install"
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($env:systemroot)\system32\msiexec.exe -ArgumentList `"/package $($installer.FullName) $($installParams)`""
    Start-Process -NoNewWindow -FilePath "$($env:systemroot)\system32\msiexec.exe" -ArgumentList "/package $($installer.FullName) $($installParams)"

    Write-Log -Level "INFO" -Message "Searching $($outpath) for $($xmlProfile)"
    $xmlProfileSrc = Get-Childitem -Path $outpath -Filter $xmlProfile -Recurse

    if($xmlProfileSrc){
        if(-Not (Test-Path $xmlProfilePathDest)){
            New-Item -Path $xmlProfilePathDest -ItemType Directory
        }
        Write-Log -Level "INFO" -Message  "Copying $($xmlProfileSrc.FullName) to $($xmlProfilePathDest)"
        Move-Item -Path $xmlProfileSrc.FullName -Destination $xmlProfilePathDest -Force
    }
    else{
        Write-Log -Level "INFO" -Message  "Not Found - $($xmlProfile) in $($outpath)"
    }

}