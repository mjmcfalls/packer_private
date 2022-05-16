[CmdletBinding()]
Param (
    [string]$outPath = "c:\temp",
    [string]$sdelete_uri = "https://download.sysinternals.com/files/SDelete.zip",
    $dotNetPaths = @("c:\windows\microsoft.net\framework64\v4.0.30319\ngen.exe", "c:\windows\microsoft.net\framework\v4.0.30319\ngen.exe")
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
        Write-Log -Level "INFO" -Message "Cleaning $($tpath)"
    
        Write-Log -Level "INFO" -Message "Getting files in $($tpath)"
        $tempFiles = Get-ChildItem $tpath -Recurse
        # $tempFiles
        Write-Log -Level "INFO" -Message "Removing files in $($tpath)"
        $tempFiles | Remove-Item -Force #-ErrorAction SilentlyContinue

        # Write-Log -Level "INFO" -Message "Getting files in $($tpath)"
        # $tempFiles = Get-ChildItem $tpath -Recurse -File
        # # $tempFiles
        # Write-Log -Level "INFO" -Message "Removing files in $($tpath)"
        # $tempFiles | Remove-Item -Force #-ErrorAction SilentlyContinue
    
        # Write-Log -Level "INFO" -Message "Getting Directories in $($tpath)"
        # $tempDirs = Get-ChildItem $tpath -Recurse -Directory
        # # $tempFiles
        # Write-Log -Level "INFO" -Message "Removing Directories in $($tpath)"
        # $tempDirs | Remove-Item -Force -Recurse #-ErrorAction SilentlyContinue
    }

}

Function Start-Sdelete {
    [CmdletBinding()]
    Param (
        [string]$outPath = "c:\temp",
        [string]$sdelete_uri = "https://download.sysinternals.com/files/SDelete.zip",
        [string]$sdelete_params = "-nobanner -z -c -p 1"
    )
    
    $sdeleteZipPath = Join-Path -Path $outpath -ChildPath "sdelete.zip"

    Write-Log -Level "INFO" -Message "Downloading Sdelete"
    Invoke-WebRequest -Uri $sdelete_uri -OutFile $sdeleteZipPath -UseBasicParsing
    
    Write-Log -Level "INFO" -Message "Unzipping $($sdeleteZipPath) to $($outPath)"
    Expand-Archive -Path $sdeleteZipPath -DestinationPath $outpath 
    
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $(Join-Path -Path $outpath -ChildPath 'sdelete.exe') -ArgumentList $($sdelete_params)"
    Start-Process -NoNewWindow -FilePath (Join-Path -Path $outpath -ChildPath "sdelete.exe") -ArgumentList $sdelete_params -Wait
    
}

Function Start-DotNetRecompile {
    [CmdletBinding()]
    Param (
        $dotNetPaths = @("c:\windows\microsoft.net\framework64\v4.0.30319\ngen.exe", "c:\windows\microsoft.net\framework\v4.0.30319\ngen.exe"),
        [string]$dotNetRecompileArgs = "update /force"
    )

    foreach ($dotNetPath in $dotNetPaths) {
        Write-Log -Level "INFO" -Message "Recompiling x64 dot net"
        Start-Process -NoNewWindow -FilePath $dotNetPath -ArgumentList $dotNetRecompileArgs -Wait

    }
}

# Recomplie Dot Net
Start-DotNetRecompile -dotNetPaths $dotNetPaths 

# Clean-up Online image
Write-Log -Level "INFO" -Message "Running Dism.exe /online /Cleanup-Image /StartComponentCleanup"
Start-Process -NoNewWindow -FilePath "Dism.exe" -ArgumentList "/online /Cleanup-Image /StartComponentCleanup"

# Clean-up and remove all superseded versions of every component in the component store
# Write-Log -Level "INFO" -Message "Running Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase"
# Start-Process -NoNewWindow -FilePath "Dism.exe" -ArgumentList "/online /Cleanup-Image /StartComponentCleanup /ResetBase"

$tempPaths = New-Object System.Collections.Generic.List[System.Object]
$tempPaths.Add($env:temp)
$tempPaths.Add($outPath)

# Clean up from installs
Clear-Directory -patharray $tempPaths

# Clean up tmp files from Windows
Write-Log -Level "INFO" -Message "Removing .tmp, .dmp, .etl, .evtx, thumbcache*.db, *.log"
Get-ChildItem -Path c:\ -Include *.tmp, *.dmp, *.etl, *.evtx, thumbcache*.db, *.log -File -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -ErrorAction SilentlyContinue

Write-Log -Level "INFO" -Message "Removing $($env:ProgramData)\Microsoft\Windows\WER\Temp\*"
Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\Temp\* -Recurse -Force -ErrorAction SilentlyContinue

Write-Log -Level "INFO" -Message "Removing $($env:ProgramData)\Microsoft\Windows\WER\ReportArchive\*"
Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\ReportArchive\* -Recurse -Force -ErrorAction SilentlyContinue

Write-Log -Level "INFO" -Message "Removing $($env:ProgramData)Microsoft\Windows\WER\ReportQueue\*"
Remove-Item -Path $env:ProgramData\Microsoft\Windows\WER\ReportQueue\* -Recurse -Force -ErrorAction SilentlyContinue

# Clear Recyclebin
Write-Log -Level "INFO" -Message "Clearing Recycle Bin"
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Clear BCCache
Write-Log -Level "INFO" -Message "Clearing BC Cache"
Clear-BCCache -Force -ErrorAction SilentlyContinue

# Clean free space
Start-Sdelete

# Clean up after sdelete
Clear-Directory -patharray $tempPaths

