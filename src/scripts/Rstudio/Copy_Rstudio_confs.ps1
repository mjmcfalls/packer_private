[CmdletBinding()]

Param (
    $crashHandlerFile = "crash-handler.conf",
    $preferenceFile = "rstudio-prefs.json",
    $preferencesDestination = "C:\ProgramData\Rstudio",
    $crashHandlerDestination = "C:\Program Files\RStudio\",
    $searchPath = $env:temp,
    $rStudioSearchString = "RStudio"
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

$programDirectories = @($env:ProgramFiles, ${env:ProgramFiles(x86)})


Write-Log -Level "INFO" -Message  "Copying R Studio Config files"

Write-Log -Level "INFO" -Message "Search for $($crashHandlerFile) in $($searchPath)"
$crashHandlerPaths = Get-ChildItem -File -Path $searchPath -Recurse | Where-Object { $_.name -match $crashHandlerFile }

if ($crashHandlerPaths) {
    if ($crashHandlerDestination) {
        if (Test-Path $crashHandlerDestination) {
            Write-Log -Level "INFO" -Message "Copying $($crashHandlerPaths.FullName) to $($crashHandlerDestination)"
        }
        else {
            Write-Log -Level "INFO" -Message "Cannot Find $($crashHandlerDestination)"
        }
    }
    else {
        $dataList = New-Object System.Collections.Generic.List[System.Object]
        Write-Log -Level "INFO" -Message "No Crash Handler Destination specified."
        Write-Log -Level "INFO" -Message "Searching for R Studio Installation Directory"
        # Search x86 and x64 install locations
        
        Foreach ($progDir in $programDirectories) {
            Write-Log -Level "INFO" -Message "Searching $($progDir) for RStudio"
            $paths = Get-ChildItem -Directory -Path $progDir | Where-Object { $_.Name -Like $rStudioSearchString }
        
            foreach ($path in $paths) {
                Write-Log -Level "INFO" -Message "Add $($path.FullName) to target Destinations"
                $dataList.Add($path)
            }
        }
    
        foreach ($target in $dataList) {
            "Copy file from XXX to $($target.FullName)"
        }
    }    
}
else {
    Write-Log -Level "INFO" -Message "Cannot find $($crashHandlerFile) in $($searchPath)"
    Write-Log -Level "INFO" -Message "Exiting Copy logic for $($crashHandlerFile)"
}


Write-Log -Level "INFO" -Message "Searching for $($preferenceFile) in $($searchPath)"
$preferenceFilePaths = Get-ChildItem -File -Path $searchPath -Recurse | Where-Object { $_.name -match $crashHandlerFile }

if ($preferenceFilePaths) {
    if (!(Test-Path -Path $preferencesDestination)) {
        Write-Log -Level "INFO" -Message "Creating $($preferencesDestination)"
        New-Item -ItemType Directory -Force -Path $preferencesDestination
    }

    Write-Log -Level "INFO" -Message "Copying $($preferenceFilePaths.Fullname) to $($preferencesDestination)"
    Copy-Item -Path $preferenceFilePaths.FullName -Destination $preferencesDestination -Force
}
else {
    Write-Log -Level "INFO" -Message "Cannot find $($preferenceFile) in $($searchPath)"
    Write-Log -Level "INFO" -Message "Exiting Copy logic for $($preferenceFile)"
}

Write-Log -Level "INFO" -Message "Exiting copy script for R Studio"
