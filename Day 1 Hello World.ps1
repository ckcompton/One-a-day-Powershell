# This is a comment
# I will be using Powershell Core 7 instead of powershell
# The difference between the two versions can be found here https://www.ghacks.net/2018/01/12/powershell-vs-powershell-core-what-you-need-to-know/
# I am using Visual Studio Code and the Powershell extension
# I belive Visual Studio Code has github functionality built in
#testing 



Write-Host "Hello World!"





#I will try to get some system information
# Basic informatoin like cpu, ram , hdd size and partitions
# I would use WMI to get the information but powershell 7 does not use that, it uses get-ciminstance 

#get-Command -Module CimCmdlets
#  I will be using
$Cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty Name
$Ram = Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object -ExpandProperty Capacity
$SSD = Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object -ExpandProperty Size

$SSD = $SSD / 1000000000
$ram = $ram | ForEach-Object -Process { $_ / 1000000000 }
Write-Host CPU=$Cpu
Write-Host SSD=$SSD GB
Write-Host Ram=$Ram GB
