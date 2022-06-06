[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath = $env:temp
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

# enable TLS 1.2 and TLS 1.1 protocols
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Tls11

$WebResponse = Invoke-WebRequest -Uri $uri
# get the list of links, skip the first one ("../") and download the files
$WebResponse.Links | Select-Object -ExpandProperty href -Skip 1 | ForEach-Object {
    $filePath = Join-Path -Path $outpath -ChildPath $_
    $fileUrl  = '{0}/{1}' -f $uri.TrimEnd('/'), $_
    Write-Log -Level "INFO" -Message "Downloading file: $fileUrl to "
    # Invoke-WebRequest -Uri $fileUrl -OutFile $filePath
}