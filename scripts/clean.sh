#!/bin/bash
set -e

echo "Cleaning Ridoo project..."

cd backend && php artisan cache:clear && php artisan config:clear && php artisan route:clear && cd ..
cd customer_app && flutter clean && cd ..
cd driver_app && flutter clean && cd ..

echo "Clean complete."
