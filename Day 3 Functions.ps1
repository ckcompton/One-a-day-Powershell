# Functions and Methods

#https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7

##Write-host needs to be avoided

<# function getVersion {
    [CmdletBinding()]
    param{
        [Parameter(Mandatory)](
        [string]$computername
    )


    $PSVersionTable 


    #Write-host should be avoidedget-
    Write-Host $computername

    
}

getVersion('hello')

getVersion -computername Test, tes1, test2, test4

get-process  #>

#CKC my initials
#verb-noun

function Get-CKCProcessInfo {
    #This makes it an advanced funtion, the CmdletBinding let you use the built function feature of powershell for example -verbose paramaters
    [CmdletBinding()]
    param (
        [string]$processname
    )
    #Will only be displayed if you use the -verbose parameter
    Write-Verbose "This is the process name $processname"
    
    get-process -name $processname

}