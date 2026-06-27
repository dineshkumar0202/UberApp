#!/bin/bash
set -e

echo "Deploying Ridoo..."

cd backend
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Deployment complete."
