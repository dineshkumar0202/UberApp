<?php

namespace App\Http\Controllers\Driver;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DriverController extends Controller
{
    public function profile(Request $request): JsonResponse
    {
        return response()->json(
            $request->user()->load(['driver.vehicle']),
        );
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'license_number' => ['sometimes', 'string'],
        ]);

        $request->user()->update(collect($validated)->only('name')->toArray());

        if ($request->user()->driver && isset($validated['license_number'])) {
            $request->user()->driver->update([
                'license_number' => $validated['license_number'],
            ]);
        }

        return response()->json($request->user()->load('driver'));
    }

    public function goOnline(Request $request): JsonResponse
    {
        $request->user()->driver?->update([
            'is_online' => true,
            'is_approved' => true,
        ]);

        return response()->json(['message' => 'You are now online.']);
    }

    public function goOffline(Request $request): JsonResponse
    {
        $request->user()->driver?->update(['is_online' => false]);

        return response()->json(['message' => 'You are now offline.']);
    }

    public function updateLocation(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'latitude' => ['required', 'numeric'],
            'longitude' => ['required', 'numeric'],
        ]);

        $driver = $request->user()->driver;
        if ($driver) {
            $driver->update([
                'current_latitude' => $validated['latitude'],
                'current_longitude' => $validated['longitude'],
            ]);

            app(\App\Services\SocketService::class)->broadcastDriverLocation(
                $driver,
                (float) $validated['latitude'],
                (float) $validated['longitude']
            );
        }

        return response()->json(['message' => 'Location updated.']);
    }

    public function uploadDocuments(Request $request): JsonResponse
    {
        $request->validate([
            'license' => ['required', 'file'],
            'vehicle_registration' => ['required', 'file'],
        ]);

        return response()->json(['message' => 'Documents uploaded for review.']);
    }

    public function getPendingRides(Request $request): JsonResponse
    {
        $driver = $request->user()->driver;
        if (!$driver || !$driver->is_online || !$driver->current_latitude || !$driver->current_longitude) {
            return response()->json([]);
        }

        // Find rides in searching state and check distance to driver
        $rides = \App\Models\Ride::where('status', \App\Models\Ride::STATUS_SEARCHING)
            ->get()
            ->filter(function (\App\Models\Ride $ride) use ($driver) {
                $distance = app(\App\Services\MapService::class)->calculateDistance(
                    (float) $driver->current_latitude,
                    (float) $driver->current_longitude,
                    (float) $ride->pickup_latitude,
                    (float) $ride->pickup_longitude
                );
                return $distance <= 5.0; // 5 km radius
            })
            ->values();

        return response()->json($rides);
    }
}
