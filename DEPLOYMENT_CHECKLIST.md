# Vercel Serverless Deployment Checklist

## Pre-Deployment Setup

### 1. Database Preparation
- [ ] Set up a hosted database (MySQL/PostgreSQL) on:
  - AWS RDS
  - DigitalOcean Managed Databases
  - Render (formerly Render)
  - PlanetScale (MySQL)
  - Heroku Postgres
  - Any other managed database service

- [ ] Test database connection locally:
  ```bash
  php artisan tinker
  DB::connection()->getPdo();
  ```

### 2. External Storage Configuration
- [ ] Choose a storage provider:
  - [ ] AWS S3
  - [ ] Cloudinary (currently in your dependencies)
  - [ ] DigitalOcean Spaces
  - [ ] Azure Blob Storage

- [ ] Update `.env` with storage credentials:
  ```
  FILESYSTEM_DISK=s3
  AWS_ACCESS_KEY_ID=...
  AWS_SECRET_ACCESS_KEY=...
  AWS_DEFAULT_REGION=us-east-1
  AWS_BUCKET=your-bucket
  ```

### 3. Email Service Configuration
- [ ] Choose an email provider:
  - [ ] Resend (already in dependencies)
  - [ ] Mailgun (already in dependencies)
  - [ ] SendGrid
  - [ ] AWS SES

- [ ] Configure in `.env`:
  ```
  MAIL_MAILER=resend
  RESEND_API_KEY=...
  ```

### 4. Update .env for Production
- [ ] Set `APP_ENV=production`
- [ ] Set `APP_DEBUG=false`
- [ ] Set `APP_URL` to your production domain
- [ ] Set all database variables
- [ ] Set all external service credentials
- [ ] Set `CACHE_DRIVER=database` (already default)
- [ ] Set `SESSION_DRIVER=database` (already default)
- [ ] Set `QUEUE_CONNECTION=database` (already default)

### 5. Verify Configuration Files
- [ ] Check `config/cache.php` - should use 'database' as default ✅
- [ ] Check `config/session.php` - should use 'database' as default ✅
- [ ] Check `config/queue.php` - should use 'database' as default ✅
- [ ] Check `config/filesystems.php` - production disk should be 's3' or similar

### 6. Build & Test Locally
```bash
# Install dependencies
composer install --no-dev
npm ci

# Build assets
npm run build

# Test locally with production environment
cp .env .env.production
php artisan migrate --env=production (with test database)
php artisan serve
```

### 7. Git Preparation
- [ ] Ensure all files are committed:
  ```bash
  git status
  git add .
  git commit -m "Configure for Vercel deployment"
  git push origin main
  ```

- [ ] Files that should NOT be in .gitignore (already configured):
  - ✅ `api/index.php`
  - ✅ `vercel.json`
  - ✅ `.vercelignore`
  - ✅ `vite.config.js` (updated)

## Vercel Deployment

### 8. Connect GitHub to Vercel
- [ ] Go to https://vercel.com/new
- [ ] Click "Import Git Repository"
- [ ] Select your GitHub repository
- [ ] Click "Import"

### 9. Configure Build Settings
- [ ] **Framework Preset**: Leave as "Other" (already configured in vercel.json)
- [ ] **Build Command**: Should be `npm run build` (in vercel.json)
- [ ] **Output Directory**: Should be `public` (in vercel.json)
- [ ] **Install Command**: Leave as default `npm ci`
- [ ] **Development Command**: Leave as default

### 10. Set Environment Variables in Vercel Dashboard
In Project Settings → Environment Variables, add:

**Application**
```
APP_NAME=VSULHS_SSLG
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:YOUR_APP_KEY_HERE
APP_URL=https://yourdomain.com
APP_LOCALE=en
```

**Database**
```
DB_CONNECTION=mysql (or pgsql)
DB_HOST=your-db-host.com
DB_PORT=3306
DB_DATABASE=your_database
DB_USERNAME=your_user
DB_PASSWORD=your_password
```

**Cache & Session**
```
CACHE_DRIVER=database
SESSION_DRIVER=database
QUEUE_CONNECTION=database
```

**Storage**
```
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=your-bucket-name
AWS_URL=https://your-bucket.s3.amazonaws.com
```

**Mail (Resend example)**
```
MAIL_MAILER=resend
RESEND_API_KEY=your_resend_key
```

### 11. Deploy
- [ ] Click "Deploy"
- [ ] Wait for build to complete (should take 2-3 minutes)
- [ ] Check that deployment is successful

### 12. Post-Deployment Database Setup

**Option A: Using Vercel CLI**
```bash
vercel env pull .env.local
php artisan migrate --force
php artisan db:seed --force (if needed)
```

**Option B: Create a deployment hook**
Add to `vercel.json` under routes (before final catch-all):
```json
{
  "src": "/migrate",
  "dest": "/api/migrate.php"
}
```

Then create `api/migrate.php`:
```php
<?php
// Only allow from localhost or specific IPs
if (!in_array($_SERVER['REMOTE_ADDR'] ?? '', ['127.0.0.1', 'YOUR_IP'])) {
    http_response_code(403);
    exit('Forbidden');
}

require __DIR__.'/../vendor/autoload.php';
$app = require __DIR__.'/../bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->call('migrate', ['--force' => true]);
echo 'Migration completed';
```

**Option C: SSH to database and run locally**
If your database allows SSH tunneling, connect and run migrations from your machine.

### 13. Verify Deployment
- [ ] Visit your production URL
- [ ] Check that pages load
- [ ] Test authentication
- [ ] Test file uploads (should upload to S3)
- [ ] Test email sending
- [ ] Check logs in Vercel dashboard

## Monitoring & Maintenance

### 14. Set Up Logging
- [ ] Configure external logging service or use Vercel's built-in logs
- [ ] Monitor error rates and performance

### 15. Database Backups
- [ ] Set up automated backups with your database provider
- [ ] Test restore procedures

### 16. Domain Setup
- [ ] Update DNS to point to Vercel:
  - Add CNAME record (or follow Vercel's instructions)
  - Update `APP_URL` in Vercel environment variables
  - Re-deploy to take effect

### 17. SSL Certificate
- [ ] Vercel automatically provisions SSL certificate
- [ ] Verify HTTPS works

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Build fails | Check build logs in Vercel dashboard |
| Database connection error | Verify DB_* env vars, check firewall/network rules |
| Assets not loading | Ensure `npm run build` runs during deployment, check `public/build` |
| 502/503 errors | Check function logs, verify storage is writable |
| Sessions not persisting | Ensure SESSION_DRIVER=database and session table exists |
| File uploads fail | Verify S3/storage credentials and bucket permissions |

## Scaling & Performance

- [ ] Enable Vercel's Edge Caching for static assets
- [ ] Consider setting up Redis for enhanced cache/session performance
- [ ] Monitor function execution time and optimize if needed
- [ ] Use Cloudinary or CDN for image optimization

## Further Documentation

- [Vercel Laravel Deployment](https://vercel.com/docs/frameworks/laravel)
- [Laravel Deployment Guide](https://laravel.com/docs/11/deployment)
- [Vercel Environment Variables](https://vercel.com/docs/projects/environment-variables)
