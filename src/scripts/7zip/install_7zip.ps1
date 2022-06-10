[CmdletBinding()]
Param (
    [string]$app = "7zip",
    [string]$searchPath = $env:temp,
    [string]$installParams = "/S",
    [string]$installername = "7z2107-x64.exe"
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

$appSrcPath = Get-ChildItem -File -Path $searchPath | Where-Object { $_.name -match $installername }
# if($appSrcPath -gt 1){
#     Write-Log -Level "INFO" -Message "Powershell magic to find the appropriate installer"
# }

# else{ }

Write-Log -Level "INFO" -Message "Switching to Directory - $($appSrcPath)"
Push-Location $appSrcPath 

Write-Log -Level "INFO" -Message "Getting Extension of $($appSrcPath.FullName)"
$installerExtension = [System.IO.Path]::GetExtension("$($appSrcPath.FullName)")

Write-Log -Level "INFO" -Message "Extension is: $($installerExtension)"

if ($installerExtension -like ".msi") {
    Write-Log -Level "INFO" -Message "MSI Install of $($appSrcPath.FullName)"
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($env:systemroot)\system32\msiexec.exe -ArgumentList `"/package $($appSrcPath.FullName) $($installParams)`""
    Start-Process -NoNewWindow -FilePath "$($env:systemroot)\system32\msiexec.exe" -ArgumentList "/package $($appSrcPath.FullName) $($installParams)" -Wait
}
elseif ($installerExtension -like ".exe") {
    Write-Log -Level "INFO" -Message "EXE Install of $($installername)"
    Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($appSrcPath.FullName) -ArgumentList `"$($installParams)`""
    Start-Process -NoNewWindow -FilePath $appSrcPath.FullName -ArgumentList "$($installParams)" -Wait -PassThru    
}

Pop-Location