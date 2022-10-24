
[CmdletBinding()]
Param (
    [int]$debugging = 1,
    $postfix = (Get-Date -format yyyyMMddhhmm),
    [string]$outPath = "c:\temp\",
    [string]$configFile = ".\packer_vcl_build_vars.json",
    $targetOS,
    [switch]$vmtimestamp,
    [string]$logfile
    # [string]$debugLog = "$($outpath)\packerlog_$($postfix).log",
    # [string]$varsfile = ".\vars\Windows_VCL\Windows_vcl.pkrvars.hcl",
    # [string]$appvarFile = "vars\Windows_VCL\Windows_VCL_App_Vars.pkrvars.hcl",
    # [string]$secretsfile = ".\secrets\secrets.pkrvars.hcl",
    # [string]$buildfile = ".\vcl.pkr.hcl",
    # [string]$packerpath = ".\bin\packer.exe",
    # [string]$vm_name = "Windows10",
    # [string]$keepregistered = "false",
    # [string]$isoPath,
    # [string]$isoSha,
    # [string]$unattendPath = "C:\Users\mmcfall\Desktop\dev\UnattendFiles\Windows10_ltsb\autounattend.xml",
    # [string]$buildTarget = "windows10.vmware-iso.win_iso"
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
        Write-Host $Line
    }
}

Function Start-PackerBuild {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)][string]$logfile,
        $build,
        $vmtimestamp
    )

    $vm_build_stopWatch = [System.Diagnostics.StopWatch]::StartNew()
    $packerVars = New-Object System.Collections.Generic.List[String]
    $packerVarfiles = New-Object System.Collections.Generic.List[String]

    Write-Log -Level "INFO" -Message "$($build.vm_name) - Start of Packer Build" -logfile $logfile

    if($vmtimestamp.IsPresent){
        Write-Log -Level "INFO" -Message "$($build.vm_name) - Appending Timestamp to VM Name; Current VM Name: $($build.vars.vm_name)" -logfile $logfile
        $build.vars.vm_name = "$($build.vars.vm_name)_$(Get-Date -Format yyyyMMddhhmm)"
        Write-Log -Level "INFO" -Message "$($build.vm_name) - New VM Name: $($build.vars.vm_name)" -logfile $logfile
    }


    Write-Log -Level "INFO" -Message "*** $($build.vars.vm_name) - *** Build Parameters ***" -logfile $logfile
    
    Write-Log -Level "INFO" -Message "$($build.vars.vm_name) - Build Parameters - vars:" -logfile $logfile
    Foreach($item in $build.vars.PSObject.Properties){
        Write-Log -Level "INFO" -Message "$($build.vars.vm_name) - $($item.Name): $($item.value)"
        # -var `"win_startmenu_xml=$($build.win_startmenu_xml)`"
        $tempvarstr = "-var `"$($item.Name)=$($item.value)`""
        $packerVars.Add($tempvarstr)
    }
    
    Write-Log -Level "INFO" -Message "$($build.vars.vm_name) - Build Parameters - varfiles:" -logfile $logfile
    Foreach($item in $build.varfiles){
        Write-Log -Level "INFO" -Message "$($build.vars.vm_name) - $($item)"
        # -var-file $($build.secretsfile) $($build.buildfile)"
        $tempvarstr = "-var-file $($item)"
        $packerVarfiles.add($tempvarstr)
    }

    Write-Log -Level "INFO" -Message "$($build.vars.vm_name) - *** END Build Parameters ***" -logfile $logfile

    if ($build.debug -like "1") {
        $env:PACKER_LOG = ([int]$build.debug)
        $env:PACKER_LOG_PATH = Join-path -Path $outPath -ChildPath "$($build.vars.vm_name).log"
        # $build
        Write-Log -Level "INFO" -Message "$($build.vars.vm_name) - Debugging log enabled" -logfile $logfile
        Write-Log -Level "INFO" -Message "$($build.vars.vm_name) - Logging to $($env:PACKER_LOG_PATH)" -logfile $logfile
    }
    else {
        Write-Log -Level "INFO" -Message "$($build.vars.vm_name) - Debugging log disabled" -logfile $logfile
    }


    Write-Log -Level "INFO" -Message "$($build.vm_name) - Building from $($build.vars.isoPath)" -logfile $logfile

    Write-Log -Level "INFO" -Message "$($build.packerpath) build -timestamp-ui -only $($build.buildTarget) $($packerVars -join ' ') $($packerVarfiles -join ' ') $($build.buildfile)" -logfile $logfile

    # Start-Process -NoNewWindow -FilePath "$($build.packerpath)" -ArgumentList "build -timestamp-ui -only $($build.buildTarget) $($packerVars -join ' ') $($packerVarfiles -join ' ') $($build.buildfile)" -Wait

    Write-Log -Level "INFO" -Message "$($build.vars.vm_name) - End Packer build" -logfile $logfile

    $vm_build_stopWatch.Stop()
    $build.stopwatch = $vm_build_stopWatch
    
    Write-Log -Level "INFO" -Message "$($build.vars.vm_name) - Build Time: $($vm_build_stopWatch.Elapsed)" -logfile $logfile

    $build
}

# Start Script Stop watch
$scriptStopWatch = [System.Diagnostics.StopWatch]::StartNew()

if (Test-Path $configFile) {
    Try {
        $buildVariables = Get-Content -Raw -Path $configFile | ConvertFrom-Json
    }
    catch {
        Write-Log -Level "INFO" -Message "Error reaching $($configFile)"
        Exit 1
    }
}
else {
    Write-Log -Level "INFO" -Message "Exitings - $($configFile) not found"
    Exit 1
}


Foreach ($os in $targetOS) {
    # $buildVariables.Windows10
    Write-Log -Level "INFO" -Message "$($os) - ===== Start build =====" -logfile $logfile
    if ($buildVariables.$os) {
        Write-Log -Level "INFO" -Message "$($os) - Found in build variables" -logfile $logfile
        $buildVariables.$os = Start-PackerBuild -build $buildVariables.$os -vmtimestamp $vmtimestamp
    }
    else {
        Write-Log -Level "INFO" -Message "$($os) - Not Found in build variables" -logfile $logfile
    }
    Write-Log -Level "INFO" -Message "$($os) - ===== End Build =====" -logfile $logfile
}

$scriptStopWatch.Stop()

Write-Log -Level "INFO" -Message "Build Script Time: $($scriptStopWatch.Elapsed)" -logfile $logfile
