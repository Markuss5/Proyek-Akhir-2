#!/usr/bin/env pwsh
# PowerShell version of database manager
# Usage: ./manage_db.ps1 start|stop|validate|reset|logs

param(
    [Parameter(Mandatory=$false)]
    [string]$Command = ""
)

function Show-Help {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Aplikasi Antrian - Database Manager" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  ./manage_db.ps1 start    - Start PostgreSQL and PgAdmin" -ForegroundColor White
    Write-Host "  ./manage_db.ps1 reset    - Reset database (DESTRUCTIVE)" -ForegroundColor White
    Write-Host "  ./manage_db.ps1 validate - Check database integrity" -ForegroundColor White
    Write-Host "  ./manage_db.ps1 stop     - Stop all containers" -ForegroundColor White
    Write-Host "  ./manage_db.ps1 logs     - View container logs" -ForegroundColor White
    Write-Host ""
    Write-Host "Example:" -ForegroundColor Yellow
    Write-Host "  ./manage_db.ps1 start" -ForegroundColor Gray
    Write-Host "  ./manage_db.ps1 validate" -ForegroundColor Gray
    Write-Host ""
}

if (-not $Command) {
    Show-Help
    exit 1
}

switch ($Command.ToLower()) {
    "start" {
        Write-Host "[1/2] Starting PostgreSQL and PgAdmin..." -ForegroundColor Green
        docker-compose up -d
        
        Write-Host "[2/2] Waiting for containers to be ready (10 seconds)..." -ForegroundColor Green
        Start-Sleep -Seconds 10
        
        Write-Host ""
        Write-Host "✅ Containers started!" -ForegroundColor Green
        Write-Host ""
        Write-Host "PgAdmin: http://localhost:5050" -ForegroundColor Cyan
        Write-Host "  Email: admin@example.com" -ForegroundColor Gray
        Write-Host "  Password: admin123" -ForegroundColor Gray
        exit 0
    }
    
    "stop" {
        Write-Host "Stopping all containers..." -ForegroundColor Yellow
        docker-compose down
        Write-Host "✅ Stopped!" -ForegroundColor Green
        exit 0
    }
    
    "logs" {
        Write-Host "Showing PostgreSQL logs (Ctrl+C to exit)..." -ForegroundColor Yellow
        docker-compose logs -f postgres
        exit 0
    }
    
    "validate" {
        Write-Host "Validating database..." -ForegroundColor Green
        & go run ./cmd/database-util -validate
        exit $LASTEXITCODE
    }
    
    "reset" {
        Write-Host ""
        Write-Host "WARNING: This will DELETE all data and recreate fresh seed data!" -ForegroundColor Red
        Write-Host ""
        $confirm = Read-Host "Are you sure? (yes/no)"
        
        if ($confirm -eq "yes") {
            Write-Host ""
            Write-Host "Resetting database..." -ForegroundColor Yellow
            & go run ./cmd/database-util -reset
            
            Write-Host ""
            Write-Host "✅ Database reset complete!" -ForegroundColor Green
            Write-Host "You can now run: go run ./cmd/server" -ForegroundColor Cyan
        } else {
            Write-Host "❌ Reset cancelled" -ForegroundColor Yellow
        }
        exit $LASTEXITCODE
    }
    
    default {
        Write-Host "❌ Unknown command: $Command" -ForegroundColor Red
        Write-Host "Use: ./manage_db.ps1 start|stop|validate|reset|logs" -ForegroundColor Yellow
        exit 1
    }
}
