@echo off
REM Quick Setup Script for Backend
REM This handles: database startup, validation, and backend server

echo.
echo ========================================
echo Aplikasi Antrian - Backend Setup
echo ========================================
echo.

echo [1/4] Starting PostgreSQL and PgAdmin (via Docker)...
docker-compose up -d
if !errorlevel! neq 0 (
    echo ❌ Failed to start Docker containers
    exit /b 1
)

echo [2/4] Waiting for database to be ready (15 seconds)...
timeout /t 15 /nobreak

echo [3/4] Validating database...
go run ./cmd/database-util -validate
if !errorlevel! neq 0 (
    echo.
    echo ⚠️ Database validation failed. Attempting reset...
    go run ./cmd/database-util -reset
    if !errorlevel! neq 0 (
        echo ❌ Reset failed. Check database manually!
        exit /b 1
    )
)

echo.
echo ✅ All checks passed! 
echo.
echo [4/4] Starting API server...
echo.
echo API running on: http://localhost:8081
echo Health check: http://localhost:8081/health
echo.
echo PgAdmin: http://localhost:5050 (admin@example.com / admin123)
echo.

go run ./cmd/server
