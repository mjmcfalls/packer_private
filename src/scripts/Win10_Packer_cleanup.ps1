[CmdletBinding()]
Param (
    [string]$tempDir = "c:\temp"
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


$tempPaths = New-Object System.Collections.Generic.List[System.Object]
$tempPaths.Add($env:temp)
$tempPaths.Add($tempDir)

# Recomplie Dot Net x64
Write-Log -Level "INFO" -Message "Recompiling x64 dot net"
&"c:\windows\microsoft.net\framework64\v4.0.30319\ngen.exe update /force"

# Recomplie Dot Net x86
Write-Log -Level "INFO" -Message "Recompiling x86 dot net"
&"c:\windows\microsoft.net\framework\v4.0.30319\ngen.exe update /force"

foreach($tpath in $tempPaths){
    Write-Log -Level "INFO" -Message "Cleaning $($tpath)"

    Write-Log -Level "INFO" -Message "Getting files in $($tpath)"
    $tempFiles = Get-ChildItem $tpath -Recurse -File
    # $tempFiles
    Write-Log -Level "INFO" -Message "Removing files in $($tpath)"
    $tempFiles | Remove-Item -Force #-ErrorAction SilentlyContinue

    Write-Log -Level "INFO" -Message "Getting Directories in $($tpath)"
    $tempDirs = Get-ChildItem $tpath -Recurse -Directory
    # $tempFiles
    Write-Log -Level "INFO" -Message "Removing Directories in $($tpath)"
    $tempDirs | Remove-Item -Force -Recurse #-ErrorAction SilentlyContinue
}
