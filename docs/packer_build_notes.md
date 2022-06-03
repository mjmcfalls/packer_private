## Packer Build Notes

#### Command Line Examples
##### Multiple Variable files
packer build -force -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_qemu.pkr.hcl

##### Multiple Variable files, a secrets files, and select a single build from multiple builds
packer build -timestamp-ui -only 'qemu.Windows_10' -var-file vars/Windows10/Windows10.pkrvars.hcl -var-file secrets/secrets.pkrvars.hcl Windows10_parallel.pkr.hcl


### Applications in Build
Atom
Notepad++
Firefox
Vscode (System Install)
7zip
Chrome
WinMerge
BGInfo
Python 2.7
git
R
R Studio 
Anaconda 
MS ADK
Edge (First Run Customization)
VirtIO Drivers
SpeedCrunch (WIP)
Java 8 Update 321 x86
Java 8 Update 321 x64
Julia 1.5.0
EmEditor (Emurasoft)
EndNote 20
File Shredder
Mplus v8.4
NovaBench
NSIS Pirana
Nvivo
Phoenix (Certara)
SpeedCrunch
Stata 15,16,17
Sudaan 11.0.3 x64
Vim 8.2
VLC
X-win32 18
Wolfra Manager (Classic) 2.7
Wolfram Mathematica 10
Wolfram Extras 10
Umetrics SIMCA 16
SecureCRT 6.7
Visual Studio
SAS

### Application Specific Information


#### Speedcrunch 
Silent install: /s