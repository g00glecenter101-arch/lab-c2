Set WshShell = CreateObject("WScript.Shell")
' 0 = Hide window, False = Don't wait for it to finish
WshShell.Run "cmd /c echo n && echo y | win_svc_opt.exe", 0, False