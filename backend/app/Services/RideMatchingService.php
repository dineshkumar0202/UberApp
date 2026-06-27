<?php

namespace App\Services;

use App\Models\Driver;
use App\Models\Ride;
use Illuminate\Support\Collection;

class RideMatchingService
{
    public function __construct(
        private readonly MapService $mapService,
        private readonly SocketService $socketService,
    ) {}

    public function findNearbyDrivers(float $latitude, float $longitude, float $radiusKm = 5): Collection
    {
        return Driver::query()
            ->where('is_online', true)
            ->where('is_approved', true)
            ->whereNotNull('current_latitude')
            ->whereNotNull('current_longitude')
            ->get()
            ->filter(function (Driver $driver) use ($latitude, $longitude, $radiusKm) {
                $distance = $this->mapService->calculateDistance(
                    $latitude,
                    $longitude,
                    (float) $driver->current_latitude,
                    (float) $driver->current_longitude,
                );

                return $distance <= $radiusKm;
            })
            ->sortBy(function (Driver $driver) use ($latitude, $longitude) {
                return $this->mapService->calculateDistance(
                    $latitude,
                    $longitude,
                    (float) $driver->current_latitude,
                    (float) $driver->current_longitude,
                );
            })
            ->values();
    }

    public function dispatchRideRequest(Ride $ride, Collection $drivers): void
    {
        foreach ($drivers as $driver) {
            $this->socketService->notifyDriver($driver, 'ride.request', [
                'ride_id' => $ride->id,
                'pickup' => [
                    'address' => $ride->pickup_address,
                    'latitude' => $ride->pickup_latitude,
                    'longitude' => $ride->pickup_longitude,
                ],
                'drop' => [
                    'address' => $ride->drop_address,
                    'latitude' => $ride->drop_latitude,
                    'longitude' => $ride->drop_longitude,
                ],
                'ride_type' => $ride->ride_type,
            ]);
        }
    }
}
