[CmdletBinding()]

Param (
    [string]$app = "msadk",
    [string]$searchPath = $env:temp,
    [string]$installParams = "/ceip off /norestart /quiet /features OptionId.WindowsPerformanceToolkit OptionId.DeploymentTools OptionId.ApplicationCompatibilityToolkit OptionId.WindowsAssessmentToolkit",
    [string]$installername = "adksetup.exe"
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

# New-TempFolder -Path $outpath

# if ($public.IsPresent) {
#     Write-Log -Level "INFO" -Message "ADK install from Web"
#     Invoke-WebRequest -Uri "$($uri)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
# }
# else {
#     Write-Log -Level "INFO" -Message "Getting $($uri)$($appuri)$($installername)"
#     Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
# }

# if ($install.IsPresent) {

$appSrcPath = Get-ChildItem -File -Path $searchPath | Where-Object { $_.name -match $installername }

    
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
    Start-Process -NoNewWindow -FilePath $appSrcPath.FullName -ArgumentList "$($installParams)" -Wait
}

    
# }

# if ($cleanup.IsPresent) {
#     if (Test-Path (Join-Path -Path $outpath -ChildPath $installername)) {
#         (Join-Path -Path $outpath -ChildPath $installername).Delete()
#     }
# }

