[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath = $env:temp,
    [string]$wgetPath = "a:\wget.exe"
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

Write-Log -Level "INFO" -Message "Wget path: $($wgetPath)"
Write-Log -Level "INFO" -Message "URI: $($uri)"
Write-Log -Level "INFO" -Message "Output Directory: $($outpath)"

Start-Process -NoNewWindow -PassThru -Wait -FilePath $wgetPath -ArgumentList "-r --no-parent --no-clobber $($uri) -P $($outpath)"