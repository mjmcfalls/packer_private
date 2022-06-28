[CmdletBinding()]
Param (
    [string]$searchPath = $env:temp,
    [string]$app = "lame",
    [string]$installDest = "C:\Program Files\Exact Audio Copy\",
    [string]$installername = "lame.exe"
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

$appSrcPath = Get-ChildItem -Directory -Path $searchPath | Where-Object { $_.Name -match $app }


Write-Log -Level "INFO" -Message "Installer Path: $($appSrcPath.FullName)"

Write-Log -Level "INFO" -Message "Moving $($appSrcPath.FullName) to $($installDest)"

Get-Childitem $appSrcPath.FullName -Recurse | Where-object { $_.Extension -notlike ".htm*" } | Move-Item -Destination $installDest -Force 

Write-Log -Level "INFO" -Message "LAME installed Finished"