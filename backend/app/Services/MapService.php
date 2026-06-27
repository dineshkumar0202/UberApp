<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class MapService
{
    public function calculateDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadius = 6371;

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) ** 2
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLon / 2) ** 2;

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return round($earthRadius * $c, 2);
    }

    public function getRoute(float $pickupLat, float $pickupLng, float $dropLat, float $dropLng): array
    {
        $apiKey = env('GOOGLE_MAPS_API_KEY');

        if ($apiKey) {
            try {
                $response = Http::get('https://maps.googleapis.com/maps/api/directions/json', [
                    'origin' => "$pickupLat,$pickupLng",
                    'destination' => "$dropLat,$dropLng",
                    'key' => $apiKey,
                ]);

                if ($response->successful()) {
                    $data = $response->json();
                    if (!empty($data['routes'])) {
                        $route = $data['routes'][0];
                        $leg = $route['legs'][0];

                        $distance = round($leg['distance']['value'] / 1000, 2); // meters to km
                        $duration = (int) ceil($leg['duration']['value'] / 60); // seconds to minutes
                        $overviewPolyline = $route['overview_polyline']['points'];

                        // Decode Google encoded polyline points to standard array for client ease
                        $polylinePoints = self::decodePolylinePoints($overviewPolyline);
                        $polyline = base64_encode(json_encode($polylinePoints));

                        return [
                            'distance_km' => $distance,
                            'duration_minutes' => $duration,
                            'polyline' => $polyline,
                        ];
                    }
                }
            } catch (\Exception $e) {
                // Fallback to simulated route if API call fails
            }
        }

        $distance = $this->calculateDistance($pickupLat, $pickupLng, $dropLat, $dropLng);
        // Realistic duration: average speed of 25 km/h, minimum 1 min
        $duration = (int) max(1, round(($distance / 25) * 60));

        // Create a simple route geometry (pickup, midpoint, drop) encoded in base64
        $polyline = base64_encode(json_encode([
            [$pickupLat, $pickupLng],
            [($pickupLat + $dropLat) / 2 + 0.001, ($pickupLng + $dropLng) / 2 - 0.001],
            [$dropLat, $dropLng]
        ]));

        return [
            'distance_km' => $distance,
            'duration_minutes' => $duration,
            'polyline' => $polyline,
        ];
    }

    public static function decodePolylinePoints(string $polyline): array
    {
        $points = [];
        $index = 0;
        $len = strlen($polyline);
        $lat = 0;
        $lng = 0;

        while ($index < $len) {
            $b = 0;
            $shift = 0;
            $result = 0;
            do {
                $b = ord($polyline[$index++]) - 63;
                $result |= ($b & 0x1f) << $shift;
                $shift += 5;
            } while ($b >= 0x20);
            $dlat = (($result & 1) ? ~($result >> 1) : ($result >> 1));
            $lat += $dlat;

            $shift = 0;
            $result = 0;
            do {
                $b = ord($polyline[$index++]) - 63;
                $result |= ($b & 0x1f) << $shift;
                $shift += 5;
            } while ($b >= 0x20);
            $dlng = (($result & 1) ? ~($result >> 1) : ($result >> 1));
            $lng += $dlng;

            $points[] = [round($lat * 1e-5, 6), round($lng * 1e-5, 6)];
        }

        return $points;
    }
}
