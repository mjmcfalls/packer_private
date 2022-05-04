[CmdletBinding()]

Param (
    [string]$uri = "",
    [string]$outpath,
    [switch]$install,
    [string]$installParams = "/S",
    [switch]$public,
    [string]$appuri = "/apps/7zip/",
    [string]$installername = "7z2107-x64.msi"
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
    Write-Log -Level "INFO" -Message "7Zip install from Web"
    Invoke-WebRequest -Uri "$($uri)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
}
else {
    Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
}

if ($install.IsPresent) {
    Write-Log -Level "INFO" -Message "Starting Install"
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $installername) -ArgumentList `"$($installParams)`""
    Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $installername) -ArgumentList "$($installParams)"
}