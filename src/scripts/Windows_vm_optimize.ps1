[CmdletBinding()]
Param (
    [string]$outPath = "c:\temp",
    [string]$sdelete_uri = "https://download.sysinternals.com/files/SDelete.zip",
    $dotNetPaths = @("c:\windows\microsoft.net\framework64\v4.0.30319\ngen.exe", "c:\windows\microsoft.net\framework\v4.0.30319\ngen.exe"),
    $fileExtensionsToRemove = @("*.tmp", "*.dmp", "*.etl", "*.evtx", "thumbcache*.db", "*.log"),
    [switch]$sdelete,
    [string]$sdeleteSearchPath = "C:\Program Files\Sysinternals"
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

Function Clear-Directory {
    [Cmdletbinding()]
    Param(
        $patharray,
        [string]$app
    )

    foreach ($tpath in $tempPaths) {
        Write-Log -logfile $logfile -Level "INFO" -Message "Cleaning $($tpath)"
    
        # Write-Log -logfile $logfile -Level "INFO" -Message "Getting files in $($tpath)"
        # $tempFiles = Get-ChildItem $tpath -Recurse
        # $tempFiles
        # Write-Log -logfile $logfile -Level "INFO" -Message "Removing files in $($tpath)"
        # foreach($file in $tempFiles){
        #     Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($file.fullname)"
        #     Remove-Item -Path $file.fullname -Force
        # }
        # $tempFiles | Remove-Item -Force #-ErrorAction SilentlyContinue

        Write-Log -logfile $logfile -Level "INFO" -Message "Getting files in $($tpath)"
        $tempFiles = Get-ChildItem $tpath -Recurse -File
        # $tempFiles
        Write-Log -logfile $logfile -Level "INFO" -Message "Removing files in $($tpath)"
        # $tempFiles | Remove-Item -Force #-ErrorAction SilentlyContinue
        foreach ($file in $tempFiles) {
            # Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($file.fullname)"
            # Remove-Item -Path $file.fullname -Force -Recurse
            # $file.Delete()
            [System.IO.File]::Delete($file.fullname)
        }
    
        Write-Log -logfile $logfile -Level "INFO" -Message "Getting Directories in $($tpath)"
        $tempDirs = Get-ChildItem $tpath -Recurse -Directory | Sort-Object -Descending FullName
        # # $tempFiles
        Write-Log -logfile $logfile -Level "INFO" -Message "Removing Directories in $($tpath)"
        foreach ($dir in $tempDirs) {
            # Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($dir.fullname)"
            # Remove-Item -Path $dir.fullname -Force -Recurse
            Try {
                [io.directory]::delete($dir.fullname)
            }
            catch {
                Remove-Item $dir -Recurse -Force
            }
        }
        # $tempDirs | Remove-Item -Force -Recurse #-ErrorAction SilentlyContinue
    }

}

Function Start-Sdelete {
    [CmdletBinding()]
    Param (
        [string]$outPath = "c:\temp",
        [string]$sdelete_uri = "https://download.sysinternals.com/files/SDelete.zip",
        [string]$sdelete_params = "-nobanner -z",
        [string]$sdelete_exe = "sdelete.exe",
        [string]$app
    )
    
    Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Searching for $($sdelete_exe) in $($sdeleteSearchPath)"
    $sdeleteLocalFiles = Get-Childitem -File -Recurse -Path $sdeleteSearchPath | Where-Object { $_.Name -like "$($sdelete_exe)" }

    if ($sdeleteLocalFiles) {
        Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Found $($sdeleteLocalFiles)"
        $sdelete_Path = $sdeleteLocalFiles.FullName
    }
    else {
        Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - $($sdelete_exe) not found locally"
        $sdeleteZipPath = Join-Path -Path $outpath -ChildPath "sdelete.zip"

        Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Downloading Sdelete"
        Invoke-WebRequest -Uri $sdelete_uri -OutFile $sdeleteZipPath -UseBasicParsing
        
        Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Unzipping $($sdeleteZipPath) to $($outPath)"
        Expand-Archive -Path $sdeleteZipPath -DestinationPath $outpath 
        $sdelete_path = Join-Path -Path $outpath -ChildPath "$($sdelete_exe)"
    }

    
    Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Start-Process -NoNewWindow -FilePath $($sdelete_path) -ArgumentList $($sdelete_params)"
    $sdeleteResults = Start-Process -NoNewWindow -PassThru -FilePath ($sdelete_path) -ArgumentList $sdelete_params -Wait
    
}

Function Start-DotNetRecompile {
    [CmdletBinding()]
    Param (
        $dotNetPaths = @("c:\windows\microsoft.net\framework64\v4.0.30319\ngen.exe", "c:\windows\microsoft.net\framework\v4.0.30319\ngen.exe"),
        [string]$dotNetRecompileArgs = "update /force",
        [string]$app
    )
    $results = New-Object System.Collections.Generic.List[System.Object]
    foreach ($dotNetPath in $dotNetPaths) {
        Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Recompiling x64 dot net"
        $results.add((Start-Process -NoNewWindow -Passthru -FilePath $dotNetPath -ArgumentList $dotNetRecompileArgs -Wait))

    }
}
$app = "VM Optimize"
$svcdefragsvc = "defragsvc"
$tempPaths = New-Object System.Collections.Generic.List[System.Object]
$tempPaths.Add($env:temp)
$tempPaths.Add($outPath)

# Recomplie Dot Net
Start-DotNetRecompile -dotNetPaths $dotNetPaths 

# Clean-up Online image
# Write-Log -logfile $logfile -logfile $logfile -Level "INFO" -Message "Running Dism.exe /online /Cleanup-Image /StartComponentCleanup"
# $dismCleanupResults = Start-Process -NoNewWindow -Wait -PassThru -FilePath "Dism.exe" -ArgumentList "/online /Cleanup-Image /StartComponentCleanup"

# Clean-up and remove all superseded versions of every component in the component store
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Running Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase /Quiet"
$dismCleanupResults = Start-Process -NoNewWindow -Wait -FilePath "Dism.exe" -ArgumentList "/online /Cleanup-Image /StartComponentCleanup /ResetBase /Quiet"

# Clean up tmp files from Windows
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Getting .tmp, .dmp, .etl, .evtx, thumbcache*.db, *.log files for removal"
# $filesToClean = Get-ChildItem -Path c:\* -Include (*.tmp, *.dmp, *.etl, *.evtx, thumbcache*.db, *.log) -File -Recurse -Force -ErrorAction SilentlyContinue
# This takes way too long.  Need a faster way to look up these dfiles.
$filesToClean = Get-ChildItem -Path c:\ -File -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.extension -in ("*.tmp", "*.dmp", "*.etl", "*.evtx", "*.log") -or $_.Name -like "thumbcache*.db" }
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Removing .tmp, .dmp, .etl, .evtx, thumbcache*.db, *.log"
foreach ($file in $filesToClean) {
    # Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($file.FullName)"
    if (Test-Path $file.FullName) {
        [System.IO.File]::Delete($file.fullname)
    }
    
}

