[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath,
    [switch]$install,
    [string]$installParams = "/S"
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

Write-Log -Level "INFO" -Message  "Fetch R Studio from $($uri)"

Create-TempFolder -Path $outpath

$installer_name = ($uri -Split "/")[-1]

Write-Log -Level "INFO" -Message "R Studio Installer Name: $($installer_name)"

Write-Log -Level "INFO" -Message "Starting Download of R Studio"
Invoke-WebRequest -Uri $uri -outfile (Join-Path -Path $outpath -ChildPath $installer_name) -UseBasicParsing

Write-Log -Level "INFO" -Message "Download Completed"

if ($install.IsPresent) {
    Write-Log -Level "INFO" -Message "Starging Install of R Studio"
    "Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $installer_name) -ArgumentList `"$($installParams)`""
    Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath $installer_name) -ArgumentList "$($installParams)"
}