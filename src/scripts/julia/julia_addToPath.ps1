[CmdletBinding()]

Param (
    [string]$appname = "julia",
    [string]$executableExtension = ".exe"
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

Foreach ($progDir in $programDirectories) {
    Write-Log -Level "INFO" -Message "Searching $($progDir) for $($appName)"
    $paths = Get-ChildItem -Path $progDir | Where-Object { $_.Name -like "$($appName)*" }
    if($paths){   
        foreach ($path in $paths) {
            Write-Log -Level "INFO" -message "Searching $($path.FullName)"
            Get-ChildItem -Path $Path.FullName -File -Recurse | Where-Object {$_.Name -like "$($appname)$($executableExtension)"}
            
            Write-Log -Level "INFO" -Message "Add $($path.FullName) to Machine Environmental variables"
            [Environment]::SetEnvironmentVariable("PATH", $Env:PATH + ";$($path.FullName)", [EnvironmentVariableTarget]::Machine)
        }
    }
}
