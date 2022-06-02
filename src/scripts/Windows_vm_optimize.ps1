[CmdletBinding()]
Param (
    [string]$outPath = "c:\temp",
    [string]$sdelete_uri = "https://download.sysinternals.com/files/SDelete.zip",
    $dotNetPaths = @("c:\windows\microsoft.net\framework64\v4.0.30319\ngen.exe", "c:\windows\microsoft.net\framework\v4.0.30319\ngen.exe"),
    $fileExtensionsToRemove = @("*.tmp", "*.dmp", "*.etl", "*.evtx", "thumbcache*.db", "*.log")
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
        $patharray
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
        [string]$sdelete_params = "-nobanner -z"
    )
    
    $sdeleteZipPath = Join-Path -Path $outpath -ChildPath "sdelete.zip"

    Write-Log -logfile $logfile -Level "INFO" -Message "Downloading Sdelete"
    Invoke-WebRequest -Uri $sdelete_uri -OutFile $sdeleteZipPath -UseBasicParsing
    
    Write-Log -logfile $logfile -Level "INFO" -Message "Unzipping $($sdeleteZipPath) to $($outPath)"
    Expand-Archive -Path $sdeleteZipPath -DestinationPath $outpath 
    
    Write-Log -logfile $logfile -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath 'sdelete.exe') -ArgumentList $($sdelete_params)"
    Start-Process -NoNewWindow -PassThru -FilePath (Join-Path -Path $outpath -ChildPath "sdelete.exe") -ArgumentList $sdelete_params -Wait #| Out-Null
    
}

Function Start-DotNetRecompile {
    [CmdletBinding()]
    Param (
        $dotNetPaths = @("c:\windows\microsoft.net\framework64\v4.0.30319\ngen.exe", "c:\windows\microsoft.net\framework\v4.0.30319\ngen.exe"),
        [string]$dotNetRecompileArgs = "update /force"
    )
    $results = New-Object System.Collections.Generic.List[System.Object]
    foreach ($dotNetPath in $dotNetPaths) {
        Write-Log -logfile $logfile -Level "INFO" -Message "Recompiling x64 dot net"
        $results.add((Start-Process -NoNewWindow -Passthru -FilePath $dotNetPath -ArgumentList $dotNetRecompileArgs -Wait))

    }
}

$tempPaths = New-Object System.Collections.Generic.List[System.Object]
$tempPaths.Add($env:temp)
$tempPaths.Add($outPath)

# Recomplie Dot Net
Start-DotNetRecompile -dotNetPaths $dotNetPaths 

# Clean-up Online image
# Write-Log -logfile $logfile -logfile $logfile -Level "INFO" -Message "Running Dism.exe /online /Cleanup-Image /StartComponentCleanup"
# $dismCleanupResults = Start-Process -NoNewWindow -Wait -PassThru -FilePath "Dism.exe" -ArgumentList "/online /Cleanup-Image /StartComponentCleanup"

# Clean-up and remove all superseded versions of every component in the component store
Write-Log -logfile $logfile -Level "INFO" -Message "Running Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase"
$dismCleanupResults = Start-Process -NoNewWindow -Wait -FilePath "Dism.exe" -ArgumentList "/online /Cleanup-Image /StartComponentCleanup /ResetBase"

# Clean up tmp files from Windows
Write-Log -logfile $logfile -Level "INFO" -Message "Getting .tmp, .dmp, .etl, .evtx, thumbcache*.db, *.log files for removal"
# $filesToClean = Get-ChildItem -Path c:\* -Include (*.tmp, *.dmp, *.etl, *.evtx, thumbcache*.db, *.log) -File -Recurse -Force -ErrorAction SilentlyContinue
# This takes way too long.  Need a faster way to look up these dfiles.
$filesToClean = Get-ChildItem -Path c:\ -File -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.extension -in ("*.tmp", "*.dmp", "*.etl", "*.evtx", "*.log") -or $_.Name -like "thumbcache*.db" }
Write-Log -logfile $logfile -Level "INFO" -Message "Removing .tmp, .dmp, .etl, .evtx, thumbcache*.db, *.log"
foreach ($file in $filesToClean) {
    # Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($file.FullName)"
    if (Test-Path $file.FullName) {
        [System.IO.File]::Delete($file.fullname)
    }
    
}

# Clean up from installs
Clear-Directory -patharray $tempPaths

Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($env:ProgramData)\Microsoft\Windows\WER\Temp\*"
Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\Temp\* -Recurse -Force -ErrorAction SilentlyContinue

Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($env:ProgramData)\Microsoft\Windows\WER\ReportArchive\*"
Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\ReportArchive\* -Recurse -Force -ErrorAction SilentlyContinue

Write-Log -logfile $logfile -Level "INFO" -Message "Removing $($env:ProgramData)Microsoft\Windows\WER\ReportQueue\*"
Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\ReportQueue\* -Recurse -Force -ErrorAction SilentlyContinue

# Clear Recyclebin
Write-Log -logfile $logfile -Level "INFO" -Message "Clearing Recycle Bin"
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Clear BCCache
Write-Log -logfile $logfile -Level "INFO" -Message "Clearing BC Cache"
Clear-BCCache -Force -ErrorAction SilentlyContinue

# Defragment disk
Write-Log -LogFile $logfile -Level "INFO" -Message "Defragment C:"
Optimize-Volume -DriveLetter C -Defrag -Verbose

# Clean free space
Write-Log -logfile $logfile -Level "INFO" -Message "Starting sdelete to zero disk space"
Start-Sdelete -sdelete_params "-nobanner -z /accepteula C:"

# Clean up after sdelete
Write-Log -logfile $logfile -Level "INFO" -Message "Final temp path clean-up"
Clear-Directory -patharray $tempPaths
