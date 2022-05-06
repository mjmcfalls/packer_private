[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath = $env:temp,
    [switch]$install,
    [string]$installParams = "/S",
    [switch]$public,
    [string]$appuri = "/apps/R_Studio/",
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

Write-Log -Level "INFO" -Message  "Fetch $($installername) from $($uri)"

if ($public.IsPresent) {
    $installername = ($uri -Split "/")[-1]

    Write-Log -Level "INFO" -Message "R Studio Installer Name: $($installername)"

    Write-Log -Level "INFO" -Message "Starting Download of $($installername)"
    Invoke-WebRequest -Uri $uri -outfile (Join-Path -Path $outpath -ChildPath $installername) -UseBasicParsing

    Write-Log -Level "INFO" -Message "Download Completed"
}
else {
    Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile (Join-Path -Path $outpath -ChildPath $installername) 
}

if ($install.IsPresent) {
    Write-Log -Level "INFO" -Message "Installing of $($installername)"
    "Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $installername) -ArgumentList `"$($installParams)`""
    Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $installername) -ArgumentList "$($installParams)"
}