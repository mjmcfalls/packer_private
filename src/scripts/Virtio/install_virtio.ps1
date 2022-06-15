[CmdletBinding()]
Param (
    [string]$uri,
    [string]$outpath = $env:temp,
    [string]$installParams = "/qn ADDLOCAL=ALL",
    [string]$isoname = "virtio-win-0.1.217.iso",
    [string]$installername = "virtio-win-gt-x64.msi",
    [switch]$cleanup
)

function New-TempFolder {
    [CmdletBinding(
        SupportsShouldProcess = $True
    )]
    param(
        [string]$Path
    )
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path
    }
}

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

$ProgressPreference = 'SilentlyContinue'

New-TempFolder -Path $outpath
$isoPath = Join-Path -Path $outpath -ChildPath $isoname

if ($public.IsPresent) {
    Write-Log -Level "INFO" -Message "Install from Web"
    Invoke-WebRequest -Uri "$($uri)" -OutFile $isoPath -UseBasicParsing
}
else { 
    Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($isoname)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($isoname)" -OutFile $isoPath -UseBasicParsing
}

if ($install.IsPresent) {
    Write-Log -Level "INFO" -Message "Mounting ISO - $($isoPath)"
    $isoMountPoint = Mount-DiskImage -ImagePath $isoPath -PassThru

    $isoDriveLetter = ($isoMountPoint | Get-Volume).DriveLetter
    Write-Log -Level "INFO" -Message "ISO mounted at $($isoDriveLetter)"

    if (-Not $installerPath) {
        $installerObj = Get-ChildItem -Path "$($isoDriveLetter):\" -Recurse -File | Where-Object { $_.Name -Like $installername }
        
        $installerPath = $installerObj.FullName
        Write-Log -Level "INFO" -Message "Installer found at $($installerPath)"
    }
    

    Write-Log -Level "INFO" -Message "Getting Extension of $($installername)"
    $installerExtension = [System.IO.Path]::GetExtension("$($installerPath)")

    Write-Log -Level "INFO" -Message "Extension is: $($installerExtension)"

    if ($installerExtension -like ".msi") {
        Write-Log -Level "INFO" -Message "MSI Install of $($installerPath)"
        Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($env:systemroot)\system32\msiexec.exe -ArgumentList `"/package $($installerPath) $($installParams)`""
        Start-Process -NoNewWindow -Passthru -FilePath "$($env:systemroot)\system32\msiexec.exe" -ArgumentList "/package $($installerPath) $($installParams)" -Wait
    }
    elseif ($installerExtension -like ".exe") {
        Write-Log -Level "INFO" -Message "EXE Install of $($installername)"
        Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($installerPath) -ArgumentList `"$($installParams)`""
        Start-Process -NoNewWindow -Passthru -FilePath $installerPath -ArgumentList "$($installParams)" -Wait    
    }
}

if ($cleanup.IsPresent) {
    if (Test-Path (Join-Path -Path $outpath -ChildPath $installername)) {
        (Join-Path -Path $outpath -ChildPath $installername).Delete()
    }
}

Dismount-DiskImage -ImagePath $isoPath