[CmdletBinding()]

Param (
    [string]$wimFile,
    [string]$mountPath = "c:\temp\wim_mount",
    [string]$driversPath,
    # [switch]$isoFile,
    [string]$isoPath = "c:\temp\iso\windows10_$(Get-Date -Format yyyyMMddHHmm).iso",
    [string]$bootLoaderPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\etfsboot.com",
    [string]$oscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe",
    [string]$winPEPath = "C:\Temp\WinPE_amd64",
    [string]$winPEWimPathStub = "media\sources\boot.wim",
    [string]$winPEMountPathStub = "mount",
    [string]$makeWinPEMediaPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\MakeWinPEMedia.cmd",
    [string]$copyPEPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\copype.cmd",
    [string]$wimIndex = 1,
    [string]$pe_arch = "amd64"
    
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

$winPEWimPath = Join-Path -Path $winPEPath -ChildPath $winPEWimPathStub
$winPEMountPath = Join-Path -Path $winPEPath -ChildPath $winPEMountPathStub

Write-Log -Level "INFO" -Message "Win PE Wim Path: $($winPEWimPath)"
Write-Log -Level "INFO" -Message "Win PE Wim Mount Path: $($winPEMountPath)"
Write-Log -Level "INFO" -Message "Win PE ISO Path: $($isoPath)"

# Create Directories if they do not exist
if (-Not (Test-Path $winPEWimPath)) {
    New-Item -ItemType Directory -Path $winPeWimPath -Force | Out-Null
}

if (-Not (Test-Path $winPEMountPath)) {
    New-Item -ItemType Directory -Path $winPEMountPath -Force | Out-Null
}

if (-Not (Test-Path $isoPath)) {
    New-Item -ItemType Directory -Path $isoPath -Force | Out-Null
}

if (-Not (Test-Path $mountPath)) {
    New-Item -ItemType Directory -Path $mountPath -Force | Out-Null
}

# # Mount WIM
# Write-Log -Level "INFO" -Message "Mounting -ImagePath $($wimFile) -index:$($wimIndex) -Path:$($mountPath) -Optimize"
# Mount-WindowsImage -Path $mountPath -Index $wimIndex -ImagePath $wimFile -Optimize

# # Add Drivers in Folder
# Write-Log -Level "INFO" -Message "Adding drivers in $($driversPath) to $($mountPath) -Recurse"
# Add-WindowsDriver -Path $mountPath -Driver $driversPath -Recurse

# # Commit changes and unmount WIM
# Write-Log -Level "INFO" -Message "Dismount $($mountPath) and commit changes"
# Dismount-WindowsImage -Path $mountPath -Save

# Copy Window PE FIles
Write-Log -Level "INFO" -Message "WinPE - $($copyPEPath) $($pe_arch) $($winPEPath)"
Start-Process -NoNewWindow -FilePath $copyPEPath -ArgumentList "$($pe_arch) $($winPeWimPath)"

# Find WinPE Boot Wim


# Mount WinPE wim
Write-Log -Level "INFO" -Message "WinPE - Mounting WIM- ImagePath:$($winPeWimPath); index:$($wimIndex); Path:$winPEMountPath)"
Mount-WindowsImage -Path $winPEMountPath -Index $wimIndex -ImagePath $winPeWimPath -Optimize

# Add Drivers in Folder
Write-Log -Level "INFO" -Message "WinPE - Adding drivers from $($driversPath) to $($winPEMountPath)/Recurse"
Add-WindowsDriver -Path $winPEMountPath -Driver $driversPath -Recurse

# Commit changes and unmount WIM
Write-Log -Level "INFO" -Message "WinPE - Dismount and commit $($winPEMountPath)"
Dismount-WindowsImage -Path $winPEMountPath -Save

# Copy PE Wim to ISO
Write-Log -Level "INFO" -Message "WinPE - Copy boot.wim to ISO location"


# Create ISO
Write-Log -Level "INFO" -Message "ISO - OSCDIMG building iso at $($isoPath)"
Write-Log -Level "INFO" -Message "ISO - oscdimg -n -m -o u2 -b$($bootLoaderPath) $($SOURCEFILES) $($isoPath)"
# Start-Process -NoNewWindow -FilePath $oscdimgPath -ArgumentList "-n -m -o u2 -b$($bootLoaderPath) $($SOURCEFILES) $($isoPath)"

# Clean Up 
Write-Log -Level "INFO" -Message "Clean-up paths"
# Delete files and folders in winPEPath
Get-ChildItem -Recurse $winPEWimPath  | Remove-Item -Force
Get-ChildItem -Recurse $winPEMountPath | Remove-Item -Recurse -Force