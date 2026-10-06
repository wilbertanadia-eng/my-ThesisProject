@echo off
REM Vercel Deployment Helper Script (Windows)
REM This script helps prepare your Laravel application for Vercel deployment

setlocal enabledelayedexpansion

echo.
echo ================================
echo Vercel Deployment Preparation
echo ================================
echo.

REM Check if .env file exists
if not exist .env (
    echo Copying .env.example to .env...
    copy .env.example .env
    echo.
    echo ^❌ .env file created from .env.example.
    echo Please update it with your configuration before running this script again.
    pause
    exit /b 1
)

REM Generate application key if not set
findstr /M "^APP_KEY=base64:" .env >nul
if errorlevel 1 (
    echo.
    echo Generating application key...
    php artisan key:generate
    echo.
    echo Application key generated
)

REM Install PHP dependencies
echo.
echo Installing PHP dependencies...
call composer install --no-dev --optimize-autoloader
echo PHP dependencies installed
echo.

REM Install Node dependencies
echo.
echo Installing Node dependencies...
call npm ci
echo Node dependencies installed
echo.

REM Build frontend assets
echo.
echo Building frontend assets...
call npm run build
echo Frontend assets built
echo.

REM Verify vercel.json exists
if not exist vercel.json (
    echo.
    echo ^❌ vercel.json not found!
    pause
    exit /b 1
)

REM Check if api/index.php exists
if not exist api\index.php (
    echo.
    echo ^❌ api/index.php not found!
    pause
    exit /b 1
)

echo.
echo ================================
echo ^✅ Preparation Complete!
echo ================================
echo.
echo Next steps:
echo.
echo 1. Verify your .env configuration:
echo    - Set APP_ENV=production
echo    - Set APP_DEBUG=false
echo    - Set APP_URL to your production domain
echo    - Configure database credentials
echo    - Configure storage (S3, Cloudinary, etc.)
echo.
echo 2. Commit changes to git:
echo    git add .
echo    git commit -m "Prepare for Vercel deployment"
echo    git push
echo.
echo 3. Deploy to Vercel:
echo    - Go to https://vercel.com/new
echo    - Import your GitHub repository
echo    - Set environment variables in Project Settings
echo    - Click Deploy
echo.
echo 4. After deployment, run migrations:
echo    vercel env pull .env.local
echo    php artisan migrate --force
echo.
echo For more information, see DEPLOYMENT_CHECKLIST.md
echo.
pause
