
[CmdletBinding()]
Param (
    [string]$logfile = $null,
    [string]$startmenufile,
    [string]$searchpath
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

$script_filename = $MyInvocation.MyCommand.Name

Write-Log -logfile $logfile -Level "INFO" -Message "$($script_filename) - Import Start Menu"

$xmlpath = Get-ChildItem -Recurse -Path $searchpath | Where-Object { $_.Name -like $startmenufile }

$xmlpath

