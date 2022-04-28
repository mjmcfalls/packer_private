[CmdletBinding()]

Param (
    [string]$installerPath,
    [string]$installParams
)

Write-Output "Installing: $($installerPath) $($installParams)"

function Create-TempFolder{
    [CmdletBinding(
        SupportsShouldProcess = $True
    )]
    param(
        [string]$Path
    )
    if(-not (Test-Path $Path)){
        New-Item -ItemType Directory -Path $Path
    }

}

Create-TempFolder -Path $outpath

"Start-Process -NoNewWindow -FilePath `"$($installerPath)`" -ArgumentList `"$($installParams)`""