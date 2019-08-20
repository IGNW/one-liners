gwmi Win32_OperatingSystem | select InstallDate
gwmi Win32_Product | where {$_.name -like "*java*"} | select name
(gwmi Win32_Product | where {$_.name -like "*toolbar*"}).uninstall()
gwmi win32_computersystem | select model
gwmi win32_baseboard | select product
gwmi win32_bios | select serialnumber
gwmi win32_bios | select SMBIOSBIOSVersion
gwmi win32_printer | select Name, Portname, Default

