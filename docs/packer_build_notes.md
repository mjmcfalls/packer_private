## Packer Build Notes

#### Command Line Examples

packer build -timestamp-ui -only 'win_base.qemu.Windows10_base' -var "keep_registered=true" -var iso_url=$bare_output_path/$vm_name -var "nix_output_directory=$base_output_path" -var "vm_name=$vm_name" 

-var "nix_output_directory=/home/libvirt/images/pool/Win10/Win10_base_test"

packer build -timestamp-ui -only 'win_base.qemu.Windows10_base' -var iso_url=/home/libvirt/images/pool/Win10/Win10_bare_20220604091933/Windows10_20220604091933 -var "vm_name=Test" -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_stages.pkr.hcl

.\build_packer.ps1 -outpath d:\temp\packer_test -buildfile Windows10_stages.pkr.hcl -secretsfile secrets\secrets.pkrvars.hcl -varsfile vars\Windows10\Windows10.pkrvars.hcl -appvarfile vars\Windows_App_Vars.pkrvars.hcl -cleanup -createvm

##### Multiple Variable files
packer build -force -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_qemu.pkr.hcl

##### Multiple Variable files, a secrets files, and select a single build from multiple builds
packer build -timestamp-ui -only 'qemu.Windows_10' -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_parallel.pkr.hcl

### To-Do
- [] Change password in Autounattend.xml
- [x] Chrome Preferences broken (cannot find file - Search for preference file: initial_preferences)
- [x] Edge preferences fixed
- [x] One Drive not being removed; Fix: Moved logic to Administrator from system
- [] Python2.7 Not added to path (might need to manually add to path; unattend file looks correct)
- [] VScode redirect for extensions
- [] Update conda navigator
- [] Start menu customization
- [] Taskbar customization
- [x] NPP silent install hangs; fix: change /s to /S
- [] BGInfo needs customization
- [] Validation: Application installs (Pester?)
- [] Validation: Image validation (Pester?)
- [] Join Active Directory
- [] Update Group policy
- [] Miktex: Script to find local repo
- [] Miktex: Zip local repo, then uncompress on demand?  Might save time?
- [] Import Conda Environments
- [] Desktop Icon cleanup; Add specific desktop icons
- [x] Java Not installing
- [x] R Studio: Disable crash reporting
- [x] R Studio: Customize user prefs (Disable update checks)
- [] Notepad++: Disable auto-update (Rename "C:\Program Files\Notepad++\updater\")
### Applications in Build
- [x] Atom
- [x] Notepad++
- [x] Firefox
- [x] Vscode (System Install)
- [x] 7zip
- [x] Chrome
- [x] WinMerge
- [x] BGInfo
- [x] Python 2.7
- [] Miktex
- [x] git
- [x] R
- [x] R Studio 
- [x] Anaconda 
- [x] TexStudio (Requires MikTex to be installed)
- [] MS ADK
- [x] Edge (First Run Customization)
- [] VirtIO Drivers (Testing)
- [] Java 8 Update 321 x86
- [] Java 8 Update 321 x64
- [] Julia 1.5.0
- [] EmEditor (Emurasoft)
- [] EndNote 20
- [x] File Shredder
- [] Mplus v8.4
- [] NovaBench
- [] NSIS Pirana
- [] Nvivo
- [] Phoenix (Certara)
- [x] SpeedCrunch
- [] Stata 15,16,17
- [] Sudaan 11.0.3 x64
- [] Vim 8.2
- [] VLC
- [] X-win32 18
- [] Wolfra Manager (Classic) 2.7
- [] Wolfram Mathematica 10
- [] Wolfram Extras 10
- [] Umetrics SIMCA 16
- [] SecureCRT 6.7
- [] Visual Studio
- [] SAS

### OS Verification
##### Path with Anaconda, Python3, Missing Python 2.7
C:\ProgramData\Anaconda3;C:\ProgramData\Anaconda3\Library\mingw-w64\bin;C:\ProgramData\Anaconda3\Library\usr\bin;C:\ProgramData\Anaconda3\Library\bin;C:\ProgramData\Anaconda3\Scripts;C:\Program Files\Python39\Scripts\;C:\Program Files\Python39\;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\Git\cmd;C:\Program Files\Microsoft VS Code\bin;C:\Users\Administrator\AppData\Local\Microsoft\WindowsApps;C:\Users\Administrator\AppData\Local\atom\bin
* Check for vscode, python, anaconda, atom
#### R checks
TBD
#### Python Checks
TBD
#### Anaconda Checks
TBD


### Application Specific Information

#### Fileshredder
/SILENT - Silent install
#### Speedcrunch 
Silent install: /S

#### Python
Installers use an unattend.xml file in the same directory as the installer

#### Miktex
Download standalone setup.
Unzip installer
Download installation files: miktexsetup_standalone --verbose --local-package-repository=C:\miktex-repository --package-set=complete download
Install: miktexsetup_standalone --verbose --local-package-repository=C:\miktex-repository --shared=yes --user-config="<APPDATA>\MiKTeX" --user-data="<LOCALAPPDATA>\MiKTeX" --user-install=<APPDATA>\MiKTeX" --print-info-only install

Update install: &"C:\Program Files\MiKTeX\miktex\bin\x64\mpm.exe" --admin --update

#### TexStudio
Need to check for C:\Program Files\texstudio for vcruntime140.dll (Seems to not get installed sometimes?)
Copy from "C:\Program Files\MiKTeX\miktex\bin\x64\vcruntime140.dll" to C:\Program Files\texstudio

#### R Studio
Disable Crash reporting: 
Create "C:\Program Files\RStudio\crash-handler.conf" -> Actually goes to %programdata%\Rstudio
Contents: crash-handling-enabled=0
Notes: Can be set under rstudio-prefs.json

Set global user preferences:
Directory: C:\ProgramData\Rstudio
File: rstudio-prefs.json
Available settings can be found at: "C:\Program Files\RStudio\resources\schema\user-prefs-schema.json"
Create and copy rstudio-prefs.json to c:\ProgramData\Rstudio

#### Julia
Uses INNO Setup
Flags: /SP /verysilent /allusers

#### VScode
System wide extensions: have to be installed into the default user account

varname = {
    "name" = ""
    "installer" = ""
    "parameters" = ""
}