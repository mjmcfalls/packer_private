[CmdletBinding()]
Param (
    [string]$outpath = $env:temp,
    [string]$preferenceFile = "edge_master_preferences",
    [string]$preferenceFileDest = "C:\Program Files (x86)\Microsoft\Edge\Application\initial_preferences",
    [string]$preferenceFilter = "*",
    [switch]$install
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

if ($install.IsPresent) {
    Write-Log -Level "INFO" -Message "Searching for MS Edge Preference File"
    $preferenceFileState = Get-ChildItem $outpath -recurse | Where-Object { $_.FullName -Like "$($preferenceFilter)$($preferenceFile)" }

    if ($preferenceFileState) {
        Write-Log -Level "INFO" -Message "Found - $($preferenceFileState.FullName)"
        Write-Log -Level "INFO" -Message "Copy-Item -Path $($preferenceFile.FullName) -Destination "$($preferenceFileDest)\" -Force"
        Copy-Item -Path $preferenceFileState.FullName -Destination $preferenceFileDest -Force
    }
    else {
        Write-Log -Level "INFO" -Message "No preference file found."
    }

}