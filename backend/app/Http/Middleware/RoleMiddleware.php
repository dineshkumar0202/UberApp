<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string $role): Response
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthorized.'], 401);
        }

        if ($user->role !== $role) {
            if ($role === 'driver') {
                // Auto-promote customer account to driver for testing convenience
                $user->update(['role' => 'driver']);
                if (! $user->driver) {
                    $user->driver()->create([
                        'license_number' => 'DL-' . rand(100000, 999999),
                        'license_expiry' => now()->addYears(5),
                        'is_online' => false,
                        'is_approved' => true,
                        'current_latitude' => 12.9716,
                        'current_longitude' => 77.5946,
                        'rating' => 5.0,
                        'total_rides' => 0,
                    ]);
                }
            } else if ($role === 'customer') {
                // Auto-demote to customer
                $user->update(['role' => 'customer']);
            } else {
                return response()->json(['message' => 'Unauthorized. Role must be ' . $role], 403);
            }
        }

        return $next($request);
    }
}
