#!/usr/bin/env sh

#!/usr/bin/env sh

# Vercel install helper: install npm deps and run Composer only if PHP exists
# This script is fault-tolerant: it logs errors to public/build/install-log.txt
# and exits 0 so the overall deployment can continue for debugging.

LOGFILE="public/build/install-log.txt"
mkdir -p "public/build"
echo "Install log - $(date)" > "$LOGFILE"

echo "Running npm ci..." | tee -a "$LOGFILE"
if npm ci 2>&1 | tee -a "$LOGFILE"; then
  echo "npm ci succeeded" | tee -a "$LOGFILE"
else
  echo "npm ci failed" | tee -a "$LOGFILE"
fi

if command -v php >/dev/null 2>&1; then
  echo "PHP detected — attempting Composer install" | tee -a "$LOGFILE"
  if command -v curl >/dev/null 2>&1; then
    echo "Downloading Composer installer with curl" | tee -a "$LOGFILE"
    if php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" 2>&1 | tee -a "$LOGFILE"; then
      echo "Composer installer downloaded" | tee -a "$LOGFILE"
    else
      echo "Composer download failed" | tee -a "$LOGFILE"
    fi
  elif command -v wget >/dev/null 2>&1; then
    echo "Downloading Composer installer with wget" | tee -a "$LOGFILE"
    if wget -O composer-setup.php https://getcomposer.org/installer 2>&1 | tee -a "$LOGFILE"; then
      echo "Composer installer downloaded" | tee -a "$LOGFILE"
    else
      echo "Composer download failed" | tee -a "$LOGFILE"
    fi
  else
    echo "Neither curl nor wget available — cannot download Composer" | tee -a "$LOGFILE"
  fi

  if [ -f composer-setup.php ]; then
    echo "Running Composer installer" | tee -a "$LOGFILE"
    if php composer-setup.php --no-ansi 2>&1 | tee -a "$LOGFILE"; then
      echo "Composer installer executed" | tee -a "$LOGFILE"
      if php composer.phar install --no-dev --optimize-autoloader --no-interaction 2>&1 | tee -a "$LOGFILE"; then
        echo "Composer install succeeded" | tee -a "$LOGFILE"
      else
        echo "Composer install failed" | tee -a "$LOGFILE"
      fi
      rm -f composer-setup.php composer.phar
    else
      echo "Composer installer execution failed" | tee -a "$LOGFILE"
    fi
  else
    echo "Composer installer not present — skipping Composer install" | tee -a "$LOGFILE"
  fi
else
  echo "PHP not found — skipping Composer install" | tee -a "$LOGFILE"
fi

echo "Install step complete." | tee -a "$LOGFILE"

# Always exit zero so Vercel deployment doesn't fail solely due to install step
exit 0
