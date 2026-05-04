@echo off
REM Database Utilities Script for Windows
REM This script helps manage database setup and troubleshooting

setlocal enabledelayedexpansion

echo.
echo ========================================
echo Aplikasi Antrian - Database Manager
echo ========================================
echo.

if "%1"=="" (
    echo Usage:
    echo   manage_db.bat start    - Start PostgreSQL and PgAdmin
    echo   manage_db.bat reset    - Reset database (DESTRUCTIVE)
    echo   manage_db.bat validate - Check database integrity
    echo   manage_db.bat stop     - Stop all containers
    echo   manage_db.bat logs     - View container logs
    echo.
    echo Example:
    echo   manage_db.bat start
    echo   manage_db.bat validate
    echo   manage_db.bat reset
    echo.
    exit /b 1
)

if "%1"=="start" (
    echo [1/2] Starting PostgreSQL and PgAdmin...
    docker-compose up -d
    echo.
    echo [2/2] Waiting for containers to be ready (10 seconds)...
    timeout /t 10 /nobreak
    echo.
    echo ✅ Containers started!
    echo.
    echo PgAdmin: http://localhost:5050
    echo   Email: admin@example.com
    echo   Password: admin123
    echo.
    exit /b 0
)

if "%1"=="stop" (
    echo Stopping all containers...
    docker-compose down
    echo ✅ Stopped!
    exit /b 0
)

if "%1"=="logs" (
    echo Showing PostgreSQL logs (Ctrl+C to exit)...
    docker-compose logs -f postgres
    exit /b 0
)

if "%1"=="validate" (
    echo Validating database...
    go run ./cmd/database-util -validate
    exit /b !errorlevel!
)

if "%1"=="reset" (
    echo.
    echo WARNING: This will DELETE all data and recreate fresh seed data!
    echo.
    set /p confirm="Are you sure? (yes/no): "
    
    if /i "!confirm!"=="yes" (
        echo.
        echo Resetting database...
        go run ./cmd/database-util -reset
        echo.
        echo ✅ Database reset complete!
        echo You can now run: go run ./cmd/server
    ) else (
        echo ❌ Reset cancelled
    )
    exit /b 0
)

echo ❌ Unknown command: %1
echo Use: manage_db.bat start^|stop^|validate^|reset^|logs
exit /b 1
