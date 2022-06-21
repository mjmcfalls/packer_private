
[CmdletBinding()]
Param (
    [string]$outPath = "c:\temp",
    [string]$oneDrivePath = "c:\Windows\SysWOW64\onedrivesetup.exe",
    [string]$oneDriveUninstallParams = "/uninstall",
    [string]$logfile = $null,
    $itemsToRemove = @("C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk", "C:\Windows\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk", "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk", "C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk")
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

# Remove OneDrive Setup 
Write-Log -logfile $logfile -Level "INFO" -Message "Taking Ownership of $($oneDrivePath)"
takeown /F "$($oneDrivePath)" /A
# Add-NTFSAccess -Path $oneDrivePath -Account "BUILTIN\Administrators" -AccessRights FullControl

# Uninstall OneDrive
Write-Log -logfile $logfile -Level "INFO" -Message "Uninstalling OneDrive"
Start-Process -NoNewWindow -FilePath $oneDrivePath -ArgumentList $oneDriveUninstallParams -Wait -PassThru

# Removing installer after uninstall completes
Write-Log -logfile $logfile -Level "INFO" -Message "Removing OneDrive Installer"
Remove-Item $oneDrivePath -Force

Write-Log -logfile $logfile -Level "INFO" -Message "Removing OneDrive Start Menu Shortcuts"
foreach ($item in $itemsToRemove) {
    if(Test-Path $item){
        Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($item)"
        Remove-Item -Path $item -Force
    }
    else{
        Write-Log -logfile $logfile -Level "INFO" -Message "Cannot find $($item)"
    }
}

