
[CmdletBinding()]
Param (
    [int]$debugging = 1,
    $postfix = (Get-Date -format yyyyMMddhhmm),
    [string]$outPath = "c:\users\mmcfall\Desktop\packer\",
    [string]$debugLog = "$($outpath)\packerlog_$($postfix).log",
    [string]$varsfile = ".\vars\Windows_VCL\Windows_vcl.pkrvars.hcl",
    [string]$appvarFile = "vars\Windows_App_Vars.pkrvars.hcl",
    [string]$secretsfile = ".\secrets\secrets.pkrvars.hcl",
    [string]$buildfile = ".\Windows10_vcl.pkr.hcl",
    [string]$packerpath = ".\bin\packer.exe",
    [string]$vm_name = "Windows10",
    [string]$keepregistered = "false",
    [string]$isoPath,
    [string]$isoSha,
    [string]$unattendPath = "C:\Users\mmcfall\Desktop\dev\UnattendFiles\Windows10_ltsb\autounattend.xml",
    [string]$buildTarget = "win_iso.vmware-iso.win_iso"
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

# Start Script Stop watch
$scriptStopWatch = [System.Diagnostics.StopWatch]::StartNew()


# Virtual machine names
$vm_name_postfix = "$($vm_name)_$($postfix)"

# Set ENV Variables for debugging
$env:PACKER_LOG = $debugging
$env:PACKER_LOG_PATH = $debugLog

$vm_name_postfix_StopWatch = [System.Diagnostics.StopWatch]::StartNew()
Write-Log -Level "INFO" -Message "Building $($vm_name_postfix) from $($isoPath)"

$env:PACKER_LOG_PATH = "$($outPath)\$($vm_name_postfix).log"

Write-Log -Level "DEBUG" -Message "$($packerpath) build -timestamp-ui -only $buildTarget -var "autounattend=$($unattendPath)" -var `"iso_checksum=$($isoSha)`" -var `"iso_url=$($isoPath)`" -var `"vm_name=$($vm_name_postfix)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" 
Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -timestamp-ui -only $buildTarget -var "autounattend=$($unattendPath)" -var `"iso_checksum=$($isoSha)`" -var `"iso_url=$($isoPath)`" -var `"vm_name=$($vm_name_postfix)`" -var-file $($varsfile) -var-file $($appvarFile) -var-file $($secretsfile) $($buildfile)" -Wait

Write-Log -Level "INFO" -Message "End Build $($vm_name_postfix) from $($isoPath)"

$bareVM_StopWatch.Stop()

$scriptStopWatch.Stop()


Write-Log -Level "INFO" -Message "Bare Build Time: $($vm_name_postfix_StopWatch.Elapsed)"
Write-Log -Level "INFO" -Message "Build Script Time: $($scriptStopWatch.Elapsed)"
