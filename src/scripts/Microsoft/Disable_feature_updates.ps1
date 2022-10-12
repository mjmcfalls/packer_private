
[CmdletBinding()]
Param (
    [string]$logfile = $null
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

$script_name = $MyInvocation.MyCommand.Name

Write-Log -logfile $logfile -Level "INFO" -Message "$($script_name) - Locking Windows update to current feature release"

$currentReleaseID = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).ReleaseID
Write-Log -logfile $logfile -Level "INFO" -Message "$($script_name) - Current Feature Release $($currentReleaseId)"

Write-Log -logfile $logfile -Level "INFO" -Message "$($script_name) - Setting HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\TargetReleaseVersion to 1"
$targetReleaseVersionKey = New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersion" -PropertyType DWord -Value 1 -Force

Write-Log -logfile $logfile -Level "INFO" -Message "$($script_name) - Setting HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\TargetReleaseVersionInfo to $($currentReleaseID)"
$releaseVerInfoKey = New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "TargetReleaseVersionInfo" -PropertyType String -Value "$($currentReleaseID)"

Write-Log -logfile $logfile -Level "INFO" -Message "$($script_name) - Registry Changes complete"