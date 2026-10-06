# Vercel Deployment Guide

## Prerequisites

Before deploying to Vercel, ensure you have:

1. A Vercel account (https://vercel.com)
2. Your GitHub repository connected to Vercel
3. A database (MySQL, PostgreSQL, or similar) hosted externally (Vercel doesn't provide built-in databases)

## Required Environment Variables on Vercel

Set these environment variables in your Vercel project settings (Settings > Environment Variables):

### Core Application
- `APP_NAME` - Application name (e.g., VSULHS_SSLG)
- `APP_ENV` - Set to `production`
- `APP_DEBUG` - Set to `false`
- `APP_KEY` - Your Laravel application key (generate with `php artisan key:generate`)
- `APP_URL` - Your production domain

### Database Configuration
- `DB_CONNECTION` - Database type (mysql, pgsql, etc.)
- `DB_HOST` - Database host
- `DB_PORT` - Database port
- `DB_DATABASE` - Database name
- `DB_USERNAME` - Database user
- `DB_PASSWORD` - Database password

### Cache & Session
- `CACHE_DRIVER` - Set to `database` or `redis` (not `file` on serverless)
- `SESSION_DRIVER` - Set to `cookie` or `database`
- `QUEUE_CONNECTION` - Set to `sync` or `database` (not `file`)

### Mail
- `MAIL_DRIVER` - Email service (e.g., `mailgun`, `resend`, `ses`)
- Add service-specific credentials (MAILGUN_DOMAIN, MAILGUN_SECRET, etc.)

### File Storage
- `FILESYSTEM_DISK` - Set to `s3` or `cloudinary` for production
- Add credentials for your chosen storage service

### Optional (if using external services)
- `CLOUDINARY_URL` - If using Cloudinary for image storage
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, etc. - For S3 storage

## Deployment Steps

1. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Configure for Vercel deployment"
   git push
   ```

2. **Connect to Vercel**
   - Go to https://vercel.com
   - Click "Add New" > "Project"
   - Import your GitHub repository
   - Select the root directory (leave as default)
   - Click "Deploy"

3. **Configure Environment Variables**
   - In Vercel Dashboard, go to Settings > Environment Variables
   - Add all required variables listed above
   - Redeploy after adding variables

4. **Database Migrations**
   - After the first deployment, you'll need to run migrations
   - Use Vercel's CLI or create an endpoint to run migrations
   - Or set up a separate task in your deployment pipeline

## Important Notes

### Storage & Temporary Files
- The `/storage` directory is ephemeral on serverless and will be reset on each deployment
- Use external storage (S3, Cloudinary, etc.) for persistent file uploads
- Configure `FILESYSTEM_DISK` to use S3 or Cloudinary

### Database Operations
- Cache and session drivers should use `database`, `cookie`, or external services (Redis)
- File-based drivers won't persist between function invocations
- Queue jobs must use persistent storage (database, Redis, etc.)

### Performance Optimization
- Asset compilation is done during build time (Vite builds assets)
- Only request files are handled by the serverless function
- Static assets (from `public/build`, `public/images`, etc.) are served from CDN

### Logs
- Logs are written to `/storage/logs`
- Use `LOG_CHANNEL=stderr` or integrate with external logging service for persistent logs

## Running Migrations & Seeders

For first-time setup, run migrations after deployment:

**Option 1: Using Vercel CLI**
```bash
vercel env pull .env.local
php artisan migrate --force
```

**Option 2: Create an artisan endpoint**
Create a route like `/artisan/migrate` that calls migrations programmatically (only for first setup).

**Option 3: Manual via SSH**
If you have SSH access to your database server, connect directly and run Laravel migrations locally against the production database.

## Troubleshooting

### "Class 'ZipArchive' not found"
- Add `ext-zip` requirement (already in composer.json)

### "Storage is not writable"
- Ensure `storage/framework/sessions`, `storage/framework/views`, etc. directories exist
- These are created during `composer install`

### Database connection errors
- Verify all DB_* environment variables are correctly set
- Check database credentials and firewall rules
- Ensure database server allows connections from Vercel

### Assets not loading
- Run `npm run build` locally to test the build process
- Verify `public/build` directory is created with manifest.json
- Check Vite manifest file exists after build

## Local Testing

Before deploying, test locally:

```bash
# Install dependencies
composer install
npm install

# Build assets
npm run build

# Run migrations (if database is available)
php artisan migrate

# Serve locally
php artisan serve
```

## Rollback

To rollback to a previous deployment in Vercel:
1. Go to your project in Vercel Dashboard
2. Click "Deployments"
3. Find the previous deployment
4. Click the three dots menu
5. Select "Promote to Production"
