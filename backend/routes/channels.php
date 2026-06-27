<?php

use App\Models\Ride;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('ride.{rideId}', function ($user, int $rideId) {
    $ride = Ride::find($rideId);

    return $ride && ($ride->customer_id === $user->id || $ride->driver?->user_id === $user->id);
});

Broadcast::channel('driver.{driverId}', function ($user, int $driverId) {
    return $user->driver?->id === $driverId;
});
