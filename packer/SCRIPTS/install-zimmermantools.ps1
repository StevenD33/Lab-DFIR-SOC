<#
.SYNOPSIS
    This script downloads and install all ZimmermanTools suite silently.
.DESCRIPTION

.EXAMPLE
    C:\PS> install-zimmermantools.ps1
.NOTES
    Author: kiki (thx to Eric Zimmerman for their awesome tools)
    Date:   August 2020
#>


$url = "https://raw.githubusercontent.com/EricZimmerman/Get-ZimmermanTools/master/Get-ZimmermanTools.ps1"
$localfile = "C:\ProgramData\chocolatey\bin\Get-ZimmermanTools.ps1"

Invoke-WebRequest -Uri $url -OutFile $localfile
powershell -ep bypass $localfile -Dest C:\ProgramData\chocolatey\bin\
