<#
.SYNOPSIS
Draws the Code128-B barcode for a given string

.DESCRIPTION
This Script uses System.Windows.Forms and System.Drawing to draw a barcode in a new window.

.PARAMETER String
The String you want to convert into a barcode.

.EXAMPLE
Show-Barcode -String "Hi mom!"

.NOTES
It will check for illegal characters ;)

#>
function Show-Barcode {
	param (
		[parameter(Mandatory = $true)][String]$String
	)
	#	Convert the string to an array to check for illegal characters.
	$illegal_array = $String.ToCharArray()
	#	Goes through every character in the string.
	foreach ($illegal_char in $illegal_array) {
		$decimal = [int[]][char[]]$illegal_char #	Convert character into decimal value.
		if ($decimal -ge 127) {
			#	If the decimal value of the character is 127 or more, the function will exit with the below text being written to console.
			Write-Host "Illegal character! --> $illegal_char" -ForegroundColor Red 
			exit
		}
	}
	#	Loads the neccessary dll's for creating the form.
	[reflection.assembly]::LoadWithPartialName( "System.Windows.Forms")
	[reflection.assembly]::LoadWithPartialName( "System.Drawing")
	#	Creates the pen.
	$pen = new-object Drawing.Pen Black
	$pen.Width = 2

	#	Creates the form (the window).
	$form = New-Object Windows.Forms.Form
	$form.Text = "Show-Barcode ($String)"
	$form.Width = (($String.length * 11 + 60) + $pen.width) * 2
	$form.Height = 200
	$formGraphics = $form.createGraphics()

	#	Closes the wndow when "Enter" is pressed.
	$form_KeyDown = [System.Windows.Forms.KeyEventHandler] {
		if ($_.KeyCode -eq 'Enter') {
			$form.Close()
		}
	}
	$form.Add_KeyDown($form_KeyDown)
	
	#	Initializes the show_array variable
	$show_array = @()
	
	#	All the data for the barcode generation is store in these arrays.
	#	(Little rant coming up) Why on earth did Norman J. Woodland not just use the binary encoding for each character???
	#	This entire array only exists because this guy didn't want to use binary.
	#	He acutally went through all these characters and thought to himself "Oh boy, let's NOT use binary, I will play God and decide where those one's and zero's need to be :)"
	$start_code = "000000000011010010000"
	$stop_code = "11000111010110000000000"
	$barcode_array = @{
		"checksum" = @(
			"11011001100", "11001101100", "11001100110", "10010011000", "10010001100", "10001001100", "10011001000", "10011000100", "10001100100", "11001001000",
			"11001000100", "11000100100", "10110011100", "10011011100", "10011001110", "10111001100", "10011101100", "10011100110", "11001110010", "11001011100",
			"11001001110", "11011100100", "11001110100", "11101101110", "11101001100", "11100101100", "11100100110", "11101100100", "11100110100", "11100110010",
			"11011011000", "11011000110", "11000110110", "10100011000", "10001011000", "10001000110", "10110001000", "10001101000", "10001100010", "11010001000",
			"11000101000", "11000100010", "10110111000", "10110001110", "10001101110", "10111011000", "10111000110", "10001110110", "11101110110", "11010001110",
			"11000101110", "11011101000", "11011100010", "11011101110", "11101011000", "11101000110", "11100010110", "11101101000", "11101100010", "11100011010",
			"11101111010", "11001000010", "11110001010", "10100110000", "10100001100", "10010110000", "10010000110", "10000101100", "10000100110", "10110010000",
			"10110000100", "10011010000", "10011000010", "10000110100", "10000110010", "11000010010", "11001010000", "11110111010", "11000010100", "10001111010",
			"10100111100", "10010111100", "10010011110", "10111100100", "10011110100", "10011110010", "11110100100", "11110010100", "11110010010", "11011011110",
			"11011110110", "11110110110", "10101111000", "10100011110", "10001011110", "10111101000", "10111100010", "11110101000", "11110100010", "10111011110",
			"10111101110", "11101011110", "11110101110", "11010000100", "11010010000", "11010011100", "11000111010"
		)
		"data"     = @{
			"20" = @("11011001100", "0"); "21" = @("11001101100", "1"); "22" = @("11001100110", "2"); "23" = @("10010011000", "3"); "24" = @("10010001100", "4"); "25" = @("10001001100", "5"); "26" = @("10011001000", "6"); "27" = @("10011000100", "7"); "28" = @("10001100100", "8"); "29" = @("11001001000", "9"); "2A" = @("11001000100", "10"); "2B" = @("11000100100", "11"); "2C" = @("10110011100", "12"); "2D" = @("10011011100", "13"); "2E" = @("10011001110", "14"); "2F" = @("10111001100", "15");
			"30" = @("10011101100", "16"); "31" = @("10011100110", "17"); "32" = @("11001110010", "18"); "33" = @("11001011100", "19"); "34" = @("11001001110", "20"); "35" = @("11011100100", "21"); "36" = @("11001110100", "22"); "37" = @("11101101110", "23"); "38" = @("11101001100", "24"); "39" = @("11100101100", "25"); "3A" = @("11100100110", "26"); "3B" = @("11101100100", "27"); "3C" = @("11100110100", "28"); "3D" = @("11100110010", "29"); "3E" = @("11011011000", "30"); "3F" = @("11011000110", "31");
			"40" = @("11000110110", "32"); "41" = @("10100011000", "33"); "42" = @("10001011000", "34"); "43" = @("10001000110", "35"); "44" = @("10110001000", "36"); "45" = @("10001101000", "37"); "46" = @("10001100010", "38"); "47" = @("11010001000", "39"); "48" = @("11000101000", "40"); "49" = @("11000100010", "41"); "4A" = @("10110111000", "42"); "4B" = @("10110001110", "43"); "4C" = @("10001101110", "44"); "4D" = @("10111011000", "45"); "4E" = @("10111000110", "46"); "4F" = @("10001110110", "47");
			"50" = @("11101110110", "48"); "51" = @("11010001110", "49"); "52" = @("11000101110", "50"); "53" = @("11011101000", "51"); "54" = @("11011100010", "52"); "55" = @("11011101110", "53"); "56" = @("11101011000", "54"); "57" = @("11101000110", "55"); "58" = @("11100010110", "56"); "59" = @("11101101000", "57"); "5A" = @("11101100010", "58"); "5B" = @("11100011010", "59"); "5C" = @("11101111010", "60"); "5D" = @("11001000010", "61"); "5E" = @("11110001010", "62"); "5F" = @("10100110000", "63");
			"60" = @("10100001100", "64"); "61" = @("10010110000", "65"); "62" = @("10010000110", "66"); "63" = @("10000101100", "67"); "64" = @("10000100110", "68"); "65" = @("10110010000", "69"); "66" = @("10110000100", "70"); "67" = @("10011010000", "71"); "68" = @("10011000010", "72"); "69" = @("10000110100", "73"); "6A" = @("10000110010", "74"); "6B" = @("11000010010", "75"); "6C" = @("11001010000", "76"); "6D" = @("11110111010", "77"); "6E" = @("11000010100", "78"); "6F" = @("10001111010", "79");
			"70" = @("10100111100", "80"); "71" = @("10010111100", "81"); "72" = @("10010011110", "82"); "73" = @("10111100100", "83"); "74" = @("10011110100", "84"); "75" = @("10011110010", "85"); "76" = @("11110100100", "86"); "77" = @("11110010100", "87"); "78" = @("11110010010", "88"); "79" = @("11011011110", "89"); "7A" = @("11011110110", "90"); "7B" = @("11110110110", "91"); "7C" = @("10101111000", "92"); "7D" = @("10100011110", "93"); "7E" = @("10001011110", "94");
		}
	}
	
	#	Converts the String into a char array and initialitzes the variables for checksum calculation.
	$char_array = $String.ToCharArray()
	$sum = 0
	$counter = 1
	#	This calculates the checksum.
	#	It goes through each character. Then it multiplies each character by it's position, and adds that to the sum.
	foreach ($char in $char_array) {
		$char = [System.String]::Format("{0:X2}", [System.Convert]::ToUInt32($char))
		$sum = $sum + ($counter * $barcode_array.data."$char"[1])
		$counter++
	}
	#	In the end , 104 is added to the sum and you apply(?) modulo 103 to it. The rest of thi modulo operation is your checksum.
	$sum = $sum + 104
	$checksum = $sum % 103
	#	Now every character is converted to hexadecimal, and the binary data from the barcode_array is added to data_array.
	foreach ($char in $char_array) {
		$char = [System.String]::Format("{0:X2}", [System.Convert]::ToUInt32($char))
		$data_array += $barcode_array.data."$char"[0]
	}
	
	#	The show_array combines all data (so start code, data, checksum, and stop code).
	$show_array += $start_code
	$show_array += $data_array
	$show_array += $barcode_array.checksum[($checksum)]
	$show_array += $stop_code
	$show_array = $show_array.ToCharArray() #	The show_array is then converted into a character array (so that each bit can be drawn seperately).
	
	#	$form.add_paint is used to acutally paint everything.
	$form.add_paint({
			#	Goes through every bit in the show_array.
			foreach ($entry in $show_array) {
				if ($entry -eq "1") {
					#	If the bit is equal to 1, the bit needs to be drawn in black.
					$X_coord = $X_coord + $pen.Width #	Advances the pen's x coordinate by the pen's width.
					$pen.Color = "Black" #	Set's the color to black.
					$formGraphics.DrawLine($pen, $X_coord, 0, $X_coord, 190) #	Draws a line on the y axis (190 just seems like an appropriate amount of pixels).
				}
				elseif ($entry -eq "0") {
					#	If the bit is equal to 0, the bit needs to be drawn in white.
					$X_coord = $X_coord + $pen.Width #	Advances the pen's x coordinate by the pen's width.
					$pen.Color = "White" #	Set's the color to white.
					$formGraphics.DrawLine($pen, $X_coord, 0, $X_coord, 190) #	Draws a line on the y axis.
				}	
			}
		})
	$form.ShowDialog()
}

$MAC = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration).MACAddress
$MAC = [string]$MAC -replace ':',''

Show-Barcode -String $MAC

Pause

Stop-Computer