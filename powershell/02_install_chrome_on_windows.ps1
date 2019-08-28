# Sick of hassling with the Chrome-downloading software known as Internet Explorer?
# Run this at an admin PS control prompt
# You just got two hours of your life back. You are welcome!
$Path = $env:TEMP; $Installer = "chrome_installer.exe"; Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Path\$Installer; Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait; Remove-Item $Path\$Installer