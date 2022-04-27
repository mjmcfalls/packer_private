copy a:\configureremotingForAnsible.ps1 c:\Windows\Setup\Scripts\
copy a:\setlocalaccounttokenfilterpolicy.ps1 c:\Windows\Setup\Scripts\
copy a:\SetupComplete.cmd c:\Windows\Setup\Scripts\
shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"