
[CmdletBinding()]
Param (
    [int]$debugging = 1,
    $postfix = (Get-Date -format yyyyMMddhhmm),
    [string]$debugLog = "d:\temp\packerlog_$($postfix).log",
    [string]$varsfile,
    [string]$appvarFile,
    [string]$secretsfile,
    [string]$buildfile,
    [string]$packerpath = ".\bin\packer.exe",
    [string]$vm_name = "Windows10",
    [string]$outPath = "c:\users\mmcfall\Desktop\VMs\",
    [string]$keepregistered = "false",
    [string]$switch = "Default Switch",
    [string]$vmlocation,
    [switch]$createVM,
    [switch]$startVM,
    [switch]$cleanup,
    $memory = 1GB,
    $numOfCpus = 2
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

# Virtual machine namees
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

Write-Log -Level "INFO" -Message "Building $($vm_name_postfix) from ISO"
Write-Log -Level "DEBUG" -Message "$($packerpath) build -timestamp-ui -only win_iso.hyperv-iso.win_iso -var -var `"switchname=$($switch)`" `"keep_registered=$($keepregistered)`" -var `"output_directory=$($bare_output_path)`" -var `"vm_name=$($vm_name_postfix)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" 

Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -timestamp-ui -only win_iso.hyperv-iso.win_iso -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($bare_output_path)`" -var `"vm_name=$($vm_name_postfix)`" -var-file $($varsfile) -var-file $($appvarFile) -var-file $($secretsfile) $($buildfile)" -Wait

Write-Log -Level "INFO" -Message "Building $($vm_name_postfix) from $($bare_output_path)"

Write-Log -Level "DEBUG" -Message "$($packerpath) build -timestamp-ui -only win_base.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($bare_output_path)\Virtual Hard Disks`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($base_output_path)`" -var `"vm_name=$($vm_name_postfix)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" 

Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -timestamp-ui -only win_base.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($bare_output_path)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($base_output_path)`" -var `"vm_name=$($vm_name_postfix)`" -var `"vm_ipaddress=$($vmIPAddress)`" -var `"vm_prefixlength=$($vmPrefixLength)`" -var `"vm_subnetmask=$($vmSubnetMask)`" -var `"vm_defaultgateway=$($hostIPAddress)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" -Wait


# Write-Log -Level "INFO" -Message "Building $($baseappVMName) from $($base_output_path)"

# Write-Log -Level "DEBUG" -Message "$($packerpath) build -timestamp-ui -only win_base_apps1.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($base_output_path)\Virtual Hard Disks`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($baseapp_output_path)`" -var `"vm_name=$($vm_name_postfix)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" 

# Start-Process -NoNewWindow -FilePath "$($packerpath)" -ArgumentList "build -timestamp-ui -only win_base_apps1.hyperv-vmcx.Windows_base -var `"clone_from_vmcx_path=$($base_output_path)`" -var `"switchname=$($switch)`" -var `"keep_registered=$($keepregistered)`" -var `"output_directory=$($baseapp_output_path)`" -var `"vm_name=$($vm_name_postfix)`" -var `"vm_ipaddress=$($vmIPAddress)`" -var `"vm_prefixlength=$($vmPrefixLength)`" -var `"vm_subnetmask=$($vmSubnetMask)`" -var `"vm_defaultgateway=$($hostIPAddress)`" -var-file $($varsfile) -var-file $($appvarFile)  -var-file $($secretsfile) $($buildfile)" -Wait



if ($createVM.IsPresent) {
    Write-Log -Level "INFO" -Message "Creating VMs from VHDXs"
    $baseVMPath = Get-ChildItem -Path $base_output_path -Recurse | Where-Object { $_.Extension -eq ".vhdx" }
    Write-Log -Level "INFO" -Message "Base VM Path: $($baseVMPath.FullName)"

    $baseVM = New-VM -Name "$($baseVMName)" -Generation 1 -MemoryStartupBytes $memory -SwitchName $switch -VHDPath $baseVMPath.FullName
    Write-Log -Level "INFO" -Message "BaseVM: $($baseVM)"

    Write-Log -Level "INFO" -Message "Base VM: Set CPU Count to 4"
    Set-VMProcessor -VMName $baseVMName -Count $numOfCpus

    # $baseappVMPath = Get-ChildItem -Path $baseapp_output_path -Recurse | Where-Object { $_.Extension -eq ".vhdx" }
    # Write-Log -Level "INFO" -Message "Base VM Path:$($baseappVMPath.FullName)"

    # $baseappVM = New-VM -Name "$($baseappVMName)" -Generation 1 -MemoryStartupBytes $memory -SwitchName $switch -VHDPath $baseappVMPath.FullName
    # Write-Log -Level "INFO" -Message "Base App VM: $($baseappVM)"
    # Write-Log -Level "INFO" -Message "Base App VM: Set CPU Count to 4"
    # Set-VMProcessor -VMName "$($baseappVM)" -Count 4 

    
    if($startVM.IsPresent){
        Write-Log -Level "INFO" -Message "Start VM: $($baseVMName)"
        Start-VM -Name $baseVMName

        # Write-Log -Level "INFO" -Message "Start VM: $($baseappVMName)"
        # Start-VM -Name $baseappVMName
    }
}

if ($cleanup.IsPresent) {
    Write-Log -Level "INFO" -Message "Cleaning up Intermediate builds"
}