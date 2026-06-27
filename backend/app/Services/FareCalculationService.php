<?php

namespace App\Services;

use App\Models\Coupon;
use App\Models\Ride;

class FareCalculationService
{
    private const BASE_FARE = 25.00;

    private const PER_KM_RATE = 12.00;

    private const PER_MINUTE_RATE = 2.00;

    public function calculate(Ride $ride, ?Coupon $coupon = null): array
    {
        $distanceFare = ($ride->distance_km ?? 0) * self::PER_KM_RATE;
        $durationFare = ($ride->duration_minutes ?? 0) * self::PER_MINUTE_RATE;
        $baseFare = self::BASE_FARE + $distanceFare + $durationFare;
        $surgeMultiplier = $ride->surge_multiplier ?? 1.0;
        $subtotal = $baseFare * $surgeMultiplier;
        $discount = $coupon ? $this->applyCoupon($subtotal, $coupon) : 0;
        $total = max(0, $subtotal - $discount);

        return [
            'base_fare' => round($baseFare, 2),
            'surge_multiplier' => $surgeMultiplier,
            'discount_amount' => round($discount, 2),
            'total_fare' => round($total, 2),
        ];
    }

    private function applyCoupon(float $amount, Coupon $coupon): float
    {
        if (! $coupon->isValid()) {
            return 0;
        }

        if ($coupon->min_fare && $amount < $coupon->min_fare) {
            return 0;
        }

        return match ($coupon->discount_type) {
            'percentage' => $amount * ($coupon->discount_value / 100),
            'fixed' => min($coupon->discount_value, $amount),
            default => 0,
        };
    }
}
