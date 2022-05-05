[CmdletBinding()]
Param (
    [string]$tempDir = "c:\temp"
)


# Get files in $tempdir, then delete
$tempfiles = Get-Childitem $tempDir -Recurse -File
$tempfiles | Remove-Item -Force

# Get directories in $tempdir, then delete
$tempDirs = Get-Childitem $tempDir -Recurse -Directory
$tempDirs | Remove-Item -Force

# Get temp files in user profile, then delete
$tempfiles = Get-Childitem $env:temp -Recurse -File
$tempfiles | Remove-Item -Force

# Get temp directories in user profile, then delete
$tempDirs = Get-Childitem $env:temp -Recurse -Directory
$tempDirs | Remove-Item -Force