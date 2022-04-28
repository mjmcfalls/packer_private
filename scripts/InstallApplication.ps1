[CmdletBinding()]

Param (
    [string]$installerPath,
    [string]$installParams
)

Write-Output "Installing: $($installerPath) $($installParams)"

"Start-Process -NoNewWindow -FilePath `"$($installerPath)`" -ArgumentList `"$($installParams)`""