[CmdletBinding()]

Param (
    [string]$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",
    [string]$registryKey = "LocalAccountTokenFilterPolicy",
    $targetValue = 1
)

Set-ItemProperty -Path $registryPath -Name $registryKey -Value $targetValue
