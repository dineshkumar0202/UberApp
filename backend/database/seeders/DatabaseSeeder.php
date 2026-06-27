<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Driver;
use App\Models\Vehicle;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Seed Admin
        User::updateOrCreate(
            ['email' => 'admin@admin.com'],
            [
                'name' => 'System Admin',
                'phone' => '+919999999999',
                'role' => 'admin',
                'password' => Hash::make('admin@123'),
                'is_active' => true,
            ]
        );

        // 2. Seed Customer
        User::updateOrCreate(
            ['email' => 'customer@ridoo.com'],
            [
                'name' => 'Demo Customer',
                'phone' => '+918888888888',
                'role' => 'customer',
                'password' => Hash::make('password'),
                'is_active' => true,
            ]
        );

        // 3. Seed Driver
        $driverUser = User::updateOrCreate(
            ['email' => 'driver@ridoo.com'],
            [
                'name' => 'Demo Driver',
                'phone' => '+917777777777',
                'role' => 'driver',
                'password' => Hash::make('password'),
                'is_active' => true,
            ]
        );

        $driver = Driver::updateOrCreate(
            ['user_id' => $driverUser->id],
            [
                'license_number' => 'DL-1234567890',
                'license_expiry' => now()->addYears(5),
                'is_online' => false,
                'is_approved' => true,
                'rating' => 4.90,
                'total_rides' => 15,
            ]
        );

        Vehicle::updateOrCreate(
            ['driver_id' => $driver->id],
            [
                'make' => 'Maruti Suzuki',
                'model' => 'Swift Dzire',
                'year' => 2022,
                'color' => 'White',
                'plate_number' => 'KA-01-MJ-9999',
                'vehicle_type' => 'economy',
                'is_active' => true,
            ]
        );
    }
}
