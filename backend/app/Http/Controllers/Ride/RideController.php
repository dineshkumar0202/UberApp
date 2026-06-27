<?php

namespace App\Http\Controllers\Ride;

use App\Http\Controllers\Controller;
use App\Models\Ride;
use App\Services\FareCalculationService;
use App\Services\PaymentService;
use App\Services\RideMatchingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RideController extends Controller
{
    public function __construct(
        private readonly RideMatchingService $rideMatchingService,
        private readonly FareCalculationService $fareCalculationService,
        private readonly PaymentService $paymentService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $rides = Ride::query()
            ->when($request->user()->isCustomer(), fn ($q) => $q->where('customer_id', $request->user()->id))
            ->when($request->user()->isDriver(), fn ($q) => $q->where('driver_id', $request->user()->driver?->id))
            ->latest()
            ->paginate(15);

        return response()->json($rides);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'pickup_address' => ['required', 'string'],
            'pickup_latitude' => ['required', 'numeric'],
            'pickup_longitude' => ['required', 'numeric'],
            'drop_address' => ['required', 'string'],
            'drop_latitude' => ['required', 'numeric'],
            'drop_longitude' => ['required', 'numeric'],
            'ride_type' => ['required', 'string'],
            'payment_method' => ['required', 'string'],
        ]);

        // Calculate route details from MapService
        $route = app(\App\Services\MapService::class)->getRoute(
            (float) $validated['pickup_latitude'],
            (float) $validated['pickup_longitude'],
            (float) $validated['drop_latitude'],
            (float) $validated['drop_longitude']
        );

        $ride = Ride::create([
            ...$validated,
            'customer_id' => $request->user()->id,
            'status' => Ride::STATUS_SEARCHING,
            'distance_km' => $route['distance_km'],
            'duration_minutes' => $route['duration_minutes'],
            'polyline' => $route['polyline'],
        ]);

        $drivers = $this->rideMatchingService->findNearbyDrivers(
            (float) $validated['pickup_latitude'],
            (float) $validated['pickup_longitude'],
        );

        $this->rideMatchingService->dispatchRideRequest($ride, $drivers);

        return response()->json($ride, 201);
    }

    public function show(Ride $ride): JsonResponse
    {
        return response()->json($ride->load(['driver.user', 'driver.vehicle', 'payment', 'rating']));
    }

    public function accept(Request $request, Ride $ride): JsonResponse
    {
        $driver = $request->user()->driver;

        $ride->update([
            'driver_id' => $driver->id,
            'status' => Ride::STATUS_ACCEPTED,
        ]);

        $ride = $ride->fresh();
        app(\App\Services\SocketService::class)->notifyCustomer($ride, 'accepted', $ride->load(['driver.user', 'driver.vehicle'])->toArray());

        return response()->json($ride);
    }

    public function reject(Request $request, Ride $ride): JsonResponse
    {
        return response()->json(['message' => 'Ride rejected.']);
    }

    public function start(Ride $ride): JsonResponse
    {
        $ride->update([
            'status' => Ride::STATUS_STARTED,
            'started_at' => now(),
        ]);

        app(\App\Services\SocketService::class)->notifyCustomer($ride, 'started', $ride->toArray());

        return response()->json($ride);
    }

    public function complete(Request $request, Ride $ride): JsonResponse
    {
        $fare = $this->fareCalculationService->calculate($ride);

        $ride->update([
            ...$fare,
            'status' => Ride::STATUS_COMPLETED,
            'completed_at' => now(),
        ]);

        if ($ride->payment_method !== 'cash') {
            $this->paymentService->process($ride, $request->user(), $ride->payment_method);
        }

        $ride = $ride->fresh();
        app(\App\Services\SocketService::class)->notifyCustomer($ride, 'completed', $ride->toArray());

        return response()->json($ride);
    }

    public function cancel(Request $request, Ride $ride): JsonResponse
    {
        $validated = $request->validate([
            'reason' => ['nullable', 'string'],
        ]);

        $ride->update([
            'status' => Ride::STATUS_CANCELLED,
            'cancelled_at' => now(),
            'cancellation_reason' => $validated['reason'] ?? null,
        ]);

        app(\App\Services\SocketService::class)->notifyCustomer($ride, 'cancelled', $ride->toArray());

        return response()->json($ride);
    }

    public function rate(Request $request, Ride $ride): JsonResponse
    {
        $validated = $request->validate([
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'review' => ['nullable', 'string'],
        ]);

        $rating = $ride->rating()->create([
            'rated_by' => $request->user()->id,
            'rated_to' => $ride->driver->user_id,
            ...$validated,
        ]);

        return response()->json($rating, 201);
    }

    public function arrive(Request $request, Ride $ride): JsonResponse
    {
        $ride->update([
            'status' => Ride::STATUS_ARRIVED,
        ]);

        app(\App\Services\SocketService::class)->notifyCustomer($ride, 'arrived', $ride->toArray());

        return response()->json($ride);
    }
}
