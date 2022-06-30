[CmdletBinding()]
Param (
    [string]$searchString = "Notepad`+`+",
    [string]$updaterDir = "updater"
)

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

$programDirectories = @($env:ProgramFiles, ${env:ProgramFiles(x86)})
$timestamp = Get-Date -format yyyyMMddhhmm
$newUpdaterName = "$($updaterDir)_$($timestamp)"

Write-Log -Level "INFO" -Message  "Disabling Notepad++ Updater"

Foreach ($programDir in $programDirectories) {
    Write-Log -Level "INFO" -Message "Searching for $($searchString) in $($programDir)"
    $nppDirs = Get-ChildItem -Directory -Path $programDir | Where-Object { $_.name -like $searchString }

    if ($nppDirs) {
        foreach ($dirObj in $nppDirs) {
            Write-Log -Level "INFO" -Message "Searching $($dirObj.FullName)"
            $updaterPath = Join-Path -Path $dirObj.FullName -ChildPath $updaterDir
            if (Test-Path -Path $updaterPath) {
                Write-Log -Level "INFO" -Message "Found $($updaterPath)"
                Write-Log -Level "INFO" -Message "Renaming $($updaterPath) to $($newUpdaterName)"
                Rename-Item -Path $updaterPath -NewName $newUpdaterName
            }
        }
    }
}
