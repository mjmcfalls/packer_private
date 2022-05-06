[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath = $env:temp,
    [switch]$install,
    [string]$installParams = "/quiet",
    [switch]$public,
    [string]$appuri = "/apps/Python/",
    [string]$installername,
    [string]$version
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

if ($public.IsPresent) {
    $installername = ($uri -Split "/")[-1]
    
    Write-Log -Level "INFO" -Message "Fetch from Web"
    Invoke-WebRequest -Uri "$($uri)" -OutFile (Join-Path -Path $outpath -ChildPath $installername) -UseBasicParsing


}
else {
    Write-Log -Level "INFO" -Message "Fetch from $($uri)$($appuri)$($installername)"
    Invoke-WebRequest -Uri "$($uri)$($appuri)$($installername)" -OutFile (Join-Path -Path $outpath -ChildPath $installername)  -UseBasicParsing
}


if ($install.IsPresent) {
    $installerPath = Join-Path -Path $outpath -ChildPath $installername

    # Set Version if not present or contains a period
    if(-Not $version){
        $version = (($installername -Split "-")[-1] -Split ".")[0..1] -Join ""
        Write-Log -Level "INFO" -Message "Version: $($version)"
    }
    else{
        if($version.contains(".")){
            $version = $version.replace(".","")
        }
    }
    
    # Copy unattend file to same directory as python installer
    Write-Log -Level "INFO" -Message "Searching for Python$($version) unattend file"
    $unattendXmlPath = Get-ChildItem -Path $outpath -Recurse -File | Where-Object {$_.Name -Like "Python$($verion)*"}
    if($unattendXmlPath){
        Write-Log -Level "INFO" -Message "Found: $($unattendXmlPath)"
        Write-Log -Level "INFO" -Message "Copy $($unattendXmlPath) to $(Join-Path -Path $outpath -ChildPath "unattend.xml")"
        Copy-Item -Path $unattendXmlPath -Destination (Join-Path -Path $outpath -ChildPath "unattend.xml")
    }
    else{
        Write-Log -Level "ERROR" -Message "No Unattend file found!"
    }

    Write-Log -Level "INFO" -Message "Getting Extension of $($installername)"
    $installerExtension = [System.IO.Path]::GetExtension("$($installerPath)")

    Write-Log -Level "INFO" -Message "Extension is: $($installerExtension)"

    if($installerExtension -like ".msi"){
        Write-Log -Level "INFO" -Message "MSI Install of $($installerPath)"
        Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($env:systemroot)\system32\msiexec.exe -ArgumentList `"/package $($installerPath) $($installParams)`""
        Start-Process -NoNewWindow -FilePath "$($env:systemroot)\system32\msiexec.exe" -ArgumentList "/package $($installerPath) $($installParams)" -Wait
    }
    elseif ($installerExtension -like ".exe") {
        Write-Log -Level "INFO" -Message "EXE Install of $($installername)"
        Write-Log -Level "INFO" -Message "Start-Process -NoNewWindow -FilePath $($installerPath) -ArgumentList `"$($installParams)`""
        Start-Process -NoNewWindow -FilePath $installerPath -ArgumentList "$($installParams)"    
    }

}