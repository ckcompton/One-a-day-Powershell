
Start-Sleep -Seconds 1

Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -Value 0

If (Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -ExpandProperty MacAddress) {

    #This will store the MAC of the connection closest to the bottom. Assuming that is what is plugged in, it needs to be plugged in.
    $upmac = Get-NetAdapter | Where-Object Status -eq "Up" | Select-Object -ExpandProperty MacAddress

    #Converts the MAC to decimal for arithmetic operations
    $upmacindecimal = [UInt64] "0x$($upmac -replace '-')"

    #debug
    #Write-Output $upmacindecimal
    #Checks for a valid MAC address in Get-NetAdapter for  upmac+1 TRUE


    #Converts the decimal MAC back to HEX in string format
    $higherMACinHex = "{0:X}" -f ($upmacindecimal + 1)
    $higherMACinHex = $higherMACinHex.Insert(2, '-')
    $higherMACinHex = $higherMACinHex.Insert(5, '-')
    $higherMACinHex = $higherMACinHex.Insert(8, '-')
    $higherMACinHex = $higherMACinHex.Insert(11, '-')
    $higherMACinHex = $higherMACinHex.Insert(14, '-')
     

    #upmac plus 1 found
    if ( (Get-NetAdapter | Select-Object -ExpandProperty MacAddress) -eq $higherMACinHex ) {
         
        $higherMACindex = Get-NetAdapter | Where-Object MacAddress -LIKE $higherMACinHex | Select-Object -ExpandProperty ifIndex
        $higherMACname = Get-NetAdapter | Where-Object MacAddress -LIKE $higherMACinHex | Select-Object -ExpandProperty Name

    }
            
    #imports data from csv file 
    $P = Import-Csv -Path "\\machinename\path\document.csv" -Header 'Serial', 'MAC', 'Hostname', 'IP', 'Domain', 'Gateway', 'Mask', 'OU', 'NTP', 'DNS' -delimiter ','
    $match_found = "False"          
                       
    $P | ForEach-Object {

        $pMAC = $_.MAC
        
        
        if (($pMAC -eq $upmac) -OR ($pMAC -eq $higherMACinHex)) {

            $match_found = "True"
            $pHostname = $_.Hostname
            $pIP = $_.IP
            $pGateway = $_.Gateway
            $pMask = $_.Mask
            $pDomain = $_.Domain
            $pOU = $_.OU
            $pOU = $pOU -replace ':', ','
            $pNTP = $_.NTP
            $pDNS = $_.DNS

            Write-Output " "  
            Write-Host -NoNewLine "Match Found:" $pMAC 
            Write-Output " "      
            Write-Host -NoNewLine "Configuring NIC:"$higherMACname
            Write-Output " "
            Write-Host -NoNewLine "Hostname:" $pHostname
            Write-Output " "
            Write-Host -NoNewLine "IP:"$pIP
            Write-Output " "                    
            Write-Host -NoNewLine "GW:" $pGateway
            Write-Output " "
            Write-Host -NoNewLine "Mask:" $pMask
            Write-Output " "
            Write-Host -NoNewLine "Domain:" $pDomain
            Write-Output " "
            Write-Host -NoNewLine "OU:" $pOU
            Write-Output " "
            Write-Host -NoNewLine "NTP:" $pNTP
            Write-Output " "

            #Set the static IP
            Invoke-Command -ScriptBlock { netsh interface ip set address "$higherMACname" static "$pIP" "$pMask" "$pGateway" } -ArgumentList $higherMACname, $pIP, $pMask, $pGateway
                            
            #Set the NTP
            Set-TimeZone -Name "Central Standard Time"
            Push-Location
            Set-Location HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers
            Set-ItemProperty . 0 "$pNTP"
            Set-ItemProperty . "(Default)" "0"
            Set-Location HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters
            Set-ItemProperty . NtpServer "$pNTP"
            Pop-Location
            Stop-Service w32time
            Start-Service w32time
            #Set standard DNS information
            #Set-DnsClientGlobalSetting -SuffixSearchList @("domain")
                            
            #Check if domain string contains domain not case sensitive like, must use wildcards
            if ($pDomain -like "*domain*") {
                Write-output "setting DNS suffix search list to domain"
                Set-DnsClientGlobalSetting -SuffixSearchList @("domain")
    
            }
            #Check if domain string contains domain not case sensitive like, must use wildcards
            if ($pDomain -like "*domain*") {
                Write-output "setting DNS suffix search list to domain"
                Set-DnsClientGlobalSetting -SuffixSearchList @("domain")
        
            }
            if ($pDomain -like "*domain*") {
                Write-output "setting DNS suffix search list to domain"
                Set-DnsClientGlobalSetting -SuffixSearchList @("domain")

            }
            #Check if domain string contains domain not case sensitive like, must use wildcards
            if ($pDomain -like "*domain*") {
                Write-output "setting DNS suffix search list to domain"
                Set-DnsClientGlobalSetting -SuffixSearchList @("domain")

            }
            #Check if domain string contains domain not case sensitive like, must use wildcards
            if ($pDomain -like "*domain*") {
                Write-output "setting DNS suffix search list to domain "
                Set-DnsClientGlobalSetting -SuffixSearchList @("domain")
    
            }
            #Check if domain string contains domain not case sensitive like, must use wildcards
            if ($pDomain -like "*domain*") {
                Write-output "setting DNS suffix search list to domain"
                Set-DnsClientGlobalSetting -SuffixSearchList @("domain", "domain")
    
            }

            Set-DnsClient -InterfaceIndex $higherMACindex -ConnectionSpecificSuffix "domain"
            $pDNS = $pDNS -replace '"', ''
            Set-DnsClientServerAddress -InterfaceIndex $higherMACindex -ServerAddresses $pDNS
            Write-Output  " "

            #Disable the other NICS
            Disable-NetAdapter -Name (Get-NetAdapter | Where-Object MacAddress -NotMatch $higherMACinHex.SubString(0, 2)).Name -Confirm:$false

            #Disable Ipv6
            Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6

            #Disable QOS
            Disable-NetAdapterQos -Name "*" 
                            
                            
            #Join Domain and change hostname
            $password = "Password" | ConvertTo-SecureString -Force -AsPlainText
            $username = "domain\username"
            $credtials = New-Object System.Management.Automation.PSCredential($username, $password)
            $machineName = Hostname
            #Change the hostname                                                               
                                                                                            
            if ( $pHostname -eq $machineName) {

                Write-Host -NoNewline "Machine has already been named to" $pHostname
                                   
            }
            else {
                                        
                Write-Output "Renaming hostname to " $pHostname "and Restarting Machine"
                #Read-Host " Press Enter"
                Start-Sleep -Seconds 2
                Rename-Computer -NewName $pHostname -Restart
            }
                                


            #Check to see if it is already part joined to a domain ( any domain )
            $domain_Joined_Bool = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
                                
            if ( -not $domain_Joined_Bool ) {
                $password = "Password" | ConvertTo-SecureString -Force -AsPlainText
                $username = "domain\uersname"
                $credtials = New-Object System.Management.Automation.PSCredential($username, $password)
                Write-Host " Joining Domain and Restarting"
                Start-Sleep -Seconds 2
                Add-Computer -DomainName $pDomain -OUPath "$pOU"-Credential $credtials -Restart -Force

            }
            else {
                Write-Output "Already Domain Joined"
                Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -Value 1
                Remove-Item -Path "C:\users\user\Desktop\startscript.ps1" -Force

            }
                            
                           
                                

                                
            
            #$userinput = Read-Host "Enter to enter"

            break

        }
        else {
            $match_found = "False"
        }
    }



    If ($match_found -eq "False") {
        Write-Output " No match found for " $upmac
        Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -Value 1

        Read-Host "Press enter"
    }


            


                            
                  

    #Checks for a valid MAC address in Get-NetAdapter for  upmac-1 is TRUE

    #Converts the decimal MAC back to HEX in string format???
    $minusMACinHex = "{0:X}" -f ($upmacindecimal - 1)
    $minusMACinHex = $minusMACinHex.Insert(2, '-')
    $minusMACinHex = $minusMACinHex.Insert(5, '-')
    $minusMACinHex = $minusMACinHex.Insert(8, '-')
    $minusMACinHex = $minusMACinHex.Insert(11, '-')
    $minusMACinHex = $minusMACinHex.Insert(14, '-')

    #debug
    #Write-Output $minusMACinHex

    #upmac minus 1 found
    if ( (Get-NetAdapter | Select-Object -ExpandProperty MacAddress) -eq $minusMACinHex ) {
        Write-Output "The network cable was plugged into the Top Nic, please plug into the bottom"
        Read-Host "Press enter"
    }


   
   
   



}
else {
    Write-Output "No UP connection found, please plug in a network cable into the bottom onboard NIC"
}
