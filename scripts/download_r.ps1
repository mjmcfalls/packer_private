[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath,
    [string]$regexTarget="release.html",
    [switch]$install,
    [string]$installParams = "/veryquiet"
)

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

Write-Output "Fetch R from $($uri)"

Create-TempFolder -Path $outpath

$content = Invoke-WebRequest -Uri $uri -UseBasicParsing
$content
$r_installer_name = ((($content.ParsedHtml.GetElementsByTagName('Meta')) | Select-Object content).Content -Split "URL=")[1]
$r_installer_name
$r_download_uri = $uri.replace($regexTarget,$r_installer_name)

Invoke-WebRequest -Uri $r_download_uri -OutFile (Join-Path -Path $outpath -ChildPath $r_installer_name) -UseBasicParsing

if($install.IsPresent){
    "Start-Process -NoNewWindow -FilePath (Join-Path -Path $outpath -ChildPath $r_installer_name) -ArgumentList `"$($installParams)`""
}