
[CmdletBinding()]
Param (
    [int]$debugging = 1,
    $postfix = (Get-Date -format yyyyMMddhhmm),
    [string]$debugLog = "d:\temp\packerlog_$($postfix).log",
    [string]$varsfile,
    [string]$secretsfile,
    [string]$buildfile,
    [string]$packerpath = ".\bin\packer.exe",
    [string]$vm_name = "Windows10",
    [string]$outPath = "c:\users\mmcfall\Desktop\VMs\",
    [string]$keepregistered = "false",
    [string]$switch = "Default Switch"
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

$vm_name_postfix = "$($vm_name)_$($postfix)"
$bare_output_path = "$($outPath)\$($vm_name)\$($vm_name)_bare_$($postfix)"
$base_output_path="$($outPath)\$($vm_name)\$($vm_name)_base_$($postfix)"
$base_opt_output_path="$($outPath)\$($vm_name)\$($vm_name)_base_opt_$($postfix)"
$baseapp_output_path = "$($outPath)\$($vm_name)\$($vm_name)_baseapp_$($postfix)"
$baseapp_opt_output_path = "$($outPath)\$($vm_name)\$($vm_name)_baseapp_opt_$($postfix)"

# Set ENV Variables for debugging
$env:PACKER_LOG = $debugging
$env:PACKER_LOG_PATH = $debugLog
Write-Log -Level "INFO" -Message "$($packerpath) build -timestamp-ui -only win_iso.hyperv-iso.vm -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($bare_output_path)`" -var `"vm_name=$($vm_name)`" -var-file $($varsfile) -var-file $($secretsfile) $($buildfile)" 
# .\bin\packer.exe build -force -var-file .\vars\Windows10\Windows10_vars.json .\Windows10.pkr.hcl
Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -timestamp-ui -only win_iso.hyperv-iso.vm -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($bare_output_path)`" -var `"vm_name=$($vm_name)`" -var-file $($varsfile) -var-file $($secretsfile) $($buildfile)" -Wait
