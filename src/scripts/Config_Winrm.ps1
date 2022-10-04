New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

Set-NetConnectionProfile -InterfaceIndex (Get-NetConnectionProfile).InterfaceIndex -NetworkCategory Private

Set-ExecutionPolicy Bypass -Force -Confirm:$false

# New-NetFirewallRule -DisplayName "Alow Outbound Port 80" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Allow