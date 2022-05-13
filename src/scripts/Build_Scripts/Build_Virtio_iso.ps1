[CmdletBinding()]

Param (
    [string]$wimFile,
    [string]$mountPath,
    [string]$driversPath,
    [switch]$isoName,
    [string]$isoPath,
    [string]$bootLoaderPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\etfsboot.com",
    [string]$oscdimgPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe"
    
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

# Mount WIM
Dism /Mount-Image /ImageFile:($wimFile) /MountDir:($mountPath)

# Add Drivers in Folder
Dism /Image:$mountPath /Add-Driver /Driver:$driversPath /Recurse

# Commit changes and unmount WIM
Dism /Unmount-Image /MountDir:$mountPath /Commit


# Copy WinPE Source file
MakeWinPEMedia /UFD C:\WinPE_amd64 F:

# Mount WinPE wim
Dism /Mount-Image /ImageFile:"C:\WinPE_amd64\media\sources\boot.wim" /index:1 /MountDir:"C:\WinPE_amd64\mount"

# Add Drivers in Folder
Dism /Image:$mountPath /Add-Driver /Driver:$driversPath /Recurse

# Commit changes and unmount WIM
Dism /Unmount-Image /MountDir:$mountPath /Commit


# Copy Window PE FIles
copype amd64 $winPEPath


# Create ISO
MakeWinPEMedia /ISO C:\WinPE_amd64 C:\WinPE_amd64\WinPE_amd64.iso
# oscdimg -n -m -bc:\temp\WindowsISO\boot\etfsboot.com $mou C:\temp\WindowsISOdrivers\windows.iso