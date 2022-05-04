
# Remove AppX Packages
Get-AppxPackage | Where-Object {$_.Name -notlike "*Search*" -or $_.Name -notlike "*Calc*" -or $_.Name -notlike "*Store*"} | Remove-AppXPackage


# Remove OneDrive Setup 
takeown /F $mountdir\Windows\SysWOW64\OneDriveSetup.exe /A
Add-NTFSAccess -Path "$($mountdir)\Windows\SysWOW64\onedrivesetup.exe" -Account "BUILTIN\Administrators" -AccessRights FullControl
Remove-Item $mountdir\Windows\SysWOW64\onedrivesetup.exe

reg load HKEY_LOCAL_MACHINE\WIM $mountdir\Users\Default\ntuser.dat
reg delete "HKEY_LOCAL_MACHINE\WIM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f

# Remove Cloud Content
reg add HKEY_LOCAL_MACHINE\WIM\SOFTWARE\Policies\Microsoft\Windows\CloudContent
reg add HKEY_LOCAL_MACHINE\WIM\SOFTWARE\Policies\Microsoft\Windows\CloudContent /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f

# Unload, Unmount, Commit
reg unload HKEY_LOCAL_MACHINE\WIM


# Disable Windows Feeds
Set-ItemProperty -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name EnableFeeds -Value 0 -PropertyType "DWORD" -Force