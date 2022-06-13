[CmdletBinding()]

Param (
    [string]$app = "Python 2.7.18",
    [string]$searchPath = $env:temp,
    [string]$installParams = "/quiet",
    [string]$installername = "python-2.7.18.amd64.msi",
    [string]$unattendXml
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

Write-Log -Level "INFO" -Message "Starting Install - $($app)"

Write-Log -Level "INFO" -Message "Search for $($installername) in $($searchPath)"
$appSrcPath = Get-ChildItem -File -Path $searchPath -Recurse | Where-Object { $_.name -match $installername }

Write-Log -Level "INFO" -Message "Installer: $($appSrcPath)"

# Set Version if not present or contains a period
if (-Not $version) {
    $version = (($appSrcPath.Name -Split "-")[-1] -Split ".")[0..1] -Join ""
    Write-Log -Level "INFO" -Message "Version: $($version)"
}
else {
    if ($version.contains(".")) {
        $version = $version.replace(".", "")
    }
}
    
# # Copy unattend file to same directory as python installer
# if ( $unattendXml ) {

# }
# else {
#     Write-Log -Level "INFO" -Message "Searching for Python$($version) unattend file"
#     $unattendXmlPath = Get-ChildItem -Path $outpath -Recurse -File | Where-Object { $_.Name -Like "Python$($verion)*.xml" }
    
#     if ($unattendXmlPath) {
#         Write-Log -Level "INFO" -Message "Found: $($unattendXmlPath.FullName)"
#     }
#     else {
#         Write-Log -Level "INFO" -Message "No Python$($version) unattend file found."
#     }
        
#     if ($unattendXmlPath) {
#         Write-Log -Level "INFO" -Message "Found: $($unattendXmlPath.FullName)"
#         Write-Log -Level "INFO" -Message "Copy $($unattendXmlPath.FullName) to $(Join-Path -Path $outpath -ChildPath "unattend.xml")"
#         Copy-Item -Path $unattendXmlPath.FullName -Destination (Join-Path -Path $outpath -ChildPath "unattend.xml")
#     }
#     else {
#         Write-Log -Level "ERROR" -Message "No Unattend file found!"
#     }
# }


Write-Log -Level "INFO" -Message "Getting Extension of $($installername)"
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
    Start-Process -NoNewWindow -FilePath $appSrcPath.FullName -ArgumentList "$($installParams)" -Wait
}
