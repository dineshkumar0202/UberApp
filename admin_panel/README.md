# Ridoo Admin Panel

Filament-based admin panel integrated into the Laravel backend.

## Modules

- Dashboard — overview & analytics
- Users / Customers / Drivers — user management
- Rides — live ride monitoring
- Earnings / Payments / Wallets — financial management
- Coupons — promotional codes
- Notifications — push & in-app notifications
- Support — ticket management
- Reports & Settings

## Access

After running migrations, install Filament admin:

```bash
cd backend
php artisan filament:install --panels
php artisan make:filament-user
```

Admin URL: `http://localhost:8000/admin`
