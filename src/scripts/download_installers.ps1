[CmdletBinding()]

Param (
    [string]$uri,
    [string]$outpath = $env:temp,
    [string]$wgetPath = "a:\wget.exe",
    [switch]$wget,
    [switch]$network,
    [string]$netpath,
    [string]$pass,
    [string]$user
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

if ($wget.IsPresent) {
    Write-Log -Level "INFO" -Message "Wget path: $($wgetPath)"
    Write-Log -Level "INFO" -Message "URI: $($uri)"
    Write-Log -Level "INFO" -Message "Output Directory: $($outpath)"

    $serverAddress = ($uri -Split ":")[1].trim("/")


    Write-Log -Level "INFO" -Message "ServerAddress: $($serverAddress)"

    Start-Process -NoNewWindow -PassThru -Wait -FilePath $wgetPath -ArgumentList "-r --no-parent --verbose --no-clobber $($uri) -P $($outpath)"

    Write-Log -Level "INFO" -Message "Move downloads out of subfolder"
    $dirExists = Get-ChildItem -Directory -Path $outpath | Where-Object { $_.Name -Like "$($serverAddress)*" }

    if ($dirExists) {
        $topLevelDirs = Get-ChildItem -Path $dirExists.FullName 
    
        foreach ($dir in $topLevelDirs) {
            Move-Item -Path $dir.FullName -Destination $outpath -Force
        }

        Remove-Item -Path $dirExists.FullName -Force -Recurse
    }
}


if ($network.IsPresent) {
    $password = ConvertTo-SecureString "$($pass)" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("$($user)", $password)
    New-PSDrive -Name "$($outpath)" -Root "$($netpath)" -PSProvider "FileSystem" -Credential $cred
    Net Use
}