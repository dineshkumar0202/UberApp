# Ridoo

Ridoo is a complete Uber-type ride booking platform built with **Flutter**, **Laravel**, **Filament**, and **MySQL**.

## Architecture

| Component | Technology |
|-----------|------------|
| Customer App | Flutter |
| Driver App | Flutter |
| Admin Panel | Laravel Filament |
| Backend API | Laravel |
| Database | MySQL |
| Realtime | Redis + WebSockets (Laravel Reverb) |
| Push Notifications | Firebase FCM |
| Maps | Google Maps API |

## Project Structure

```
Ridoo/
├── backend/          # Laravel API server
├── customer_app/     # Flutter customer application
├── driver_app/       # Flutter driver application
├── admin_panel/      # Filament admin modules
├── website/          # Marketing website
├── shared/           # Shared assets and API docs
├── design/           # UI/UX design files
├── docs/             # Documentation
├── deployment/       # Docker, nginx, CI/CD
├── postman/          # API collections
└── scripts/          # Utility scripts
```

## Getting Started

### Prerequisites

- PHP 8.2+
- Composer
- MySQL 8+
- Redis
- Node.js 18+
- Flutter 3.x
- Docker (optional)

### Backend Setup

```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

### Customer App

```bash
cd customer_app
flutter pub get
flutter run
```

### Driver App

```bash
cd driver_app
flutter pub get
flutter run
```

### Docker (Full Stack)

```bash
docker-compose up -d
```

## Development Flow

1. Project setup, authentication, database design
2. Customer App — booking, tracking, payments
3. Driver App — ride requests, navigation, earnings
4. Backend — driver matching, fare calculation, realtime tracking
5. Admin Panel — analytics, reports, deployment

## License

See [LICENSE](LICENSE).
