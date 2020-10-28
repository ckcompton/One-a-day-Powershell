#Today I would like to learn about Tcpclient connect




$client = New-Object System.Net.Sockets.TcpClient

# There are a lot of cool things to do with System.Net.Sockets.TcpClient it looks like
# https://docs.microsoft.com/en-us/dotnet/api/system.net.sockets.tcpclient?view=netcore-3.1

# Mainly I want to learn because tnc is slow aka test-netconnection
# tnc does a ping, that usually has to time out, it does a tcp connect but I think it also wants to do a dns lookup. It just seems to take a while to finish.
# Is there a function I can run that will just test the conneciton? I want small timeout. Most networks today dont need a long time out anymore

#Well the microsoft docs didnt really help
# Lets see what kind of methods it has

$client.Connect("localhost", 3213)

#The methond doesnt return any value so testing if it is true doesnt work..
# Well it is not as clear as I would like it to be 

#do I use connect() or beginconnection(), connect is asynchronous , begin connected is sychronyous. 
# 


#When I ran this, it seemed to connect. I didnt get an error.

if ($client.Connected) {

    Write-Host Connected
}
else {
    Write-Host NotConnected
}

$client.Dispose()