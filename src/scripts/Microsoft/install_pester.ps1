
[CmdletBinding()]

Param (
    [string]$app = "Pester"
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


Install-Module -Name $app -Force -SkipPublisherCheck