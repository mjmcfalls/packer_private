
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
$targetRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$targetRegKey = "EnableLUA"
$targetValue = 0
Write-Log -logfile $logfile -Level "INFO" -Message "$($script_name) - Disabling User Account Control"
Write-Log -logfile $logfile -Level "INFO" -Message "$($script_name) - Setting $($targetRegPath)\$($targetRegKey) to $($targetValue) "

Set-ItemProperty -Path $targetRegPath -Name $targetRegKey -Value $targetValue

Write-Log -logfile $logfile -Level "INFO" -Message "$($script_name) - Script complete"