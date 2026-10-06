#!/usr/bin/env sh

# Vercel install helper: install npm deps and run Composer only if PHP exists
set -e

echo "Running npm ci..."
npm ci

if command -v php >/dev/null 2>&1; then
  echo "PHP detected — installing Composer dependencies..."
  if command -v curl >/dev/null 2>&1; then
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  elif command -v wget >/dev/null 2>&1; then
    wget -O composer-setup.php https://getcomposer.org/installer
  else
    echo "Neither curl nor wget available — skipping Composer installer download"
  fi

  if [ -f composer-setup.php ]; then
    php composer-setup.php --no-ansi
    php composer.phar install --no-dev --optimize-autoloader --no-interaction
    rm -f composer-setup.php composer.phar
  else
    echo "Composer installer not found — skipping Composer install"
  fi
else
  echo "PHP not found — skipping Composer install"
fi

echo "Install step complete."
