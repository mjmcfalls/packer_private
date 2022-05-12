[CmdletBinding()]
Param (
    [string]$outPath = "c:\temp",
    [string]$sdelete_uri = "https://download.sysinternals.com/files/SDelete.zip"
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

Function Clean-Directory {
    [Cmdletbinding()]
    Param(
        $patharray
    )

    foreach ($tpath in $tempPaths) {
        Write-Log -Level "INFO" -Message "Cleaning $($tpath)"
    
        Write-Log -Level "INFO" -Message "Getting files in $($tpath)"
        $tempFiles = Get-ChildItem $tpath -Recurse -File
        # $tempFiles
        Write-Log -Level "INFO" -Message "Removing files in $($tpath)"
        $tempFiles | Remove-Item -Force #-ErrorAction SilentlyContinue
    
        Write-Log -Level "INFO" -Message "Getting Directories in $($tpath)"
        $tempDirs = Get-ChildItem $tpath -Recurse -Directory
        # $tempFiles
        Write-Log -Level "INFO" -Message "Removing Directories in $($tpath)"
        $tempDirs | Remove-Item -Force -Recurse #-ErrorAction SilentlyContinue
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
    Start-Process -NoNewWindow -FilePath (Join-Path -Path $outpath -ChildPath "sdelete.exe") -ArgumentList $sdelete_params
    
}

# Recomplie Dot Net x64
Write-Log -Level "INFO" -Message "Recompiling x64 dot net"
Start-Process -NoNewWindow -FilePath "c:\windows\microsoft.net\framework64\v4.0.30319\ngen.exe"  -ArgumentList "update /force" -Wait


# Recomplie Dot Net x86
Write-Log -Level "INFO" -Message "Recompiling x86 dot net"
Start-Process -NoNewWindow -FilePath "c:\windows\microsoft.net\framework\v4.0.30319\ngen.exe "  -ArgumentList "update /force" -Wait

# Clean-up Online image
Write-Log -Level "INFO" -Message "Running Dism.exe /online /Cleanup-Image /StartComponentCleanup"
Start-Process -NoNewWindow -FilePath "Dism.exe" -ArgumentList "/online /Cleanup-Image /StartComponentCleanup"

# Clean-up and remove all superseded versions of every component in the component store
# Write-Log -Level "INFO" -Message "Running Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase"
# Start-Process -NoNewWindow -FilePath "Dism.exe" -ArgumentList "/online /Cleanup-Image /StartComponentCleanup /ResetBase"


$tempPaths = New-Object System.Collections.Generic.List[System.Object]
$tempPaths.Add($env:temp)
$tempPaths.Add($outPath)

Clean-Directory -patharray $tempPaths


# Clean free space

Clean-Directory -patharray $tempPaths

