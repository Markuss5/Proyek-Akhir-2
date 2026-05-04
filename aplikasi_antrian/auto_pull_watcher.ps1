# Auto-Pull PDF Watcher - Simple Version
$checkInterval = 2
$projectFolder = "$PSScriptRoot"
$queueFolder = "$PSScriptRoot\queue_pdfs"
$emulatorPath = "/storage/emulated/0/Android/data/com.example.aplikasi_antrian/files/Download"

if (-not (Test-Path $queueFolder)) { mkdir $queueFolder | Out-Null }

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "PDF Auto-Pull Watcher STARTED" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Monitoring: $emulatorPath" -ForegroundColor Yellow
Write-Host "Saving to: queue_pdfs (relative path)" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
Write-Host ""

$lastCount = 0

while ($true) {
    $pdfs = @(adb shell ls $emulatorPath 2>$null | Where-Object { $_ -match "Antrian.*\.pdf" })
    $count = $pdfs.Count
    
    if ($count -gt $lastCount) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] NEW PDF(S) DETECTED! Pulling $($count - $lastCount) file(s)..." -ForegroundColor Green
        
        # Change to project folder for relative path pulls
        Push-Location $projectFolder
        
        foreach ($pdf in $pdfs) {
            $pdf = $pdf.Trim()
            $null = adb pull "$emulatorPath/$pdf" queue_pdfs/ 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] [OK] Pulled: $pdf" -ForegroundColor Green
            } else {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] [FAIL] Failed: $pdf" -ForegroundColor Red
            }
        }
        
        Pop-Location
        
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] [INFO] Opening folder..." -ForegroundColor Yellow
        explorer.exe $queueFolder
        $lastCount = $count
    }
    
    Start-Sleep -Seconds $checkInterval
}
