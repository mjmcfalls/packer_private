
[CmdletBinding()]
Param (
    [string]$outPath = "c:\temp",
    [string]$oneDrivePath = "c:\Windows\SysWOW64\onedrivesetup.exe",
    [string]$oneDriveUninstallParams = "/uninstall",
    $appxIgnoreList = @("microsoft.windowscommunicationsapps", "Microsoft.WindowsCalculator", "Microsoft.DesktopAppInstaller", "Microsoft.WindowsStore", "Microsoft.StorePurchaseApp", "Microsoft.Appconnector"),
    $winFeaturesToDisable = @("DirectPlay", "WindowsMediaPlayer"),
    [string]$defaultsUserSettingsPath = "c:\temp\apps\Scripts\Microsoft\DefaultUsersSettings.txt",
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
$appXHashTable = @{}

$schTasksResults = New-Object System.Collections.Generic.List[System.Object]
$regKeyResults = New-Object System.Collections.Generic.List[System.Object]

$osRegistryChangesArray = @(
    @{DisplayName = "Cortana"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCortana'; PropertyType = "DWORD"; Value = 0; ParentPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\'; ParentKey = 'Windows Search'; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "Consumer Features (Internet App Downloads)"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsConsumerFeatures'; PropertyType = "DWORD"; Value = 1; ParentPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows'; ParentKey = 'CloudContent'; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "Disabling Windows Store Updates"; Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate'; Name = 'AutoDownload'; PropertyType = "DWORD"; Value = 2; ParentPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\'; ParentKey = 'WindowsUpdate'; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "Windows tips"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableSoftLanding'; PropertyType = "DWORD"; Value = 1; ParentPath = $null; ParentKey = $null; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "Windows Feeds"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"; Name = "EnableFeeds"; PropertyType = "DWORD"; Value = 0; ParentPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows'; ParentKey = "Windows Feeds"; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "ShellFeedsTaskbarviewMode"; Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" ; Name = "ShellFeedsTaskbarviewMode"; PropertyType = "DWORD"; Value = 2; ParentPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion"; ParentKey = "Feeds"; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "OneDrive - DisableFileSync"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive'; Name = 'DisableFileSync'; PropertyType = "DWORD"; Value = 1; ParentPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\'; ParentKey = 'Skydrive'; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "OneDrive - DisableLibrariesDefaultSaveToSkyDrive"; Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive'; Name = 'DisableLibrariesDefaultSaveToSkyDrive'; PropertyType = "DWORD"; Value = 1; ParentPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\'; ParentKey = 'Skydrive'; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "MS Edge First Run Experience"; Path = "HKLM:\Software\Policies\Microsoft\Edge"; Name = 'HideFirstRunExperience'; PropertyType = "DWORD"; Value = 1; ParentPath = "HKLM:\Software\Policies\Microsoft"; ParentKey = "Edge"; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "OOBE Experience for Current User"; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement'; Name = 'ScoobeSystemSettingEnabled'; PropertyType = "DWORD"; Value = 0; ParentPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion"; ParentKey = "UserProfileEngagement"; ItemResults = $null; PropertyResults = $null }
    @{DisplayName = "First Run Animations"; Path = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'; Name = 'EnableFirstLogonAnimation'; PropertyType = "DWORD"; Value = 0; ParentPath = $null; ParentKey = $null; ItemResults = $null; PropertyResults = $null }
)



if (Test-Path $auditLogPath) {
    Write-Log -Level "INFO" -Message "$($app) - $($auditLogPath) exists"
}
else {
    Write-Log -Level "INFO" -Message "$($app) - Creating $($auditLogPath)"
    New-Item -Path $auditLogPath -ItemType Directory -Force

}



# Set High Performance
$highperfguid = ((((powercfg /list | Select-String "High Performance") -Split ":")[1]) -Split "\(")[0].trim()
Write-Log -logfile $logfile -Level "INFO" -Message "Setting performance plan to $($highperfguid)"
powercfg /setactive "$($highperfguid)"

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


for($i=0; $i -lt $osRegistryChangesArray.length; $i++) {
    Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Disable $($osRegistryChangesArray[$i].DisplayName)"
    if ($osRegistryChangesArray[$i].ParentPath) {
        try {
            Write-Log -Level "INFO" -Message "New-Item -Path $($osRegistryChangesArray[$i].ParentPath) -Name $($osRegistryChangesArray[$i].ParentKey)"
            $newItemResults = New-Item -Path $osRegistryChangesArray[$i].ParentPath -Name $osRegistryChangesArray[$i].ParentKey -ErrorAction Stop
            $osRegistryChangesArray[$i].ItemResults = $newItemResults
        }
        catch {
            Write-Log -Level "INFO" -Message "$($_)"
            $osRegistryChangesArray[$i].ItemResults = $_
        }
    }

    Write-Log -logfile $logfile -Level "INFO" -Message "$($app) -  New-ItemProperty: Path $($osRegistryChangesArray[$i].Path); Name $($osRegistryChangesArray[$i].Name); PropertyType $($osRegistryChangesArray[$i].PropertyType); Value $($osRegistryChangesArray[$i].Value)"
    try {
        $newItemPropertyResults = New-ItemProperty -Path $osRegistryChangesArray[$i].Path -Name $osRegistryChangesArray[$i].Name -PropertyType $osRegistryChangesArray[$i].PropertyType -Value $osRegistryChangesArray[$i].Value -ErrorAction stop
        $osRegistryChangesArray[$i].PropertyResults = $newItemPropertyResults

    }
    catch {
        Write-Log -logfile $logfile -Level "INFO" -Message "$($_)"
        $osRegistryChangesArray[$i].PropertyResults = $_
    }
}



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
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($service): Found Service"
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($service): Stopping Service"
                Stop-Service $service
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($service): Setting StartupType to Disabled"
                Set-Service -Name $service -StartupType Disabled
            }
            else {
                Write-Log -logfile $logfile -Level "INFO" -Message "$($service): Service not found"
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
            Write-Log -logfile $logfile -Level "INFO" -Message "$($tracer): Starting logic to disable tracer"
            Write-Log -logfile $logfile -Level "INFO" -Message  "$($tracer): Testing for existance of tracer"
            if (Test-Path "$($tracer)") {
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($tracer): Disabling tracer"
                New-ItemProperty -Path "$($tracer)" -Name "Start" -PropertyType "DWORD" -Value "0" -Force
            }
            else {
                Write-Log -logfile $logfile -Level "INFO" -Message  "$($tracer): Unable to find"
            }
            
        }
    }
}
else {
    Write-Log -logfile $logfile -Level "INFO" -Message  "Unable to find $($automaticTracingFilePath)"
}

# Disable Windows Features
foreach ($feature in $winFeaturesToDisable) {
    Write-Log -logfile $logfile -Level "INFO" -Message "$($feature): Disabling Windows Feature"
    Disable-WindowsOptionalFeature -Online -FeatureName $feature
}

# Disable System Restore
Write-Log -logfile $logfile -Level "INFO" -Message "Disabling System Restore for C:"
Disable-ComputerRestore -Drive "C:\"

# Disable Hibernate
Write-Log -logfile $logfile -Level "INFO" -Message "Disabling Hibernate"
powercfg /hibernate off

# Disable Crash Dumps
Write-Log -logfile $logfile -Level "INFO" -Message "Disabling System crash dumps"
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