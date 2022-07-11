
[CmdletBinding()]

Param (
    [string]$app = "Pester",
    [switch]$remove
)

function New-TempFolder {
    [CmdletBinding(
        SupportsShouldProcess = $True
    )]
    param(
        [string]$Path
    )
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path
    }

}

if ($remove.IsPresent) {
    $module = "C:\Program Files\WindowsPowerShell\Modules\Pester"
    takeown /F $module /A /R
    icacls $module /reset
    icacls $module /grant "*S-1-5-32-544:F" /inheritance:d /T
    Remove-Item -Path $module -Recurse -Force -Confirm:$false
}

Install-Module -Name $app -Force -SkipPublisherCheck