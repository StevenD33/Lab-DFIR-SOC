Copy-Item "C:/ProgramData/chocolatey/lib/volatility/tools/volatility_2.6_win64_standalone/volatility_2.6_win64_standalone.exe" -Destination "C:/Users/analyste/Desktop"

Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Ghidra.lnk" -Destination "C:\Users\analyste\Desktop\"

$SourceFileLocation = "$env:C:\ProgramData\chocolatey\lib\network-miner\tools\NetworkMiner_2-6\NetworkMiner.exe";$ShortcutLocation = "C:\Users\analyste\Desktop\NetworkMiner.lnk";$WScriptShell = New-Object -ComObject WScript.Shell;$Shortcut = $WScriptShell.CreateShortcut($ShortcutLocation);$Shortcut.TargetPath = $SourceFileLocation;$Shortcut.Save()
