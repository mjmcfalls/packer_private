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
- [] Remove packer user from autounattend.xml
- [] Windows: Set Hostname
- [] Windows: Join Active Directory
- [] Windows: Update Group policy
- [x] Chrome Preferences broken (cannot find file - Search for preference file: initial_preferences)
- [x] Edge preferences fixed
- [x] One Drive: not being removed; Fix: Moved logic to Administrator from system
- [] Python2.7: Not added to path (might need to manually add to path; unattend file looks correct)
- [] VScode: redirect for extensions
- [x] Update conda navigator
- [] Windows: Start menu customization
- [] Windows: Taskbar customization
- [x] NPP silent install hangs; fix: change /s to /S
- [] BGInfo needs customization
- [x] BGInfo - Change to fill backgroup
- [] Validation: Application installs (Pester?)
- [] Validation: Image validation (Pester?)
- [] Miktex: Script to find local repo
- [] Miktex: Zip local repo, then uncompress on demand?  Might save time?
- [] Conda: Import Environments
- [] Windows: Desktop Icon cleanup; Add specific desktop icons
- [x] Java Not installing
- [x] R Studio: Disable crash reporting
- [x] R Studio: Customize user prefs (Disable update checks)
- [x] Notepad++: Disable auto-update (Rename "C:\Program Files\Notepad++\updater\")
- [] WWW - Replace Startup pages with static SRW page?
- [x] Install App Script - Revisit logic for spliting file name; inconsistent split with spaces
- [] R/R Studio Library paths
- [] Python3: installs to program files instead of c:\python39
- [] WSL: Additional images?
- [] Docker: Add users to group (group policy?)
- [] Docker: Create default settings
### Applications in Build
#### Base
- [x] 7zip
- [x] Anaconda 
- [x] Atom
- [x] BGInfo
- [x] Chrome
- [x] Edge (First Run Customization)
- [x] File Shredder
- [x] Firefox
- [x] git
- [] Java 8 Update 321 x86 (Al)
- [] Java 8 Update 321 x64
- [x] Julia 1.5.0
- [x] Notepad++
- [x] Miktex
- [x] Python 2.7
- [x] R
- [x] R Studio 
- [x] SpeedCrunch
- [x] TexStudio (Requires MikTex to be installed)
- [x] Vim 8.2
- [x] Vscode (System Install)
- [x] WinMerge
#### Base + Apps 1
- [x] MS ADK

#### Base + Apps 2
- [] WSL
- [] Docker

#### Apps to integrate
- [] EmEditor (Emurasoft)
- [] EndNote 20
- [] Mplus v8.4
- [] MySql Workbench 8.0 CE
- [] NovaBench
- [] NSIS Pirana
- [] Nvivo
- [] Phoenix (Certara)
- [] Stata 15,16,17
- [] Sudaan 11.0.3 x64
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
- [] Check install directory
- [] Check env path

#### Anaconda Checks
- [] Environments imported
- [] Environment sanity check ( ENV open and appropriate packages installed?)

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

#### SecureCRT
scrt-sfx-x64.9.1.1.2638.exe /s /v"/qn"

#### R Tools
The path in the packer variables needs to be in single quotes.


varname = {
    "name" = ""
    "installer" = ""
    "parameters" = ""
}