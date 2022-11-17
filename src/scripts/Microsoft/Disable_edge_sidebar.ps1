
[CmdletBinding()]
Param (
    [string]$logfile = $null,
    [string]$file = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk",
    [string]$targetAddition = " --disable-features=msSidebarSearchAfterSearchWebFor,msSidebarSearchBeforeSearchWebFor"
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


if (Test-Path $file) {
    $obj = New-Object -ComObject WScript.Shell 
    $link = $obj.CreateShortcut($file) 
    Write-Host  -ForegroundColor green
    Write-Log -logfile $logfile -Level "INFO" -Message "Shortcut Target Path: $($link.TargetPath)"
    $tempPath = $link.TargetPath + $targetAddition
    Write-Log -logfile $logfile -Level "INFO" -Message "New Shortcut Target Path: $($tempPath)"
    $link.TargetPath = $tempPath
    Write-Log -logfile $logfile -Level "INFO" -Message "Updating target path to $($tempPath)"
    $link.Save() 
    Write-Log -logfile $logfile -Level "INFO" -Message "Saving $($file)"
}
else{
    Write-Log -logfile $logfile -Level "INFO" -Message "Could not find $($file)"
}
Write-Log -logfile $logfile -Level "INFO" -Message "Script complete"
