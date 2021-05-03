Function Set-WallPaper($Value)
{
 Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value "$value"
 rundll32.exe user32.dll, UpdatePerUserSystemParameters
}
    
Set-WallPaper -Value "C:\Users\analyste\Pictures\dfirbg.png"
