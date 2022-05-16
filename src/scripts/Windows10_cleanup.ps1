
[CmdletBinding()]
Param (
    [string]$outPath = "c:\temp",
    $oneDrivePath = "c:\Windows\SysWOW64\onedrivesetup.exe",
    $oneDriveUninstallParams = "/uninstall",
    $appxIgnoreList = @("microsoft.windowscommunicationsapps", "Microsoft.WindowsCalculator", "Microsoft.DesktopAppInstaller", "Microsoft.WindowsStore", "Microsoft.StorePurchaseApp", "Microsoft.Appconnector"),
    $winFeaturesToDisable = @("DirectPlay", "WindowsMediaPlayer"),
    $defaultsUsersSettingsPath = "Microsoft\DefaultUsersSettings.txt"
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




# Set High Performance
$highperfguid = ((((powercfg /list | Select-String "High Performance") -Split ":")[1]) -Split "\(")[0].trim()
Write-Log -Level "INFO" -Message "Setting performance plan to $($highperfguid)"
powercfg /setactive "$($highperfguid)"


# Install dot Net 3.5
Write-Log -Level "INFO" -Message "Installing .NET 3.5"
dism /online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:$NetFX3_Source /NoRestart


Write-Log -Level "INFO" -Message "Disabling Consumer Features (Internet App Downloads)"
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'CloudContent' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableWindowsConsumerFeatures' -PropertyType DWORD -Value '1' #| Out-Null 

Write-Log -Level "INFO" -Message "Disabling Windows tips"
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableSoftLanding' -PropertyType DWORD -Value '1' #| Out-Null 

# Disable Windows Feeds
Write-Log -Level "INFO" -Message "Disabling Windows Feeds"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -PropertyType DWORD -Value "0" #| Out-Null 
# reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f


# Remove AppX Packages
$installedAppXApps = Get-ProvisionedAppxPackage -Online

foreach ($appX in $installedAppXApps) {
    if (-Not ($appX.DisplayName -in $appxIgnoreList)) {
        Write-Log -Level "INFO" -Message "Removing AppX Provisioned Package: $($appX.DisplayName)"
        Remove-AppxProvisionedPackage -Online -PackageName $($appX.PackageName | Out-Null

        New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'Windows Search' | Out-Null"Removing AppX Package: $($appX.DisplayName)"
        Remove-AppxPackage -Package $($appX.PackageName | Out-Null
    }
}

# dism /Online /Get-ProvisionedAppxPackages | Select-String PackageName | Select-String xbox | ForEach-Object { $_.Line.Split(':')[1].Trim() } | ForEach-Object { dism /Online /Remove-ProvisionedAppxPackage /PackageName:$_ }

# Disable Cortana
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'Windows Search' | Out-Null
Write-Log -Level "INFO" -Message "Disable Cortana"
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -PropertyType DWORD -Value '0' | Out-Null


# Uninstall OneDrive
Write-Log -Level "INFO" -Message "Uninstalling OneDrive"
Start-Process -NoNewWindow -FilePath $oneDrivePath -ArgumentList $oneDriveUninstallParams -Wait

# Remove OneDrive Setup 
takeown /F "$($oneDrivePath)" /A
# Add-NTFSAccess -Path $oneDrivePath -Account "BUILTIN\Administrators" -AccessRights FullControl
Write-Log -Level "INFO" -Message "Removing OneDrive Installer"
Remove-Item $oneDrivePath

Remove-Item -Path "C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force
Remove-Item -Path "C:\Windows\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force


# Registry changes
Write-Log -Level "INFO" -Message "Loading Default User Registry"
reg load HKEY_LOCAL_MACHINE\WIM $mountdir\Users\Default\ntuser.dat

Write-Log -Level "INFO" -Message "Deleting OneDrive Setup from Default User"
reg delete "HKEY_LOCAL_MACHINE\WIM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v OneDriveSetup /f

Write-Log -Level "INFO" -Message "Removing OneDrive Startup from Default User"
Remove-Itemproperty -Path 'HKLM:\WIM\Software\Microsoft\Windows\CurrentVersion\Run\' -name 'OneDriveSetup'

Write-Log -Level "INFO" -Message "Disabling OneDrive Syncing for All users"
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'Skydrive' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive' -Name 'DisableFileSync' -PropertyType DWORD -Value '1' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive' -Name 'DisableLibrariesDefaultSaveToSkyDrive' -PropertyType DWORD -Value '1' | Out-Null 


# Unload, Unmount, Commit
reg unload HKEY_LOCAL_MACHINE\WIM


# Disable Windows Features
foreach($feature in $winFeaturesToDisable){
    Write-Log -Level "INFO" -Message "Removing $($feature)"
    Disable-WindowsOptionalFeature -Online -FeatureName $feature
}

# Don't need this with Packer
# if (Get-Process -Name "Explorer") {
#     Stop-Process -Name "Explorer"
# }
# else {
#     "No Explorer.exe process found."
# }