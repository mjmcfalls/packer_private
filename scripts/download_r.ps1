[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath,
    [string]$regexTarget = "release.html",
    $urlRegex = "(?<URL>URL=R-[0-9\.]*-win.exe)",
    [switch]$install,
    [string]$installParams = "/verysilent /NORESTART"
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

Create-TempFolder -Path $outpath

Write-Log -Level "INFO" -Message "Fetch R from $($uri)"
$content = Invoke-WebRequest -Uri $uri -UseBasicParsing
$content

if ( $content.content -match $urlRegex ) {
    $r_installer_name = ($Matches.URL -split "=")[-1]
    Write-Log -Level "INFO" -Message "R Installer Name: $($r_installer_name)"
}
else {
    Write-Log -Level "INFO" -Message "R Installer Name not found in redirect"
}

$r_download_uri = $uri.replace($regexTarget, $r_installer_name)
Write-Log -Level "INFO" -Message "R Download URI: $($r_download_uri)"

Write-Log -Level "INFO" -Message "Starting Download"
Invoke-WebRequest -Uri $r_download_uri -OutFile (Join-Path -Path $outpath -ChildPath $r_installer_name) -UseBasicParsing

if ($install.IsPresent) {
    Write-Log -Level "INFO" -Message "Starting Install"
    "Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $r_installer_name) -ArgumentList `"$($installParams)`""
    Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $r_installer_name) -ArgumentList "$($installParams)"
}