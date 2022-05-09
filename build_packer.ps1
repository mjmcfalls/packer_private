
[CmdletBinding()]
Param (
    [int]$debugging = 1,
    [string]$debugLog = "d:\temp\packerlog_$(Get-Date -format yyyyMMddhhmm).log",
    [string]$varsfile,
    [string]$buildfile,
    [string]$packerpath=".\bin\packer.exe"
)



# Set ENV Variables for debugging
$env:PACKER_LOG=$debugging
$env:PACKER_LOG_PATH=$debugLog

# .\bin\packer.exe build -force -var-file .\vars\Windows10\Windows10_vars.json .\Windows10.pkr.hcl
Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -force -var-file $($varsfile) $($buildfile)" -Wait