# Clean up from installs
Clear-Directory -patharray $tempPaths

Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Removing $($env:ProgramData)\Microsoft\Windows\WER\Temp\*"
Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\Temp\* -Recurse -Force -ErrorAction SilentlyContinue

Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Removing $($env:ProgramData)\Microsoft\Windows\WER\ReportArchive\*"
Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\ReportArchive\* -Recurse -Force -ErrorAction SilentlyContinue

Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Removing $($env:ProgramData)Microsoft\Windows\WER\ReportQueue\*"
Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\ReportQueue\* -Recurse -Force -ErrorAction SilentlyContinue

# Clear Recyclebin
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Clearing Recycle Bin"
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Clear BCCache
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Clearing BC Cache"
Clear-BCCache -Force -ErrorAction SilentlyContinue

if ($sdelete.IsPresent) {
    # Clean free space
    Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Starting sdelete to zero disk space"
    Start-Sdelete -sdelete_params "-nobanner -z /accepteula C:"
}

# Defragment disk
Write-Log -LogFile $logfile -Level "INFO" -Message "$($app) - Defragment C:"
$statusdefragsvc = Get-Service $svcdefragsvc
if ($statusdefragsvc.Status -eq "Stopped") {
    Write-Log -LogFile $logfile -Level "INFO" -Message "$($app) - $($svcdefragsvc) is $($statusdefragsvc.Status)"
    Write-Log -LogFile $logfile -Level "INFO" -Message "$($app) - Setting $($svcdefragsvc) to Manual"
    Set-Service $svcdefragsvc -StartupType Manual
    Write-Log -LogFile $logfile -Level "INFO" -Message "$($app) - Starting $($svcdefragsvc)"
    Start-Service $svcdefragsvc
}

Optimize-Volume -DriveLetter C -Defrag #-Verbose
Write-Log -LogFile $logfile -Level "INFO" -Message "$($app) - Stopping $($svcdefragsvc)"
Stop-Service $svcdefragsvc
Write-Log -LogFile $logfile -Level "INFO" -Message "$($app) - Setting $($svcdefragsvc) to Disabled"
Set-Service $svcdefragsvc -StartupType Disabled

# Clean up after sdelete
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Final temp path clean-up"
Clear-Directory -patharray $tempPaths

