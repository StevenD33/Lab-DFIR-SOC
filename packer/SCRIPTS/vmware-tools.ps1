#Set the current working directory to whichever drive corresponds to the mounted VMWare Tools installation ISO
Set-Location d:
#Install VMWare Tools
Start-Process "setup64.exe" -ArgumentList '/s /v "/qb REBOOT=R"' -Wait
