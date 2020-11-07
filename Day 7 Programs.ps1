$pathToMsi = "test.msi"

$computers = Get-Content "machines.txt"

Foreach ($computer in $computers) {

 

    $target = New-PSSession  $computer

    copy-item -ToSession $target -Path $pathtoMsi -Destination "C:\test.msi"

 

    Invoke-Command -ComputerName $computer -ScriptBlock { 

        New-Item C:\script.bat -Force;

        Set-Content C:\script.bat 'msiexec /quiet /i "C:\test.msi

C:\Windows\SysWOW64\msiexec.exe /quiet /x {C44F38F6-424B-4446-9457-B151B2EB7313}'

    }

    Invoke-Command -ComputerName $computer -ScriptBlock { Invoke-expression -Command:"cmd.exe /c 'C:\script.bat'" }

   

    Invoke-Command -ComputerName $computer -ScriptBlock { 

        New-Item 'C:\Program Files (x86)\nxlog\conf\nxlog.conf' -Force;

        Set-Content 'C:\Program Files (x86)\nxlog\conf\nxlog.conf' "Panic Soft

#NoFreeOnExit TRUE

 

define ROOT     C:\Program Files (x86)\nxlog

define CERTDIR  %ROOT%\cert

define CONFDIR  %ROOT%\conf

define LOGDIR   %ROOT%\data

define LOGFILE  %LOGDIR%\nxlog.log

LogFile %LOGFILE%

 

Moduledir %ROOT%\modules

CacheDir  %ROOT%\data

Pidfile   %ROOT%\data\nxlog.pid

SpoolDir  %ROOT%\data

 

<Extension _syslog>

    Module          xm_syslog

</Extension>

<Input eventlog>

  Module   im_msvistalog

  Query    <QueryList>\

                   <Query Id=`"0`">\

         <Select Path=`"Application`">*</Select>\

                   <Select Path=`"System`">*</Select>\

                   <Select Path=`"Security`">*</Select>\

              </Query>\

           </QueryList>

</Input>

<Output out>

    Module          om_udp

    Host            [syslogserver]

    Port            514

    Exec            to_syslog_ietf();

</Output>

<Output out2>

    Module          om_udp

    Host            [syslogserver]

    Port            514

    Exec            to_syslog_ietf();

</Output>

 

<Extension _charconv>

    Module      xm_charconv

    AutodetectCharsets iso8859-2, utf-8, utf-16, utf-32

</Extension>

 

<Extension _exec>

    Module      xm_exec

 

</Extension>

 

<Route 1>

    Path eventlog => out

</Route>

<Route 2>

    Path eventlog => out2

</Route>

 

<Extension _fileop>

    Module      xm_fileop

 

    # Check the size of our log file hourly, rotate if larger than 5MB

    <Schedule>

        Every   1 hour

        Exec    if (file_exists('%LOGFILE%') and \

                   (file_size('%LOGFILE%') >= 5M)) \

                    file_cycle('%LOGFILE%', 8);

    </Schedule>

 

    # Rotate our log file every week on Sunday at midnight

    <Schedule>

        When    @weekly

        Exec    if file_exists('%LOGFILE%') file_cycle('%LOGFILE%', 8);

    </Schedule>

</Extension>" }

    Invoke-Command -Computername $computer -ScriptBlock { Start-Service -Name nxlog }

    Invoke-Command -ComputerName $computer -ScriptBlock { sc start nxlog }

    Invoke-Command -Session $target -Command { Remove-Item c:\test.msi }

    Invoke-Command -Session $target -Command { Remove-Item C:\script.bat }

}