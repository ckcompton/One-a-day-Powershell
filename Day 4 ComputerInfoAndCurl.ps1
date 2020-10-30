function Get-CKCcomputerinfo {
    [CmdletBinding()]
    param (
        [string]$computername
    )
    
   
    $computerinfo = Get-CimInstance -ComputerName $computername -ClassName Win32_Processor 
    return($computerinfo.MaxClockSpeed)
    


}
$result = get-CKCcomputerinfo
write-output $result 
while ($result -gt 3190) {
    if ($result -lt 500 ) {

        Write-Output "Less than 500"
    }
    else {

        Write-Output "More than 500"
    }
    $result = $result - 1
}
#This command will grab the file from ethe google.com url. Its an HTTP Get request. 
#I am mainly interested in output2.txt. That contains the info from STDERR
# STDERR contains the date from what I am looking for
curl -v google.com -o output.txt  2> output2.txt 

#Get the date from the file, parse it using some regex.
#This will grab the line that contains "< Date:" , simple but works
$date = (Get-ChildItem .\output2.txt | Select-String -Pattern "^\< Date:" ).ToString()
# I want to split it because I don't want all that extra stuff
$datesplit = $date.Split("<")

#Then I want to output the second index of the datesplit array that has just the date in it 
Write-Output "The current time from google (aka a curl) is : " $datesplit[1]