
[CmdletBinding()]
Param (
    [int]$debugging = 1,
    $postfix = (Get-Date -format yyyyMMddhhmm),
    [string]$outPath = "c:\users\mmcfall\Desktop\VMs\",
    [string]$debugLog = "$($outpath)\packerlog_$($postfix).log",
    [string]$varsfile,
    [string]$appvarFile,
    [string]$secretsfile,
    [string]$buildfile,
    [string]$packerpath = ".\bin\packer.exe",
    [string]$vm_name = "Windows10",
    [string]$keepregistered = "false",
    [string]$switch = "Default Switch",
    [string]$vmlocation,
    [switch]$createVM,
    [switch]$startVM,
    [switch]$cleanup,
    [string]$isoPath,
    [string]$isoSha,
    $memory = 1GB,
    $numOfCpus = 4
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
$bareVMName = "$($vm_name)_bare_$($postfix)"
$baseVMName = "$($vm_name)_base_$($postfix)"
$baseappVMName ="$($vm_name)_baseapp1_$($postfix)"
# Optimized VM Names
$baseOptVMName = "$($vm_name)_base_opt_$($postfix)"
$baseappOptVMName = "$($vm_name)_baseapp1_opt_$($postfix)"

# Virtual machine Output Paths
$bare_output_path = "$($outPath)\$($vm_name)\bare\$($bareVMName)"
$base_output_path = "$($outPath)\$($vm_name)\base\$($baseVMName)"
$baseapp_output_path = "$($outPath)\$($vm_name)\baseapp1\$($baseappVMName)"
# Optimized VM output paths
$base_opt_output_path = "$($outPath)\$($vm_name)\base_opt\$($baseOptVMName)"
$baseapp_opt_output_path = "$($outPath)\$($vm_name)\baseapp1_opt\$($baseappOptVMName)"

# Get Default Switch IP and Subnet
# $nicAdapter = Get-NetAdapter | Where-Object {$_.Name -like "*default*"}
# $nicConfig = Get-NetIPConfiguration -InterfaceIndex ($nicAdapter.InterfaceIndex)

# [ipaddress]$hostIPAddress = $nicConfig.IPv4Address.ipaddress
# $hostSubnetMask = [ipaddress]([math]::pow(2, 32) -1 -bxor [math]::pow(2, (32 - $nicConfig.IPv4Address.PrefixLength)-1))

# Write-Log -Level "INFO" -Message "Hyperv - Default Switch IP:$($hostIPAddress); Prefix Length:$($nicConfig.IPv4Address.PrefixLength); Subnet:$($hostSubnetMask); Index:$($nicAdapter.InterfaceIndex)"

# $vmPrefixLength = $nicConfig.IPv4Address.PrefixLength
# $vmSubnetMask = $hostSubnetMask
# [ipaddress]$vmIPAddress = $hostIPAddress.Address + (1 -shl 24)

# Write-Log -Level "INFO" -Message "VM - IP Address $($vmIPAddress); Prefix Length: $($vmPrefixLength); VM Subnet: $($vmSubnetMask); Default Gateway: $($hostIPAddress)"

# Set ENV Variables for debugging
$env:PACKER_LOG = $debugging
$env:PACKER_LOG_PATH = $debugLog

$bareVM_StopWatch = [System.Diagnostics.StopWatch]::StartNew()
Write-Log -Level "INFO" -Message "Building $($bareVMName) from $($isoPath)"
$env:PACKER_LOG_PATH = "$($outPath)\$($bareVMName).log"
Write-Log -Level "DEBUG" -Message "$($packerpath) build -timestamp-ui -only win_iso.hyperv-iso.win_iso -var `"iso_checksum=$($isoSha)`" -var `"iso_url=$($isoPath)`" -var `"switchname=$($switch)`" `"keep_registered=$($keepregistered)`" -var `"output_directory=$($bare_output_path)`" -var `"vm_name=$($bareVMName)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" 
Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -timestamp-ui -only win_iso.hyperv-iso.win_iso -var `"iso_checksum=$($isoSha)`" -var `"iso_url=$($isoPath)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($bare_output_path)`" -var `"vm_name=$($bareVMName)`" -var-file $($varsfile) -var-file $($appvarFile) -var-file $($secretsfile) $($buildfile)" -Wait
Write-Log -Level "INFO" -Message "End Build $($bareVMName) from $($isoPath)"
$bareVM_StopWatch.Stop()

$baseVM_StopWatch = [System.Diagnostics.StopWatch]::StartNew()
Write-Log -Level "INFO" -Message "Building $($baseVMName) from $($bare_output_path)"
$env:PACKER_LOG_PATH = "$($outPath)\$($base_output_path).log"
Write-Log -Level "DEBUG" -Message "$($packerpath) build -timestamp-ui -only win_base.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($bare_output_path)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($base_output_path)`" -var `"vm_name=$($baseVMName)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" 
Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -timestamp-ui -only win_base.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($bare_output_path)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($base_output_path)`" -var `"vm_name=$($baseVMName)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" -Wait
Write-Log -Level "INFO" -Message "End Build $($baseVMName) from $($bare_output_path)"
$baseVM_StopWatch.Stop()

$baseOptVMName_StopWatch = [System.Diagnostics.StopWatch]::StartNew()
Write-Log -Level "INFO" -Message "Building $($baseOptVMName) from $($baseapp_output_path)"
$env:PACKER_LOG_PATH = "$($outPath)\$($base_opt_output_path).log"
Write-Log -Level "DEBUG" -Message "$($packerpath) build -timestamp-ui -only win_base_optimize.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($base_output_path)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($base_opt_output_path)`" -var `"vm_name=$($baseOptVMName)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" 
Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -timestamp-ui -only win_base_optimize.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($base_output_path)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($base_opt_output_path)`" -var `"vm_name=$($baseOptVMName)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" -Wait
# packer build -timestamp-ui -only 'win_base_optimize.qemu.Windows_base' -var "keep_registered=false" -var "iso_checksum=sha256:$base_sha" -var iso_url=$base_output_path/$vm_name -var "nix_output_directory=$base_opt_output_path" -var "vm_name=$vm_name" -var-file vars/Windows_App_Vars.pkrvars.hcl -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages_homelab.pkr.hcl
Write-Log -Level "INFO" -Message "End Build $($baseOptVMName) from $($baseapp_output_path)"
$baseOptVMName_StopWatch.Stop()

$baseappVM_StopWatch = [System.Diagnostics.StopWatch]::StartNew()
Write-Log -Level "INFO" -Message "Building $($baseappVMName) from $($base_opt_output_path)"
$env:PACKER_LOG_PATH = "$($outPath)\$($baseapp_output_path).log"
Write-Log -Level "DEBUG" -Message "$($packerpath) build -timestamp-ui -only win_base_apps1.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($base_opt_output_path)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($baseapp_output_path)`" -var `"vm_name=$($baseappVMName)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" 
Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -timestamp-ui -only win_base_apps1.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($base_opt_output_path)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($baseapp_output_path)`" -var `"vm_name=$($baseappVMName)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" -Wait
Write-Log -Level "INFO" -Message "End Build $($baseappVMName) from $($base_opt_output_path)"
$baseappVM_StopWatch.Stop()

$baseappOptVM_StopWatch = [System.Diagnostics.StopWatch]::StartNew()
Write-Log -Level "INFO" -Message "Building $($baseappOptVMName) from $($baseapp_output_path)"
$env:PACKER_LOG_PATH = "$($outPath)\$($baseappOptVMName).log"
Write-Log -Level "DEBUG" -Message "$($packerpath) build -timestamp-ui -only win_base_optimize.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($baseapp_output_path)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($baseapp_opt_output_path)`" -var `"vm_name=$($baseappOptVMName)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" 
Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -timestamp-ui -only win_base_optimize.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($baseapp_output_path)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($baseapp_opt_output_path)`" -var `"vm_name=$($baseappOptVMName)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" -Wait
# packer build -timestamp-ui -only 'win_base_optimize.qemu.Windows_base' -var "keep_registered=false" -var "iso_checksum=sha256:$baseapp_sha" -var iso_url=$baseapp_output_path/$vm_name -var "nix_output_directory=$baseapp_opt_output_path" -var "vm_name=$vm_name" -var-file vars/Windows_App_Vars.pkrvars.hcl -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages_homelab.pkr.hcl
Write-Log -Level "INFO" -Message "End Build $($baseappOptVMName) from $($baseapp_output_path)"
$baseappOptVM_StopWatch.Stop()

if ($createVM.IsPresent) {
    Write-Log -Level "INFO" -Message "Creating VMs from VHDXs"
    # $baseVMPath = Get-ChildItem -Path $base_output_path -Recurse | Where-Object { $_.Extension -eq ".vhdx" }
    # Write-Log -Level "INFO" -Message "Base VM Path: $($baseVMPath.FullName)"

    # $baseVM = New-VM -Name "$($baseVMName)" -Generation 1 -MemoryStartupBytes $memory -SwitchName $switch -VHDPath $baseVMPath.FullName
    # Write-Log -Level "INFO" -Message "BaseVM: $($baseVM)"

    # Write-Log -Level "INFO" -Message "Base VM: Set CPU Count to 4"
    # Set-VMProcessor -VMName $baseVMName -Count $numOfCpus

    # $baseappVMPath = Get-ChildItem -Path $baseapp_output_path -Recurse | Where-Object { $_.Extension -eq ".vhdx" }
    # Write-Log -Level "INFO" -Message "Base VM Path:$($baseappVMPath.FullName)"

    # $baseappVM = New-VM -Name "$($baseappVMName)" -Generation 1 -MemoryStartupBytes $memory -SwitchName $switch -VHDPath $baseappVMPath.FullName
    # Write-Log -Level "INFO" -Message "Base App VM: $($baseappVM)"
    # Write-Log -Level "INFO" -Message "Base App VM: Set CPU Count to 4"
    # Set-VMProcessor -VMName "$($baseappVM)" -Count 4 

    # Optimize Base VM
    $baseOptVMPath = Get-ChildItem -Path $base_opt_output_path -Recurse | Where-Object { $_.Extension -eq ".vhdx" }
    Write-Log -Level "INFO" -Message "Base Optimized VM Path: $($baseOptVMPath.FullName)"

    $baseOptVM = New-VM -Name "$($baseOptVMName)" -Generation 1 -MemoryStartupBytes $memory -SwitchName $switch -VHDPath $baseOptVMPath.FullName
    Write-Log -Level "INFO" -Message "Base Optimized VM: $($baseOptVM)"

    Write-Log -Level "INFO" -Message "Base Optimized VM: Set CPU Count to $($numOfCpus)"
    Set-VMProcessor -VMName $baseOptVMName -Count $numOfCpus

    # Optimize Base+App VM
    $baseappOptVMPath = Get-ChildItem -Path $baseapp_opt_output_path -Recurse | Where-Object { $_.Extension -eq ".vhdx" }
    Write-Log -Level "INFO" -Message "Base App Optimized VM Path:$($baseappOptVMPath.FullName)"

    $baseappOptVM = New-VM -Name "$($baseappOptVMName)" -Generation 1 -MemoryStartupBytes $memory -SwitchName $switch -VHDPath $baseappOptVMPath.FullName
    Write-Log -Level "INFO" -Message "Base App Optimized VM: $($baseappOptVM)"
    Write-Log -Level "INFO" -Message "Base App Optimized VM: Set CPU Count to $($numOfCpus)"
    Set-VMProcessor -VMName "$($baseappOptVMPath)" -Count $numOfCpus
    
    if($startVM.IsPresent){
        Write-Log -Level "INFO" -Message "Start VM: $($baseappOptVMName)"
        Start-VM -Name $baseappOptVMName

        Write-Log -Level "INFO" -Message "Start VM: $($baseOptVMName)"
        Start-VM -Name $baseOptVMName
        # Write-Log -Level "INFO" -Message "Start VM: $($baseappVMName)"
        # Start-VM -Name $baseappVMName
    }
}

if ($cleanup.IsPresent) {
    Write-Log -Level "INFO" -Message "Cleaning up Intermediate builds"
}

# Stop Script Stopwatch
$scriptStopWatch.Stop()


Write-Log -Level "INFO" -Message "Bare Build Time: $($bareVM_StopWatch.Elapsed)"
Write-Log -Level "INFO" -Message "Base Build Time: $($baseVM_StopWatch.Elapsed)"
Write-Log -Level "INFO" -Message "Base Optimized Build Time: $($baseOptVMName_StopWatch.Elapsed)"
Write-Log -Level "INFO" -Message "Base App Build Time: $($baseappVM_StopWatch.Elapsed)"
Write-Log -Level "INFO" -Message "Base App Optimized Build Time: $($baseappOptVM_StopWatch.Elapsed)"
Write-Log -Level "INFO" -Message "Build Script Time: $($scriptStopWatch.Elapsed)"