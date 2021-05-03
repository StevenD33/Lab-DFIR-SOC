Write-Host "Disabling Screensaver"
Set-ItemProperty "HKCU:\Control Panel\Desktop" -Name ScreenSaveActive -Value 0 -Type DWord
& powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
& powercfg -x -monitor-timeout-ac 0
& powercfg -x -monitor-timeout-dc 0
& powercfg -h off
