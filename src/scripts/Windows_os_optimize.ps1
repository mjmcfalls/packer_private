
[CmdletBinding()]
Param (
    [string]$outPath = "c:\temp",
    [string]$oneDrivePath = "c:\Windows\SysWOW64\onedrivesetup.exe",
    [string]$oneDriveUninstallParams = "/uninstall",
    $appxIgnoreList = @("microsoft.windowscommunicationsapps", "Microsoft.WindowsCalculator", "Microsoft.DesktopAppInstaller", "Microsoft.WindowsStore", "Microsoft.StorePurchaseApp", "Microsoft.Appconnector"),
    $winFeaturesToDisable = @("DirectPlay", "WindowsMediaPlayer"),
    [string]$defaultsUserSettingsPath = "c:\temp\apps\Scripts\Microsoft\DefaultUserSettings.txt",
    [string]$defaultsUserVisualSettingsPath = "c:\temp\apps\Scripts\Microsoft\DefaultUserVisualEffects.txt",
    [string]$ScheduledTasksListPath = "c:\temp\apps\Scripts\Microsoft\ScheduledTasks.txt",
    [string]$automaticTracingFilePath = "c:\temp\apps\Scripts\Microsoft\AutomaticTracers.txt",
    [string]$servicesToDisablePath = "c:\temp\apps\Scripts\Microsoft\ServicesToDisable.txt",
    [int]$FileInfoCacheEntriesValue = 1024,
    [int]$DirectoryCacheEntriesMax = 1024,
    [int]$FileNotFoundCacheEntriesMax = 2048,
    [int]$DormantFileLimit = 256,
    [int]$DisableBandwidthThrottling = 1,
    [string]$logfile = $null,
    [string]$auditLogFile = "audit.json",
    [string]$auditLogPath = "C:\ProgramData\Packer",
    [string]$buildName = "Default"
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

$app = "OS Optimize"
$optimizeHashTable = @{}

$appXResults = New-Object System.Collections.Generic.List[System.Object]
$schTasksResults = New-Object System.Collections.Generic.List[System.Object]
$regKeyResults = New-Object System.Collections.Generic.List[System.Object]
$visualEffectsResults = New-Object System.Collections.Generic.List[System.Object]
$serviceChangesList = New-Object System.Collections.Generic.List[System.Object]
$tracingChangesList = New-Object System.Collections.Generic.List[System.Object]
$allChangeResults = @{}

$osRegistryChangesArray = @(
    @{DisplayName = "Cortana"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCortana'; PropertyType = "DWORD"; Value = "0"; ParentPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\'; ParentKey = 'Windows Search'; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "Consumer Features (Internet App Downloads)"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsConsumerFeatures'; PropertyType = "DWORD"; Value = "1"; ParentPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows'; ParentKey = 'CloudContent'; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "Disabling Windows Store Updates"; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate'; Name = 'AutoDownload'; PropertyType = "DWORD"; Value = "2"; ParentPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\'; ParentKey = 'WindowsUpdate'; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "Windows tips"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableSoftLanding'; PropertyType = "DWORD"; Value = "1"; ParentPath = $null; ParentKey = $null; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "Windows Feeds"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"; Name = "EnableFeeds"; PropertyType = "DWORD"; Value = "0"; ParentPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows'; ParentKey = "Windows Feeds"; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "ShellFeedsTaskbarviewMode"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" ; Name = "ShellFeedsTaskbarviewMode"; PropertyType = "DWORD"; Value = "2"; ParentPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion"; ParentKey = "Feeds"; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "OneDrive - DisableFileSync"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive'; Name = 'DisableFileSync'; PropertyType = "DWORD"; Value = "1"; ParentPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\'; ParentKey = 'Skydrive'; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "OneDrive - DisableLibrariesDefaultSaveToSkyDrive"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive'; Name = 'DisableLibrariesDefaultSaveToSkyDrive'; PropertyType = "DWORD"; Value = "1"; ParentPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\'; ParentKey = 'Skydrive'; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "MS Edge First Run Experience"; Path = "HKLM:\Software\Policies\Microsoft\Edge"; Name = 'HideFirstRunExperience'; PropertyType = "DWORD"; Value = "1"; ParentPath = "HKLM:\Software\Policies\Microsoft"; ParentKey = "Edge"; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "OOBE Experience for Current User"; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement'; Name = 'ScoobeSystemSettingEnabled'; PropertyType = "DWORD"; Value = "0"; ParentPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion"; ParentKey = "UserProfileEngagement"; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "First Run Animations"; Path = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'; Name = 'EnableFirstLogonAnimation'; PropertyType = "DWORD"; Value = "0"; ParentPath = $null; ParentKey = $null; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "Disable Privacy Experience"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE'; Name = 'DisablePrivacyExperience'; PropertyType = "DWORD"; Value = "1"; ParentPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\"; ParentKey = "OOBE"; ItemResults = $null; PropertyResults = $null }
)



if (Test-Path $auditLogPath) {
    Write-Log -Level "INFO" -Message "$($app) - Audit Log Path $($auditLogPath) exists"
}
else {
    Write-Log -Level "INFO" -Message "$($app) - Creating $($auditLogPath)"
    New-Item -Path $auditLogPath -ItemType Directory -Force

}

# 
# Set High Performance
# 
$highperfguid = ((((powercfg /list | Select-String "High Performance") -Split ":")[1]) -Split "\(")[0].trim()
Write-Log -logfile $logfile -Level "INFO" -Message "Setting performance plan to $($highperfguid)"
powercfg /setactive "$($highperfguid)"

# 
# Remove AppX Packages
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Get Installed AppX Packages"
$installedAppXApps = Get-ProvisionedAppxPackage -Online

foreach ($appX in $installedAppXApps) {
    $tempAppXhashTbl = @{ AppXDisplayName = $appX.DisplayName; AppXPackageName = $appX.PackageName; Skipped = $null; ProvisionedPackageResults = $null; PackageResults = $null }

    if (-Not ($appX.DisplayName -in $appxIgnoreList)) {
        # Removing Provisioned App X Package
        Try {
            Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Removing AppX Provisioned Package: $($appX.DisplayName)"
            $provisionedPackageResults = Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $($appX.PackageName) -ErrorAction Stop

            Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - $($appX.DisplayName): $($provisionedPackageResults)"
            $tempAppXhashTbl.ProvisionedPackageResults = $provisionedPackageResults
        }
        Catch {
            $tempAppXhashTbl.ProvisionedPackageResults = $_
        }

        # Removing Provisioned App X Package
        Try {
            Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Removing AppX Package: $($appX.DisplayName)"
            $appXPackageResults = Remove-AppxPackage -AllUsers -Package $($appX.PackageName) -ErrorAction Stop

            Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - $($appX.DisplayName): $($appXPackageResults)"
            $tempAppXhashTbl.PackageResults = $appXPackageResults
        }
        Catch {
            Write-Log -logfile $logfile -Level "ERROR" -Message "$($app) - $($appX.DisplayName): $($_)"
            $tempAppXhashTbl.PackageResults = $_
        }
    }
    else {
        $tempAppXhashTbl.Skipped = $true
    }
    $appXResults.Add($tempAppXhashTbl)
}

# Add changes to hastable for reporting
$allChangeResults.Add("AppX", $appXResults)

# 
# Global Registry Changes
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Starting Global Registry Changes"
for ($i = 0; $i -lt $osRegistryChangesArray.length; $i++) {
    Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Disable $($osRegistryChangesArray[$i].DisplayName)"
    if ($osRegistryChangesArray[$i].ParentPath) {
        try {
            Write-Log -Level "INFO" -Message "New-Item -Path $($osRegistryChangesArray[$i].ParentPath) -Name $($osRegistryChangesArray[$i].ParentKey)"
            $newItemResults = New-Item -Force -ErrorAction stop -Path $osRegistryChangesArray[$i].ParentPath -Name $osRegistryChangesArray[$i].ParentKey
            $osRegistryChangesArray[$i].ItemResults = $newItemResults
        }
        catch {
            Write-Log -Level "INFO" -Message "$($_)"
            $osRegistryChangesArray[$i].ItemResults = $_
        }
        Write-Log -Level "INFO" -Message "$($app) - Results: $($osRegistryChangesArray[$i].ItemResults)"
    }

    Write-Log -logfile $logfile -Level "INFO" -Message "$($app) -  New-ItemProperty: Path $($osRegistryChangesArray[$i].Path); Name $($osRegistryChangesArray[$i].Name); PropertyType $($osRegistryChangesArray[$i].PropertyType); Value $($osRegistryChangesArray[$i].Value)"
    try {
        $newItemPropertyResults = New-ItemProperty -Force -ErrorAction stop -Path $osRegistryChangesArray[$i].Path -Name $osRegistryChangesArray[$i].Name -PropertyType $osRegistryChangesArray[$i].PropertyType -Value ($osRegistryChangesArray[$i].Value)
        $osRegistryChangesArray[$i].PropertyResults = $newItemPropertyResults

    }
    catch {
        Write-Log -logfile $logfile -Level "INFO" -Message "$($_)"
        $osRegistryChangesArray[$i].PropertyResults = $_
    }
    Write-Log -Level "INFO" -Message "$($app) - Results: $($osRegistryChangesArray[$i].PropertyResults)"
}
# Add changes to hastable for reporting
$allChangeResults.Add("SystemRegistry", $osRegistryChangesArray)

# 
# Default User Registry Settings
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Searching for $($defaultsUserSettingsPath)"
if (Test-Path $defaultsUserSettingsPath) {
    Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Found $($defaultsUserSettingsPath)"
    $defaultUserSettings = Get-Content $defaultsUserSettingsPath

    if ($defaultUserSettings.count -gt 0) {
        Foreach ($item in $defaultUserSettings) {
            $regResults = Start-Process C:\Windows\System32\Reg.exe -ArgumentList "$($item)" -Wait -PassThru

            $usrHashTblTemp = @{
                Name    = $item;
                Results = $regResults
            }

            $regKeyResults.Add($usrHashTblTemp)
        }
    }
   
}
else {
    Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Unable to find $($defaultsUserSettingsPath)"
}
$allChangeResults.Add("DefaultUserRegistryKeys", $regKeyResults)

# 
# Default User Visual Effects Registry Settings
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Searching for $($defaultsUserVisualSettingsPath)"
if (Test-Path $defaultsUserVisualSettingsPath) {
    Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Found $($defaultsUserVisualSettingsPath)"
    $defaultUserVisualSettings = Get-Content $defaultsUserVisualSettingsPath

    if ($defaultUserVisualSettings.count -gt 0) {
        Foreach ($item in $defaultUserVisualSettings) {
            $regResults = Start-Process C:\Windows\System32\Reg.exe -ArgumentList "$($item)" -Wait -PassThru

            $usrVisualHashTblTemp = @{
                Name    = $item;
                Results = $regResults
            }

            $visualEffectsResults.Add($usrVisualHashTblTemp)
        }
    }
}
else {
    Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Unable to find $($defaultsUserVisualSettingsPath)"
}
$allChangeResults.Add("DefaultUserVisualEffectsRegistryKeys", $visualEffectsResults)

# 
# Disable Scheduled Tasks
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Searching for $($ScheduledTasksListPath)"
if (Test-Path $ScheduledTasksListPath) {
    Write-Log -logfile $logfile -Level "INFO" -Message "Found $($ScheduledTasksListPath)"
    $SchTasksList = Get-Content $ScheduledTasksListPath

    if ($SchTasksList.count -gt 0) {
        Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - $($ScheduledTasksListPath) contains $($schTasksList.count) items"
        Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Getting Enabled Scheduled Tasks"
        $EnabledScheduledTasks = Get-ScheduledTask | Where-Object { $_.State -ne "Disabled" }

        Foreach ($item in $SchTasksList) {
            $schTaskHashTbl = @{ SchTaskName = "$($item.trim())"; results = $null }
            Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - $($item): Disabling scheduled task"
            $schTaskResult = $EnabledScheduledTasks | Where-Object { $_.TaskName -like "$($item.trim())" } | Disable-ScheduledTask
            $schTaskHashTbl.results = $schTaskResult
            $schTasksResults.add($schTaskHashTbl)
        }
    }
}
else {
    Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Unable to find $($ScheduledTasksListPath)"
}

$allChangeResults.Add("ScheduledTasks", $schTasksResults)

# Disable Windows Services
Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Searching for $($servicesToDisablePath)"
if (Test-Path $servicesToDisablePath) {
    Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Found $($servicesToDisablePath)"
    $servicesToDisable = Get-Content $servicesToDisablePath
    if ($servicesToDisable.count -gt 0) {
        Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - $($servicesToDisablePath) contains $($servicesToDisable.count) items"

        Foreach ($service in $servicesToDisable) {
            Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Check if $($service) exists"
            $svcHashTbl = @{ Name = $service; DisplayName = $null; Status = $null; StartupType = $null }

            $serviceExists = Get-Service -Name "$($service)" -ErrorAction SilentlyContinue
            if ($serviceExists) {
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Found $($service)"
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Stopping $($service)"
                Stop-Service $service
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Setting StartupType of $($service) to Disabled"
                Set-Service -Name $service -StartupType Disabled
                $serviceState = Get-Service "$($service)" | Select-Object Name, DisplayName, Status, StartupType
                $svcHashTbl.DisplayName = $service.DisplayName
                $svcHashTbl.Status = $service.Status
                $svcHashTbl.StartupType = $service.StartupType
            }
            else {
                Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - $($service) not found"
                $svcHashTbl.Status = "NotFound"
            }

            $serviceChangesList.add($serviceState)
        }
    }
}
else {
    Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Unable to find $($servicesToDisablePath)"
}
$allChangeResults.Add("Services", $serviceChangesList)

# 
# Disable Windows Automatic tracing
# 
Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Searching for $($automaticTracingFilePath)"
if (Test-Path $automaticTracingFilePath) {
    Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Found $($automaticTracingFilePath)"
    $AutomaticTracers = Get-Content $automaticTracingFilePath
    if ($AutomaticTracers.count -gt 0) {
        Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - $($automaticTracingFilePath) contains $($AutomaticTracers.count) tracers"
        $tracerHashTbl = @{RegPath = $tracer; Value = 0; Property = "Start"; PropertyType = "DWORD"; results = $null }

        Foreach ($tracer in $AutomaticTracers) {
            Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Testing for existance of $($tracer) tracing"
            if (Test-Path "$($tracer)") {
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Disabling $($tracer) tracing"
                $tracerResults = New-ItemProperty -Path "$($tracer)" -Name "Start" -PropertyType "DWORD" -Value "0" -Force
                $tracerHashTbl.results = $tracerResults
            }
            else {
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Unable to find $($tracer) tracing"
                $tracerHashTbl.results = "NotFound"
            }
            $tracingChangesList.Add($tracerHashTbl)
        }
    }
}
else {
    Write-Log -logfile $logfile -Level "INFO" -Message  "$($app) - Unable to find $($automaticTracingFilePath)"
}
$allChangeResults.Add("Tracing", $tracingChangesList)

# 
# Disable Windows Features
# 
foreach ($feature in $winFeaturesToDisable) {
    $featureState = Get-WindowsOptionalFeature -Online -FeatureName $feature
    # ).State
    if($featureState.State -like "disabled"){
        Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - $($feature) Feature Already Disabled"
    }
    else{
        Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Disabling $($feature) Feature"
        Disable-WindowsOptionalFeature -Online -FeatureName $feature
    }

}

# 
# Disable System Restore
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Disabling System Restore for C:"
Disable-ComputerRestore -Drive "C:\"

# 
# Disable Hibernate
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Disabling Hibernate"
powercfg /hibernate off

# 
# Disable Crash Dumps
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Disabling System crash dumps"
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'CrashDumpEnabled' -Value '1'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'LogEvent' -Value '0'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'SendAlert' -Value '0'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'AutoReboot' -Value '1'

# 
# Disable Logon Background
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Disable Logon Background"
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'DisableLogonBackgroundImage' -Value '1'

# 
# Network Optimization
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Disable SMB Bandwidth Throttling"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" DisableBandwidthThrottling -Value $DisableBandwidthThrottling -Force

Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Set FileInfoCacheEntries to $($FileInfoCacheEntriesValue)"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" FileInfoCacheEntriesMax -Value $FileInfoCacheEntriesValue -Force

Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Set DirectoryCacheEntriesMax to $($DirectoryCacheEntriesMax)"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" DirectoryCacheEntriesMax -Value $DirectoryCacheEntriesMax -Force

Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Set FileNotFoundCacheEntriesMax to $($FileNotFoundCacheEntriesMax)"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" FileNotFoundCacheEntriesMax -Value $FileNotFoundCacheEntriesMax -Force

Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Set DormantFileLimit to $($DormantFileLimit)"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters" DormantFileLimit -Value $DormantFileLimit -Force

# 
# Disk cleanup will occur post application installs
# 

# 
# Export Config changes to json file
# 
$allChangeResults | ConvertTo-JSON | Set-Content (Join-Path -Path $auditLogPath -ChildPath "$(Get-Date -Format yyyyMMddhhmm)_$($buildName)_$($auditLogFile)")