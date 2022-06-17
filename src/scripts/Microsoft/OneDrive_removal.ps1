
[CmdletBinding()]
Param (
    [string]$outPath = "c:\temp",
    [string]$oneDrivePath = "c:\Windows\SysWOW64\onedrivesetup.exe",
    [string]$oneDriveUninstallParams = "/uninstall",
    [string]$logfile = $null
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

# Uninstall OneDrive
Write-Log -logfile $logfile -Level "INFO" -Message "Uninstalling OneDrive"
Start-Process -NoNewWindow -FilePath $oneDrivePath -ArgumentList $oneDriveUninstallParams -Wait

# Remove OneDrive Setup 
takeown /F "$($oneDrivePath)" /A
# Add-NTFSAccess -Path $oneDrivePath -Account "BUILTIN\Administrators" -AccessRights FullControl
Write-Log -logfile $logfile -Level "INFO" -Message "Removing OneDrive Installer"
Remove-Item $oneDrivePath

Write-Log -logfile $logfile -Level "INFO" -Message "Removing OneDrive Start Menu Shortcuts"
Remove-Item -Path "C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force
Remove-Item -Path "C:\Windows\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force
Remove-Item -Path "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force
Remove-Item -Path "C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force