# anaconda_install_type = "/InstallationType=AllUsers"
# anaconda_install_addpath = "/AddToPath=1"
# anaconda_install_registerpy = "/RegisterPython=1"
# anaconda_install_silent = "/S"
# anaconda_install_dir = "C:\\programdata\\Anaconda3"
# anaconda_installer = "Anaconda3-2021.11-Windows-x86_64.exe"
# seven_zip_installer = "7z2107-x64.exe"
# chrome_installer = "GoogleChromeEnterpriseBundle64.zip"
# anyconnect_installer = "anyconnect-win-4.10.05095.zip"
# r_tools_40_installer = "rtools40-x86_64.exe"
# r_tools_40_installParams = "/VERYSILENT /DIR='C:\\rtools40'"
# vscode_installer = "VSCodeSetup-x64-1.67.0.exe"
# git_installer = "Git-2.36.1-32-bit.exe"
# ms_adk_installer = "adksetup.exe"
# sdelete_uri = "https://download.sysinternals.com/files/SDelete.zip"
# virtio_isoname = "virtio-win-0.1.217.iso"
wget_path = "c:\\Program Files\\wget"
audit_json_path = "c:\\ProgramData\\Packer"
audit_json_file = "audit.json"

os_optimize = {
    "defaultsUserSettingsPath" = "a:\\DefaultUserSettings.txt" 
    "ScheduledTasksListPath" = "a:\\ScheduledTasks.txt"
    "automaticTracingFilePath" = "a:\\AutomaticTracers.txt"
    "servicesToDisablePath" = "a:\\ServicesToDisable.txt"
}

vcl = {
    "src_path" = "c:\\temp\\scripts\\VCL\\UserScripts"
    "script_path" = "C:\\Scripts"
}

cygwin = {
    "root" = "C:\\cygwin"
}

winscp = {
    "name" = "WinSCP-5.21.3"
    "installer" = "WinSCP-5.21.3-Setup.exe"
    "parameters" = "/S"
}

r_studio = {
    "name" = "RStudio-2022.02.1-461"
    "installer" = "RStudio-2022.02.1-461.exe"
    "parameters" = "/S"
}

r = {
    "name"="R-4.1.3"
    "installer"="R-4.1.3-win.exe"
    "parameters"="/verysilent /NORESTART /MERGETASKS=!desktopicon"
}

seven_zip = {
    "name" = "7zip"
    "installer" = "7z2201-x64.exe"
    "parameters" = "/S"
}

chrome = {
    "name" = "Chrome"
    "installer" = "GoogleChromeStandaloneEnterprise64.msi"
    "parameters" = "/quiet /norestart"
}

git = {
    "name" = "Git"
    "installer" = "Git-2.36.1-64-bit.exe"
    "parameters" = "/VERYSILENT /NORESTART"
}

git_lfs = {
    "name" = "Git LFS"
    "installer" = "git-lfs-windows-v3.2.0.exe"
    "parameters" = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
}

vscode = {
    "name" = "VSCode"
    "installer" = "VSCodeSetup-x64-1.67.0.exe"
    "parameters" = "/VERYSILENT /loadinf=vscode.inf /MERGETASKS=!runcode"
}

python_27 = {
    "name" = "Python2.7"
    "installer" = "python-2.7.18.amd64.msi"
    "parameters" = "/quiet"
}

python_39 = {
    "name" = "Python 3.9.13"
    "installer" = "python-3.9.13-amd64.exe"
    "parameters" = "/quiet unattend.xml"
}

conda = {
    "name" = "Anaconda3 2021.11"
    "installer" = "Anaconda3-2021.11-Windows-x86_64.exe"
    "parameters" = "/S /RegisterPython=1 /AddToPath=1 /InstallationType=AllUsers"
}

firefox = {
    "name" = "Firefox"
    "installer" = "Firefox Setup 105.0.2.exe"
    "parameters" = ""
}

atom = {
    "name" = "Atom"
    "installer" = "AtomSetup-x64.exe"
    "parameters" = "-s"
}

npp = {
    "name" = "Notepad++"
    "installer" = "npp.8.4.1.Installer.x64.exe"
    "parameters" = "/S"
}

winmerge = {
    "name" = "WinMerge"
    "installer" = "WinMerge-2.16.20-x64-Setup.exe"
    "parameters" = "/VERYSILENT /NORESTART /MERGETASKS=!desktopicon"
}

miktex = {
    "name" = "MikTex"
    "installer" = "miktexsetup_standalone.exe"
    "parameters" = "--verbose --local-package-repository=C:\\temp\\apps\\miktex\\repo --shared=yes install"
}

texstudio = {
    "name" = "TexStudio"
    "installer" = "texstudio-4.2.3-win-qt6.exe"
    "parameters" = "/S"
}

fileshredder = {
    "name" = "FileShredder"
    "installer" = "file_shredder_setup.exe"
    "parameters" = "/SILENT"
}

speedcrunch = {
    "name" = "SpeedCrunch"
    "installer" = "SpeedCrunch-0.12-win32.exe"
    "parameters" = "/S"
}

java_x86 = {
    "name" = "Java 8 R333 x86"
    "installer" = "jre-8u333-windows-i586.exe"
    "parameters" = "INSTALLCFG=c:\\temp\\apps\\java\\java_install.cfg"
}

java_x64 = {
    "name" = "Java 8 R333 x64"
    "installer" = "jre-8u333-windows-x64.exe"
    "parameters" = "INSTALLCFG=c:\\temp\\apps\\java\\java_install.cfg"
}

julia = {
    "name" = "Julia 1.7.3 x86"
    "installer" = "julia-1.7.3-win32.exe"
    "parameters" = "/SP /verysilent /allusers"
}

vim = {
    "name" = "VIM 9.0.0001"
    "installer" = "gvim_9.0.0001_x64.exe"
    "parameters" = "/S"
}

r_tools_40 = {
    "name" = "R Tools 4.0 x64"
    "installer" = "rtools40-x86_64.exe"
    "parameters" = "/VERYSILENT /DIR=C:\\rtools40"
    "path" = "C:\\rtools40"
}

docker = {
    "name" = "Docker Desktop"
    "installer" = "Docker Desktop Installer.exe"
    "parameters" = "install --quiet --accept-license --backend=wsl-2"
}
