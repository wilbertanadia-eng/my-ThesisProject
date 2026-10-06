#!/bin/bash

# Vercel Deployment Helper Script
# This script helps prepare your Laravel application for Vercel deployment

set -e

echo "================================"
echo "Vercel Deployment Preparation"
echo "================================"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found. Creating from .env.example..."
    cp .env.example .env
    echo "✅ .env file created. Please update it with your configuration."
    exit 1
fi

# Generate application key if not set
if ! grep -q "^APP_KEY=base64:" .env; then
    echo "⚙️  Generating application key..."
    php artisan key:generate
    echo "✅ Application key generated"
fi

# Install PHP dependencies
echo ""
echo "⚙️  Installing PHP dependencies..."
composer install --no-dev --optimize-autoloader
echo "✅ PHP dependencies installed"

# Install Node dependencies
echo ""
echo "⚙️  Installing Node dependencies..."
npm ci
echo "✅ Node dependencies installed"

# Build frontend assets
echo ""
echo "⚙️  Building frontend assets..."
npm run build
echo "✅ Frontend assets built"

# Verify vercel.json exists
if [ ! -f vercel.json ]; then
    echo "❌ vercel.json not found!"
    exit 1
fi

# Check if api/index.php exists
if [ ! -f api/index.php ]; then
    echo "❌ api/index.php not found!"
    exit 1
fi

echo ""
echo "================================"
echo "✅ Preparation Complete!"
echo "================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Verify your .env configuration:"
echo "   - Set APP_ENV=production"
echo "   - Set APP_DEBUG=false"
echo "   - Set APP_URL to your production domain"
echo "   - Configure database credentials"
echo "   - Configure storage (S3, Cloudinary, etc.)"
echo ""
echo "2. Commit changes to git:"
echo "   git add ."
echo "   git commit -m 'Prepare for Vercel deployment'"
echo "   git push"
echo ""
echo "3. Deploy to Vercel:"
echo "   - Go to https://vercel.com/new"
echo "   - Import your GitHub repository"
echo "   - Set environment variables in Project Settings"
echo "   - Click Deploy"
echo ""
echo "4. After deployment, run migrations:"
echo "   vercel env pull .env.local"
echo "   php artisan migrate --force"
echo ""
echo "For more information, see DEPLOYMENT_CHECKLIST.md"
