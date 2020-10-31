

$response = Invoke-WebRequest -Uri https://blogs.msdn.microsoft.com/powershell/feed/

#Out-file -FilePath output.txt -InputObject $response
ConvertTo-Xml $response
Write-Output $response

