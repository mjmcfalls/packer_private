[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath = $env:temp,
    [switch]$install,
    [string]$installParams = "/S",
    [switch]$public,
    [string]$appuri = "/apps/anaconda/",
    [string]$installername,
    [switch]$cleanup,
    [switch]$navigatorUpdate
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

$ProgressPreference = 'SilentlyContinue'

Write-Log -Level "INFO" -Message "Fetch $($installername) from $($uri)"
New-TempFolder -Path $outpath

if ($install.IsPresent) {
    if ($public.IsPresent) {
        Write-Log -Level "INFO" -Message "Anaconda - TO:Do fetch from source"
    }
    else {
        Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
        Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile (Join-Path -Path $outpath -ChildPath $installername) -UseBasicParsing
    }
    Write-Log -Level "INFO" -Message "Installing of $($installername)"
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $installername) -ArgumentList `"$($installParams)`""
    Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $installername) -ArgumentList "$($installParams)" -Wait
}

if ($navigatorUpdate.IsPresent) {
    # Update Anaconda Navigator
    Write-Log -Level "INFO" -Message "Updating Anaconda Navigator"
    Write-Log -Level "INFO" -Message "Running: Start-Process -NoNewWindow -PassThru -Wait -FilePath `"C:\ProgramData\Anaconda3\Library\bin\conda.exe`" -ArgumentList `"update anaconda-navigator -y`""
    $navigatorUpdateResults = Start-Process -NoNewWindow -PassThru -Wait -FilePath "C:\ProgramData\Anaconda3\Library\bin\conda.exe" -ArgumentList "update anaconda-navigator -y"
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

