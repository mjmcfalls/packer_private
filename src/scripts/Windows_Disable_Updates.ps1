
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


# 
# Global Registry Changes
# 
Write-Log -logfile $logfile -Level "INFO" -Message "$($app) - Disabling Windows Update"

New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name "WindowsUpdate" -Force

New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name "AU" -Force

New-ItemProperty -Force -ErrorAction stop -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name "NoAutoUpdate" -PropertyType "DWORD" -Value 1
New-ItemProperty -Force -ErrorAction stop -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name "AUOptions" -PropertyType "DWORD" -Value 1
