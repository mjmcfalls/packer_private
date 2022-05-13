[CmdletBinding()]

Param (
    [string]$windowsWimFile = "install.wim",
    [string]$bootWimFile = "boot.wim",
    [string]$setupIsoPath,
    [string]$mountPath = "c:\temp\wim_mount",
    [string]$driversPath,
    [string]$isoPath = "c:\temp\iso\windows10_$(Get-Date -Format yyyyMMddHHmm).iso",
    [string]$bootLoaderPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\etfsboot.com",
    [string]$oscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe",
    [string]$winPEPath = "C:\Temp\WinPE_amd64",
    [string]$winPEWimPathStub = "sources\boot.wim",
    [string]$winPEMountPathStub = "mount",
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

# Find install wim
Write-Log -Level "INFO" -Message "Windows - Searching for $($windowsWimFile) in $($setupIsoPath)"
$windowsWimPath = Get-ChildItem -Recurse -Path $setupIsoPath | Where-Object { $_.name -like $windowsWimFile }

if ($windowsWimPath) {
    Write-Log -Level "INFO" -Message "Windows - Found at $($windowsWimPath.FullName)"
    # Mount WIM
    Write-Log -Level "INFO" -Message "Windows - Mounting -ImagePath $($windowsWimPath.FullName) -index:$($wimIndex) -Path:$($mountPath) -Optimize"
    Mount-WindowsImage -Path $mountPath -Index $wimIndex -ImagePath $windowsWimPath.FullName -Optimize

    # Add Drivers in Folder
    Write-Log -Level "INFO" -Message Windows - "Adding drivers in $($driversPath) to $($mountPath) -Recurse"
    Add-WindowsDriver -Path $mountPath -Driver $driversPath -Recurse

    # Commit changes and unmount WIM
    Write-Log -Level "INFO" -Message "Windows - Dismount $($mountPath) and commit changes"
    Dismount-WindowsImage -Path $mountPath -Save
}
else {
    Write-Log -Level "ERROR" -Message "Windows - No $($windowsWimFile) found in $($setupIsoPath)"
}


# Find WinPE Boot Wim
Write-Log -Level "INFO" -Message "WinPE - Searching for $($bootWimFile) in $($setupIsoPath)"

$bootWimPath = Get-ChildItem -Recurse -Path $setupIsoPath | Where-Object { $_.name -like $bootWimFile }

if ($bootWimPath) {
    Write-Log -Level "INFO" -Message "WinPE - Found at $($bootWimPath.FullName)"
    # Mount WinPE wim
    Write-Log -Level "INFO" -Message "WinPE - Mounting WIM- ImagePath:$($bootWimPath.FullName); index:$($wimIndex); Path:$winPEMountPath)"
    Mount-WindowsImage -Path $winPEMountPath -Index $wimIndex -ImagePath $bootWimPath.FullName -Optimize

    # Add Drivers in Folder
    Write-Log -Level "INFO" -Message "WinPE - Adding drivers from $($driversPath) to $($winPEMountPath)/Recurse"
    Add-WindowsDriver -Path $winPEMountPath -Driver $driversPath -Recurse

    # Commit changes and unmount WIM
    Write-Log -Level "INFO" -Message "WinPE - Dismount and commit $($winPEMountPath)"
    Dismount-WindowsImage -Path $winPEMountPath -Save
}
else {
    Write-Log -Level "ERROR" -Message "WinPe - No $($bootWimFile) found in $($setupIsoPath)"
}


# Create ISO
Write-Log -Level "INFO" -Message "ISO - OSCDIMG building iso at $($isoPath)"
Write-Log -Level "INFO" -Message "ISO - oscdimg -n -m -o u2 -b$($bootLoaderPath) $($setupIsoPath) $($isoPath)"
Start-Process -NoNewWindow -FilePath $oscdimgPath -ArgumentList "-n -m -o u2 -b$($bootLoaderPath) $($setupIsoPath) $($isoPath)"

# Clean Up 
Write-Log -Level "INFO" -Message "Clean-up paths"
Get-ChildItem -Recurse $winPEMountPath | Remove-Item -Recurse -Force
Get-ChildItem -Recurse $mountPath | Remove-Item -Recurse -Force