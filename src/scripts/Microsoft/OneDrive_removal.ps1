
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
$oneDriveRunStub = "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$oneDriveRunStubKey = "OneDriveSetup"
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
    if (Test-Path $item) {
        Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($item)"
        Remove-Item -Path $item -Force
    }
    else {
        Write-Log -logfile $logfile -Level "INFO" -Message "Cannot find $($item)"
    }
}

# Remove for current user and all existing users, and from default user profile
# HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run OneDriveSetup
$driveStatus = New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
Write-Log -logfile $logfile -Level "INFO" -Message "Created HKU PS Drive - $($driveStatus)"

If (Test-Path -Path HKU:) {
    $userRegKeys = Get-ChildItem HKU:

    Foreach ($userKey in $userRegKeys) {
        $userkey | Select *
        $oneDriveUserRunPath = Join-Path -Path $userKey.PSPath -ChildPath $oneDriveRunStub
        #$oneDriveUserRunPath
        $oneDriveSetupState = Get-ItemProperty -Path $oneDriveUserRunPath -Name $oneDriveRunStubKey -ErrorAction SilentlyContinue
        if ($oneDriveSetupState) {
            Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($oneDriveRunStubKey) from $($userkey.Name)"
            Remove-ItemProperty -Path $oneDriveSetupState.PSPath -Name $oneDriveRunStubKey -Force
        }
        Else {
            Write-Log -logfile $logfile -Level "INFO" -Message "$($oneDriveRunStubKey) does not exist under $($userkey.Name)"
        }
    }
}

Write-Log -logfile $logfile -Level "INFO" -Message "Removing HKU PS Drive"
Remove-PSDrive -Name HKU


# Removing OneDriveSetup from Default User
Write-Log -logfile $logfile -Level "INFO" -Message "Mounting Default User ntuser.dat to HKLM\Default"
& REG LOAD HKLM\DEFAULT C:\Users\Default\NTUSER.DAT

if (Test-Path "HKLM:\DEFAULT\$($oneDriveRunStub)") {
    Write-Log -logfile $logfile -Level "INFO" -Message "$($oneDriveRunStub) Exists in default user"
    Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($oneDriveRunStubKey) under HKLM:\DEFAULT\$($oneDriveRunStub)"
    Remove-ItemProperty -Path "HKLM:\DEFAULT\$($oneDriveRunStub)" -Name $oneDriveRunStubKey -Force
    
}
Write-Log -logfile $logfile -Level "INFO" -Message "Running Garbage collection to commit registry changes"
[gc]::Collect() 

Write-Log -logfile $logfile -Level "INFO" -Message "Unmounting HKLM\Default"
& REG UNLOAD HKLM\DEFAULT

Write-Log -logfile $logfile -Level "INFO" -Message "End of OneDrive Removal Process"