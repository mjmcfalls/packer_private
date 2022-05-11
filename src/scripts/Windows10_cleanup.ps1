
$oneDrivePath = "c:\Windows\SysWOW64\onedrivesetup.exe"
$oneDriveUninstallParams = "/uninstall"

# Set High Performance
$highperfguid = ((((powercfg /list | Select-String "High Performance") -Split ":")[1]) -Split "\(")[0].trim()
powercfg /setactive "$($highperfguid)"

# Remove AppX Packages
Get-AppxPackage | Where-Object { $_.Name -notlike "*Search*" -or $_.Name -notlike "*Calc*" -or $_.Name -notlike "*Store*" } | Remove-AppXPackage

dism /Online /Get-ProvisionedAppxPackages | Select-String PackageName | Select-String xbox | ForEach-Object { $_.Line.Split(':')[1].Trim() } | ForEach-Object { dism /Online /Remove-ProvisionedAppxPackage /PackageName:$_ }

# Uninstall OneDrive
Start-Process -NoNewWindow -FilePath $oneDrivePath -ArgumentList $oneDriveUninstallParams -Wait

# Remove OneDrive Setup 
takeown /F "$($oneDrivePath)" /A
# Add-NTFSAccess -Path $oneDrivePath -Account "BUILTIN\Administrators" -AccessRights FullControl
Remove-Item $oneDrivePath

reg load HKEY_LOCAL_MACHINE\WIM $mountdir\Users\Default\ntuser.dat
reg delete "HKEY_LOCAL_MACHINE\WIM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f

# Remove Cloud Content
reg add HKEY_LOCAL_MACHINE\WIM\SOFTWARE\Policies\Microsoft\Windows\CloudContent
reg add HKEY_LOCAL_MACHINE\WIM\SOFTWARE\Policies\Microsoft\Windows\CloudContent /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f

# Disable Windows Feeds
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f

# Unload, Unmount, Commit
reg unload HKEY_LOCAL_MACHINE\WIM

if (Get-Process -Name "Explorer") {
    Stop-Process -Name "Explorer"
}
else {
    "No Explorer.exe process found."
}