$username = @()
$path = @()
# Checking to see if users is in users.csv
do {
    Import-Csv "your path\scripts\users.csv" |`
    ForEach-Object {
        $username += $_.username
        $path += $_.path
    }

    if ($username -contains $env:username){

        Do{
            $q = Read-Host '1 For Backup 2 for Restore'
                # If user enters 1 starts additional backup
                if ($q -eq 1){
                    # Checks to see if path exsists if not then it creates Directory
                    if ((Test-Path $path\$env:computername) -eq $False){
                        New-Item -ItemType directory -Path $path\$env:computername
                    } Else {
                    }
                    # Starts USMT
    		        Invoke-Item "USMT PATH"
                    Write-Host 'Welcome to the additional backup process, This process will backup all printers and selected users'
                    Write-Host 'This IS NOT to replace the USMT process'

                    # Copy's Public Desktop then sets attribute to show without having to view hidden folder
    		        Invoke-Item C:\Users\
    		        robocopy C:\Users\Public\Desktop\ $path\$env:computername\Public\Desktop\ /xf "Excel *.lnk" "Outlook 2016.lnk" "PowerPoint 2016.lnk" "Skype for Business.lnk" "Skype for Business 2016.lnk" "Web Login.lnk" "Word 2016.lnk" "Web Login.lnk" "UF Health Applications.lnk" /s /nfl /ndl /njh /np /ns /nc /np /ns /nc /R:10 /W:5
    		        attrib -s -h $path\$env:computername\Public\* /s /d

                    # Creates an additional backup from USMT until user enters 0
                    Do {
                       Write-Host 'if you would like to exit this enter 0'
                       $u = Read-Host 'What is the username that backup'
                       if (Test-Path C:\Users\$u){
		                    robocopy C:\Users\$u\ $path\$env:computername\$u\  /xj /xf NTUSER.dat NTUSER.dat.* desktop.ini /xd C:\Users\$u\Appdata C:\Users\$u\Onedrive C:\Users\$u\Dropbox C:\Users\$u\Searches "C:\Users\$u\Saved Games" C:\Users\$u\Contacts C:\Users\$u\Music C:\Users\$u\Links /s /nfl /ndl /njh /np /ns /nc /np /ns /nc /R:10 /W:5
			                if ((Test-Path "C:\Users\$u\Appdata\Roaming\Microsoft\Sticky Notes") -eq $True){
				                robocopy "C:\Users\$u\Appdata\Roaming\Microsoft\Sticky Notes" $path\$env:computername\$u\Stickynotes\  /xj /xf NTUSER.dat NTUSER.dat.* desktop.ini /xd /s /nfl /ndl /njh /np /ns /nc /np /ns /nc /R:10 /W:5
			                }Else{
			                }
                       } Else {
                           Write-Host 'You have inserted an invalid User'
                        }
                    } until ($u -eq 0)

                    # Gathers Printers into Printers.printerExport
                    Write-Host 'Gathering Printers'
                    & $env:WINDIR\System32\spool\tools\printbrm -b -f $env:UserProfile\Desktop\printers.printerExport
                    Move-Item $env:UserProfile\Desktop\printers.printerExport $path\$env:computername\printers.printerExport
                    cscript $env:windir\System32\printing_Admin_Scripts\en-US\prnmngr.vbs -l > $path\$env:computername\Printers.txt
                      
                    Write-Host 'Gathering Service Tag'
                    # Gathers Serial Number, Prints it to ServiceTag_old and sets it to a veriable
                    $st = gwmi win32_bios | select -Expand serialnumber
                    $st
                    $st > $path\$env:computername\ServiceTag_Old.txt

                    # Gathers Applications with exceptions
		            Write-Host 'Getting Installed Applications'
                    Get-WmiObject -Class Win32_Product | select Name | ? {$_.Name -notmatch "Citrix|Zoom|Java|Silverlight|Secure Mail|Configuration|Software|Microsoft Policy|Microsoft Visual|Update|Microsoft .Net|Symantec|Online Plug-in|MBAM|Local Administrator|Adobe Acrobat|Visage|FormFast|Phish|PolicyPak|64 Bit|32 Bit|Herra|Outils|Realtek|Microsoft Office| Microsoft Identity|Microsoft DCF"} > $path\$env:computername\Applications.txt
                
                    # Asks user for asset tag, writes it in Asset_Old.txt and sets it as a Veriable     
                    $at = Read-Host 'What is the Asset Tag'
                    $at > $path\$env:computername\AssetTag_Old.txt
		        
                    # Gathers and prints it to PCModel_Old and marks it as a veriable
		            $PCM = gwmi win32_Computersystemproduct | select -Expand Name
                    $PCM
		            $PCM > $path\$env:computername\PCModel_Old.txt

                    # Writes Veriables to Computers.csv
	    	        $csv = @(
	                    "$PCM,$st,$at,$env:computername"
	    	        )
	     	        $csv | foreach { Add-Content -Path "$path\Computer List.csv" -Value $_ }
                
                    # Closes the session        
                    write-host 'Thank You for using the additional backup tool'
                    write-host "Press any key to Exit..."
                    [void][System.Console]::ReadKey($true)
                    stop-process -Id $PID
                } elseif ($q -eq 2){
                    Invoke-Item "USMT PATH"
                    if ((Test-Path $path\$env:computername\printers.printerExport) -eq $True){
    	                Write-Host 'Restoring Printers'
    	                & $env:WINDIR\System32\spool\tools\printbrm -R -F $path\$env:computername\printers.printerExport
	                    & printmanagement.msc
    		            Invoke-Item $path\$env:computername\printers.txt
                    } Else {
    	                Write-Host "No Printers to restore"
                    }
                    if ((Test-Path $path\$env:computername) -eq $False){
                        New-Item -ItemType directory -Path $path\$env:computername
                    } Else {
                    }
            
                    Write-Host 'Gathering Service Tag'
                    $st = gwmi win32_bios | select -Expand serialnumber
                    $st
                    $st > $path\$env:computername\ServiceTag_New.txt
                      
                    $at = Read-Host 'What is the Asset Tag'
                    $at > $path\$env:computername\AssetTag_New.txt
                
                    $PCM = gwmi win32_Computersystemproduct | select -Expand Name
                    $PCM
                    $PCM > $path\$env:computername\PCModel_New.txt
                       
                    write-host 'RUN NEXT STEP AFTER USMT RESTORE'
                    write-host "Press any key to Continue..."
                    [void][System.Console]::ReadKey($true)

                    Write-Host 'Removing All Hyperspace Shortcuts'
                    Get-ChildItem -path C:\Users\ -Exclude C:\Users\$env:username\ -Recurse -Filter "*- Hyperspace.lnk" | Remove-Item

                    $csv = @(
                        "$PCM,$st,$at,$env:computername"
                    )
                    $csv | foreach { Add-Content -Path "$path\Computer List.csv" -Value $_ }

                    write-host "Process finished Press any key to close..."
                    [void][System.Console]::ReadKey($true)       
                    stop-process -Id $PID
                } else {
                    Write-Host 'Incorrect Syntax'
                }
        } While ($true)
    } else {
        $np = Read-Host "Path Does Not exsist please enter a path you would like to enter"
        $nu = $env:username

        $nf = @(
            "$nu,$np"
        )
        $nf | foreach { Add-Content -Path "your path\scripts\users.csv" -Value $_}
    }
} While ($true)