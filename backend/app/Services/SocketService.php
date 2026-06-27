<?php

namespace App\Services;

use App\Events\DriverLocationUpdated;
use App\Events\RideRequested;
use App\Events\RideStatusUpdated;
use App\Models\Driver;
use App\Models\Ride;

class SocketService
{
    public function broadcastDriverLocation(Driver $driver, float $latitude, float $longitude): void
    {
        // Find the active ride for this driver to broadcast on the ride's channel
        $activeRide = Ride::where('driver_id', $driver->id)
            ->whereIn('status', [Ride::STATUS_ACCEPTED, Ride::STATUS_ARRIVED, Ride::STATUS_STARTED])
            ->first();

        if ($activeRide) {
            broadcast(new DriverLocationUpdated($driver, $latitude, $longitude, $activeRide->id));
        }
    }

    public function notifyDriver(Driver $driver, string $event, array $payload): void
    {
        if ($event === 'ride.request') {
            $ride = Ride::find($payload['ride_id']);
            if ($ride) {
                broadcast(new RideRequested($driver, $ride, $payload));
            }
        }
    }

    public function notifyCustomer(Ride $ride, string $event, array $payload): void
    {
        broadcast(new RideStatusUpdated($ride, $event, $payload));
    }
}
