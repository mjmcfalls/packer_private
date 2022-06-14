
[CmdletBinding()]
Param (
    [string]$outPath = "c:\temp",
    [string]$oneDrivePath = "c:\Windows\SysWOW64\onedrivesetup.exe",
    [string]$oneDriveUninstallParams = "/uninstall",
    $appxIgnoreList = @("microsoft.windowscommunicationsapps", "Microsoft.WindowsCalculator", "Microsoft.DesktopAppInstaller", "Microsoft.WindowsStore", "Microsoft.StorePurchaseApp", "Microsoft.Appconnector"),
    $winFeaturesToDisable = @("DirectPlay", "WindowsMediaPlayer"),
    [string]$defaultsUserSettingsPath = (Join-Path -Path $outPath -ChildPath "apps\Scripts\Microsoft\DefaultUsersSettings.txt"),
    [string]$ScheduledTasksListPath = (Join-Path -Path $outPath -ChildPath "apps\Scripts\Microsoft\ScheduledTasks.txt"),
    [string]$automaticTracingFilePath = (Join-Path -Path $outPath -ChildPath "apps\Scripts\Microsoft\AutomaticTracers.txt"),
    [string]$servicesToDisablePath = (Join-Path -Path $outPath -ChildPath "apps\Scripts\Microsoft\ServicesToDisable.txt"),
    [int]$FileInfoCacheEntriesValue = 1024,
    [int]$DirectoryCacheEntriesMax = 1024,
    [int]$FileNotFoundCacheEntriesMax = 2048,
    [int]$DormantFileLimit = 256,
    [int]$DisableBandwidthThrottling = 1,
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

$schTasksResults = New-Object System.Collections.Generic.List[System.Object]
$regKeyResults = New-Object System.Collections.Generic.List[System.Object]

# Set High Performance
$highperfguid = ((((powercfg /list | Select-String "High Performance") -Split ":")[1]) -Split "\(")[0].trim()
Write-Log -logfile $logfile -Level "INFO" -Message "Setting performance plan to $($highperfguid)"
powercfg /setactive "$($highperfguid)"


# Install dot Net 3.5
Write-Log -logfile $logfile -Level "INFO" -Message "Installing .NET 3.5"
$dismDotNetThreeFiveResults = Start-Process -NoNewWindow -Wait -PassThru -FilePath "Dism.exe" -ArgumentList "/online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart"

# Remove AppX Packages
$installedAppXApps = Get-ProvisionedAppxPackage -Online

foreach ($appX in $installedAppXApps) {
    if (-Not ($appX.DisplayName -in $appxIgnoreList)) {
        Write-Log -logfile $logfile -Level "INFO" -Message "Removing AppX Provisioned Package: $($appX.DisplayName)"
        Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $($appX.PackageName) | Out-Null

        Write-Log -logfile $logfile -Level "INFO" -Message "Removing AppX Package: $($appX.DisplayName)"
        Remove-AppxPackage -AllUsers -Package $($appX.PackageName) | Out-Null
    }
}

# dism /Online /Get-ProvisionedAppxPackages | Select-String PackageName | Select-String xbox | ForEach-Object { $_.Line.Split(':')[1].Trim() } | ForEach-Object { dism /Online /Remove-ProvisionedAppxPackage /PackageName:$_ }

# Disable Cortana
Write-Log -logfile $logfile -Level "INFO" -Message "Disable Cortana"
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'Windows Search' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -PropertyType DWORD -Value '0' | Out-Null


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

# Registry changes
Write-Log -logfile $logfile -Level "INFO" -Message "Disabling Consumer Features (Internet App Downloads)"
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'CloudContent' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableWindowsConsumerFeatures' -PropertyType DWORD -Value '1' | Out-Null 

Write-Log -logfile $logfile -Level "INFO" -Message "Disabling Windows Store Updates"
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" -Name "AutoDownload" -PropertyType DWORD -Value "2"

Write-Log -logfile $logfile -Level "INFO" -Message "Disabling Windows tips"
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableSoftLanding' -PropertyType DWORD -Value '1' | Out-Null 

# Disable Windows Feeds
Write-Log -logfile $logfile -Level "INFO" -Message "Creating HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name Windows Feeds"
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "Windows Feeds" -Force

Write-Log -logfile $logfile -Level "INFO" -Message "Disabling Windows Feeds"
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -PropertyType DWORD -Value "0" | Out-Null 

New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion" -Name "Feeds" -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarviewMode" -PropertyType DWORD -Value "2" -Force | Out-Null
# reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v EnableFeeds /t REG_DWORD /d 0 /f

Write-Log -logfile $logfile -Level "INFO" -Message "Disabling OneDrive Syncing for All users"
New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'Skydrive' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive' -Name 'DisableFileSync' -PropertyType DWORD -Value '1' | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive' -Name 'DisableLibrariesDefaultSaveToSkyDrive' -PropertyType DWORD -Value '1' | Out-Null 


Write-Log -logfile $logfile -Level "INFO" -Message "Disabling MS Edge First Run Experience"
New-Item -Path "HKLM:\Software\Policies\Microsoft" -Name "Edge" -Force
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Edge" -Name HideFirstRunExperience -PropertyType DWORD -Value "1" -Force | Out-Null

Write-Log -logfile $logfile -Level "INFO" -Message "Disabling OOBE Experience for Current User"
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion" -Name "UserProfileEngagement" -Force
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -PropertyType DWORD -Value "0" -Force | Out-Null

Write-Log -logfile $logfile -Level "INFO" -Message "Disabling First Run Animations"
New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "EnableFirstLogonAnimation" -Value "0" -Force | Out-Null 


if (Test-Path $defaultsUserSettingsPath) {
    $defaultUserSettings = Get-Content $defaultsUserSettingsPath

    if ($defaultUserSettings.count -gt 0) {
        Foreach ($item in $defaultUserSettings) {
            $regResults = Start-Process C:\Windows\System32\Reg.exe -ArgumentList "$($item)" -Wait -PassThru

            $psobj = [PSCustomObject]@{
                Name    = $item
                Results = $regResults
            }

            $regKeyResults.Add($psobj)
        }
    }

}
else {
    Write-Log -logfile $logfile -Level "INFO" -Message  "Unable to find $($defaultsUserSettingsPath)"
}

# Disable Scheduled Tasks
if (Test-Path $ScheduledTasksListPath) {
    Write-Log -logfile $logfile -Level "INFO" -Message "Found $($ScheduledTasksListPath)"
    $SchTasksList = Get-Content $ScheduledTasksListPath

    if ($SchTasksList.count -gt 0) {
        Write-Log -logfile $logfile -Level "INFO" -Message "$($ScheduledTasksListPath) is not empty"
        Write-Log -logfile $logfile -Level "INFO" -Message "Getting Enabled Scheduled Tasks"
        $EnabledScheduledTasks = Get-ScheduledTask | Where-Object { $_.State -ne "Disabled" }

        Foreach ($item in $SchTasksList) {
            Write-Log -logfile $logfile -Level "INFO" -Message "$($item): Disabling scheduled task"
            $schTaskResult = $EnabledScheduledTasks | Where-Object { $_.TaskName -like "$($item.trim())" } | Disable-ScheduledTask
            $schTasksResults.add($schTaskResult)
        }
    }
}
else {
    Write-Log -logfile $logfile -Level "INFO" -Message  "Unable to find $($ScheduledTasksListPath)"
}

# Disable Windows Services
if (Test-Path $servicesToDisablePath) {
    $servicesToDisable = Get-Content $servicesToDisablePath
    if ($servicesToDisable.count -gt 0) {
        Foreach ($service in $servicesToDisable) {
            $serviceExists = Get-Service -Name W32Time -ErrorAction SilentlyContinue
            if ($null -eq $serviceExists) {
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($service): Disabling service"
                Stop-Service $service
                Set-Service -Name $service -StartupType Disabled
            }
            else {
                Write-Log -logfile $logfile -Level "INFO" -Message "$($service): Service does not exist"
            }
        }
    }
}
else {
    Write-Log -logfile $logfile -Level "INFO" -Message  "Unable to find $($servicesToDisablePath)"
}

# Disable Windows Automatic tracing
if (Test-Path $automaticTracingFilePath) {
    $AutomaticTracers = Get-Content $automaticTracingFilePath
    if ($AutomaticTracers.count -gt 0) {
        Foreach ($tracer in $AutomaticTracers) {
            Write-Log -logfile $logfile -Level "INFO" -Message "$($tracer): Starting logic to disable"
            Write-Log -logfile $logfile -Level "INFO" -Message  "$($tracer): Testing for existance of tracing"
            if (Test-Path "$($tracer)") {
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($tracer): Disabling tracing"
                New-ItemProperty -Path "$($tracer)" -Name "Start" -PropertyType "DWORD" -Value "0" -Force
            }
            else {
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($tracer): Does not exist"
            }
            
        }
    }
}
else {
    Write-Log -logfile $logfile -Level "INFO" -Message  "Unable to find $($automaticTracingFilePath)"
}

# Disable Windows Features
foreach ($feature in $winFeaturesToDisable) {
    Write-Log -logfile $logfile -Level "INFO" -Message "Feature $($feature): Removing"
    Disable-WindowsOptionalFeature -Online -FeatureName $feature
}

# Disable System Restore
Write-Log -logfile $logfile -Level "INFO" -Message "Disable System Restore for C:"
Disable-ComputerRestore -Drive "C:\"

# Disable Hibernate
Write-Log -logfile $logfile -Level "INFO" -Message "Disable Hibernate"
powercfg /hibernate off

# Disable Crash Dumps
Write-Log -logfile $logfile -Level "INFO" -Message "Disable System crash dumps"
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'CrashDumpEnabled' -Value '1'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'LogEvent' -Value '0'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'SendAlert' -Value '0'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'AutoReboot' -Value '1'


# Disable Logon Background
Write-Log -logfile $logfile -Level "INFO" -Message "Disable Logon Background"
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'DisableLogonBackgroundImage' -Value '1'

# Network Optimization
Write-Log -logfile $logfile -Level "INFO" -Message "Disable SMB Bandwidth Throttling"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" DisableBandwidthThrottling -Value $DisableBandwidthThrottling -Force

Write-Log -logfile $logfile -Level "INFO" -Message "Set FileInfoCacheEntries to $($FileInfoCacheEntriesValue)"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" FileInfoCacheEntriesMax -Value $FileInfoCacheEntriesValue -Force

Write-Log -logfile $logfile -Level "INFO" -Message "Set DirectoryCacheEntriesMax to $($DirectoryCacheEntriesMax)"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" DirectoryCacheEntriesMax -Value $DirectoryCacheEntriesMax -Force

Write-Log -logfile $logfile -Level "INFO" -Message "Set FileNotFoundCacheEntriesMax to $($FileNotFoundCacheEntriesMax)"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" FileNotFoundCacheEntriesMax -Value $FileNotFoundCacheEntriesMax -Force

Write-Log -logfile $logfile -Level "INFO" -Message "Set DormantFileLimit to $($DormantFileLimit)"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" DormantFileLimit -Value $DormantFileLimit -Force

# Disk cleanup will occur post application installs