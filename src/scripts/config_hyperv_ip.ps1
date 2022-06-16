
[CmdletBinding()]
Param (
    [string]$switchDescription = "*default*",
    $IPAddress,
    $prefixLength,
    $SubnetMask,
    $defaultGateway,
    [switch]$set,
    [switch]$remove
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

Write-Log -Level "INFO" -Message "VM IP: $($hostIP); VM Subnet: $($hostSubnetAddress); VM Prefix Length: $($hostPrefixLength)"

Write-Log -Level "INFO" -Message "Select Ethernet NIC with lowest index"
$nic = (Get-NetAdapter | Where-Object { $_.Name -Like "*Ethernet*" } | Sort-Object -Property ifIndex -Descending)[0]


if ($set.IsPresent) {
    Write-Log -Level "INFO" -Message "Selected NIC: $($nic)"

    Write-Log -Level "INFO" -Message "Setting Configuration on NIC $($nic.InterfaceIndex)"
    $nicResults = New-NetIPAddress -InterfaceIndex ($nic.InterfaceIndex) -IPAddress $IPAddress -PrefixLength $prefixLength -DefaultGateway $defaultGateway

    Write-Log -Level "INFO" -Message "Nic Results: $($nicResults)"
}

if ($remove.IsPresent) {
    Write-Log -Level "INFO" -Message "Removing Static IP from NIC $($nic.InterfaceIndex)"

    Write-Log -Level "INFO" -Message "Setting Nic $($nic.InterfaceIndex) to DHCP"
    Set-NetIPInterface  -InterfaceIndex ($nic.InterfaceIndex) -Dhcp Enabled

    Write-Log -Level "INFO" -Message "Setting Nic $($nic.InterfaceIndex) to DHCP DNS"
    Set-DnsClientServerAddress -InterfaceIndex ($nic.InterfaceIndex) -ResetServerAddresses
}