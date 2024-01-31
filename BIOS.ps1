# Set all settings to default (Just in case...)
$Invokation = (Get-WmiObject -Namespace root\wmi -Class Lenovo_LoadDefaultSettings).LoadDefaultSettings().Return

if ($Invokation -eq "Success") {
	Write-Host "Setting defaults was successful!" -ForegroundColor Green
}
elseif ($Invokation -ne "Success") {
	Write-Host "Setting defaults was unsuccessful!" -ForegroundColor Red
}

<#
Use the array below to specify the settings you want to change.

Available settings can be qeuried from any Lenovo device with the follwowing command:
Get-WmiObject -Namespace root\wmi -Class Lenovo_BiosSetting | Select-Object CurrentSetting

In case you don't have ThinkPad handy, you can use this:
Get-WmiObject -ComputerName [REMOTE LENOVO MACHINE] -Namespace root\wmi -Class Lenovo_BiosSetting | Select-Object CurrentSetting

The bit of code underneath the array sets each setting.

#>
@(
	'IPv4NetworkStack,Enable',
	'IPv6NetworkStack,Disable',
	'UefiPxeBootPriority,IPv4First',
	'MACAddressPassThrough,Enable',
	'StartupOptionKeys,Enable',
	'BootOrder,PXEBOOT:NVMe0',
	'NetworkBoot,PXEBOOT',
	'BIOSPasswordAtReboot,Disable'
) | ForEach-Object {
	$Invokation = (Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting).SetBiosSetting($_).Return

	if ($_ -eq 'MACAddressPassThrough,Enable' -and $Invokation -ne "Success") {
		Write-Host "Setting $_ unsucceful! Error: $Invokation" -ForegroundColor Yellow
		Write-Host "Trying different method..." -ForegroundColor Yellow
		$Invokation = (Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosSetting).SetBiosSetting('MACAddressPassThrough,Internal').Return
		if ($Invokation -eq "Success") {
			Write-Host "Setting MACAddressPassThrough,Internal successful!" -ForegroundColor Green
		}
		elseif ($Invokation -ne "Success") {
			Write-Host "Setting $_ unsucceful! Error: $Invokation" -ForegroundColor Red
		}
	}
	elseif ($Invokation -eq "Success") {
		Write-Host "Setting $_ successful!" -ForegroundColor Green
	}
	elseif ($Invokation -ne "Success") {
		Write-Host "Setting $_ unsucceful! Error: $Invokation" -ForegroundColor Red
	}
}

#	This saves all changes that were made
$Invokation = (Get-WmiObject -Namespace root\wmi -Class Lenovo_SaveBiosSettings).SaveBiosSettings().Return

if ($Invokation -eq "Success") {
	Write-Host "Saving settings was successful!" -ForegroundColor Green
}
elseif ($Invokation -ne "Success") {
	Write-Host "Saving setting was unsucceful! Error: $Invokation" -ForegroundColor Red
}

#	This sets a new BIOS password
#	WARNING! Usually you can only change a previously set password.
#	IF YOU WANT TO SET A NEW PASWORD, YOU HAVE TO ENTER WHAT'S CALLED "SYSTEM DEPLOYMENT BOOT MODE".
#	This is acomplished by entering the boot menu (F12) and then hitting the "Del" key.
#	Enter you desired BIOS password below!!!
$Invokation = (Get-WmiObject -Namespace root\wmi -Class Lenovo_SetBiosPassword).SetBiosPassword("pap,[BIOS PASSWORD],[BIOS PASSWORD],ascii,us").Return

if ($Invokation -eq "Success") {
	Write-Host "Password set!" -ForegroundColor Green
}
elseif ($Invokation -ne "Success") {
	Write-Host "Password not set! Error: $Invokation" -ForegroundColor Red
	Write-Host "Please try removing the current password and rebooting in System deployment mode" -ForegroundColor Red
}
#This removes the Windows Boot Manager from the boot order.

cmd /c "bcdedit /delete {bootmgr} /f"


#	This reads out the MAC-Address and displays it when done.
$MAC = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration).MACAddress
$MAC = $MAC -replace ':', ''
Write-Host $MAC

#	This bit of code activates "show-barcode". A script which outputs any string into a Code128-B barcode.
#	I use this to quickly get access to the MAC-address and scan it with a barcode scanner but you can use it for other onforamtion that might be important to you :)
cmd /c Start X:\powershell.lnk -Executionpolicy Unrestricted -File X:\Show-Barcode.ps1