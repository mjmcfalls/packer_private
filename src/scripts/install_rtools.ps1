[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath,
    [string]$regexTarget = "release.html",
    [switch]$install,
    [string]$installParams = "/verysilent /DIR='C:\R\R-3.3.0'",
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
    Write-Log -Level "INFO" -Message "Fetching from $($uri)"
    $installername = ($uri -Split "/")[-1]
    $installerPath = Join-Path -Path $outpath -ChildPath $installername
    Invoke-WebRequest -Uri $uri -OutFile $installerPath -UseBasicParsing
}
else {
    $installerPath = Join-Path -Path $outpath -ChildPath $installername

    Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile $installerPath -UseBasicParsing
}

if ($install.IsPresent) {
    Write-Log -Level "INFO" -Message "Installing of $($installername)"
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($installerPath) -ArgumentList `"$($installParams)`""
    Start-Process -NoNewWindow -FilePath $($installerPath) -ArgumentList "$($installParams)"
}