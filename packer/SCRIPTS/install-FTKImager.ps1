<#
.SYNOPSIS
    This script downloads and install AccessDATA FTK Imager silently.
.DESCRIPTION

.EXAMPLE
    C:\PS> install-FTKImager.ps1
.NOTES
    Author: kidrek 
    Date:   November 2020
#>

$url = "https://ad-exe.s3.amazonaws.com/AccessData_FTK_Imager_4.5.0_%28x64%29.exe"
$downloadedFile = "C:\windows\temp\AccessData_FTK_Imager_4.5.0.exe"

iwr -Uri $url -OutFile $downloadedFile
& $downloadedFile /S /v/qn
