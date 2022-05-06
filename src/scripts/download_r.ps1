[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath = $env:temp,
    [string]$regexTarget = "release.html",
    $urlRegex = "(?<URL>URL=R-[0-9\.]*-win.exe)",
    [switch]$install,
    [string]$installParams = "/verysilent /NORESTART",
    [switch]$public,
    [string]$appuri = "/apps/R/",
    [string]$installername
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
    Write-Log -Level "INFO" -Message "Fetch $($installername) from $($uri)"
    $content = Invoke-WebRequest -Uri $uri -UseBasicParsing
    $content

    if ( $content.content -match $urlRegex ) {
        $installername = ($Matches.URL -split "=")[-1]
        Write-Log -Level "INFO" -Message "R Installer Name: $($installername)"
    }
    else {
        Write-Log -Level "INFO" -Message "R Installer Name not found in redirect"
    }

    $r_download_uri = $uri.replace($regexTarget, $installername)
    Write-Log -Level "INFO" -Message "R Download URI: $($r_download_uri)"

    Write-Log -Level "INFO" -Message "Starting Download"
    Invoke-WebRequest -Uri $r_download_uri -OutFile (Join-Path -Path $outpath -ChildPath $installername) -UseBasicParsing
}
else {
    Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile (Join-Path -Path $outpath -ChildPath $installername) -UseBasicParsing
}

if ($install.IsPresent) {
    Write-Log -Level "INFO" -Message "Installing of $($installername)"
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $installername) -ArgumentList `"$($installParams)`""
    Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $installername) -ArgumentList "$($installParams)"
}