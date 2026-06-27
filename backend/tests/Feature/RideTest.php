<?php

namespace Tests\Feature;

use App\Models\Driver;
use App\Models\Ride;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RideTest extends TestCase
{
    use RefreshDatabase;

    private User $customer;
    private User $driverUser;
    private Driver $driver;

    protected function setUp(): void
    {
        parent::setUp();

        // Create Customer
        $this->customer = User::create([
            'name' => 'Jane Customer',
            'email' => 'customer@example.com',
            'phone' => '+919876543210',
            'password' => bcrypt('password123'),
            'role' => 'customer',
        ]);

        // Create Driver
        $this->driverUser = User::create([
            'name' => 'John Driver',
            'email' => 'driver@example.com',
            'phone' => '+918765432109',
            'password' => bcrypt('password123'),
            'role' => 'driver',
        ]);

        $this->driver = Driver::create([
            'user_id' => $this->driverUser->id,
            'is_online' => true,
            'is_approved' => true,
            'current_latitude' => 12.9716, // Bangalore coordinates
            'current_longitude' => 77.5946,
        ]);

        // Add Vehicle
        Vehicle::create([
            'driver_id' => $this->driver->id,
            'make' => 'Maruti Suzuki',
            'model' => 'Swift',
            'year' => 2022,
            'color' => 'White',
            'plate_number' => 'KA-01-AB-1234',
            'vehicle_type' => 'economy',
        ]);
    }

    public function test_customer_can_create_ride_request_and_driver_can_lifecycle(): void
    {
        // 1. Customer creates a ride request
        $customerToken = $this->customer->createToken('test')->plainTextToken;

        $rideResponse = $this->withHeader('Authorization', 'Bearer ' . $customerToken)
            ->postJson('/api/v1/rides', [
                'pickup_address' => 'MG Road Metro, Bangalore',
                'pickup_latitude' => 12.9750,
                'pickup_longitude' => 77.6000,
                'drop_address' => 'Indiranagar Metro, Bangalore',
                'drop_latitude' => 12.9784,
                'drop_longitude' => 77.6408,
                'ride_type' => 'economy',
                'payment_method' => 'cash',
            ]);

        $rideResponse->assertStatus(201)
            ->assertJson([
                'status' => 'searching',
                'pickup_address' => 'MG Road Metro, Bangalore',
                'payment_method' => 'cash',
            ]);

        $rideId = $rideResponse->json('id');

        // 2. Driver fetches pending requests close to their location (MG Road to Bangalore coordinates is within 5 km)
        $driverToken = $this->driverUser->createToken('test')->plainTextToken;

        $pendingResponse = $this->withHeader('Authorization', 'Bearer ' . $driverToken)
            ->getJson('/api/v1/driver/rides/pending');

        $pendingResponse->assertStatus(200);
        $this->assertCount(1, $pendingResponse->json());
        $this->assertEquals($rideId, $pendingResponse->json('0.id'));

        // 3. Driver accepts the ride
        $acceptResponse = $this->withHeader('Authorization', 'Bearer ' . $driverToken)
            ->postJson("/api/v1/rides/{$rideId}/accept");

        $acceptResponse->assertStatus(200)
            ->assertJson([
                'id' => $rideId,
                'driver_id' => $this->driver->id,
                'status' => 'accepted',
            ]);

        // 4. Driver arrives at the pickup spot
        $arriveResponse = $this->withHeader('Authorization', 'Bearer ' . $driverToken)
            ->postJson("/api/v1/rides/{$rideId}/arrive");

        $arriveResponse->assertStatus(200)
            ->assertJson([
                'id' => $rideId,
                'status' => 'arrived',
            ]);

        // 5. Driver starts the trip
        $startResponse = $this->withHeader('Authorization', 'Bearer ' . $driverToken)
            ->postJson("/api/v1/rides/{$rideId}/start");

        $startResponse->assertStatus(200)
            ->assertJson([
                'id' => $rideId,
                'status' => 'started',
            ]);

        // 6. Driver completes the trip
        $completeResponse = $this->withHeader('Authorization', 'Bearer ' . $driverToken)
            ->postJson("/api/v1/rides/{$rideId}/complete");

        $completeResponse->assertStatus(200)
            ->assertJson([
                'id' => $rideId,
                'status' => 'completed',
            ]);

        // 7. Customer rates the driver
        $rateResponse = $this->withHeader('Authorization', 'Bearer ' . $customerToken)
            ->postJson("/api/v1/rides/{$rideId}/rate", [
                'rating' => 5,
                'review' => 'Excellent service!',
            ]);

        $rateResponse->assertStatus(201)
            ->assertJson([
                'rating' => 5,
                'review' => 'Excellent service!',
            ]);
    }
}
