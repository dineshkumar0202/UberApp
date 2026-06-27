<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    public function send(User $user, string $title, string $body, string $type, array $data = []): Notification
    {
        return Notification::create([
            'user_id' => $user->id,
            'title' => $title,
            'body' => $body,
            'type' => $type,
            'data' => $data,
        ]);
    }

    public function sendPush(User $user, string $title, string $body, array $data = []): void
    {
        // Log in DB first
        $this->send($user, $title, $body, 'push', $data);

        $fcmToken = $user->fcm_token;
        if (!$fcmToken) {
            Log::info("FCM push skipped: User [{$user->id}] does not have an FCM token.");
            return;
        }

        $projectId = env('FIREBASE_PROJECT_ID');
        $credentialsPath = env('FIREBASE_CREDENTIALS');

        if (!$projectId || !$credentialsPath) {
            Log::info("FCM push mocked (Firebase credentials not configured): To User [{$user->id}] -> Title: '{$title}', Body: '{$body}'");
            return;
        }

        try {
            if (!file_exists($credentialsPath)) {
                Log::warning("FCM credentials file not found at: {$credentialsPath}");
                return;
            }

            $serviceAccount = json_decode(file_get_contents($credentialsPath), true);
            $accessToken = $this->getGoogleAccessToken($serviceAccount);

            if (!$accessToken) {
                Log::warning("FCM: Failed to obtain Google OAuth access token.");
                return;
            }

            $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

            // Ensure data key-value pairs are all strings
            $stringData = [];
            foreach ($data as $key => $value) {
                $stringData[(string)$key] = is_array($value) ? json_encode($value) : (string)$value;
            }

            $payload = [
                'message' => [
                    'token' => $fcmToken,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => $stringData,
                ]
            ];

            $response = Http::withToken($accessToken)->post($url, $payload);

            if ($response->failed()) {
                Log::error("FCM dispatch failed for User [{$user->id}]: " . $response->body());
            } else {
                Log::info("FCM push successfully sent to User [{$user->id}]");
            }
        } catch (\Exception $e) {
            Log::error("FCM dispatch exception for User [{$user->id}]: " . $e->getMessage());
        }
    }

    private function getGoogleAccessToken(array $serviceAccount): ?string
    {
        try {
            $privateKey = $serviceAccount['private_key'];
            $clientEmail = $serviceAccount['client_email'];

            $header = json_encode(['alg' => 'RS256', 'typ' => 'JWT']);
            $now = time();
            $claimSet = json_encode([
                'iss' => $clientEmail,
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => 'https://oauth2.googleapis.com/token',
                'exp' => $now + 3600,
                'iat' => $now
            ]);

            $base64UrlHeader = $this->base64UrlEncode($header);
            $base64UrlClaimSet = $this->base64UrlEncode($claimSet);

            $signature = '';
            if (!openssl_sign($base64UrlHeader . "." . $base64UrlClaimSet, $signature, $privateKey, OPENSSL_ALGO_SHA256)) {
                return null;
            }

            $base64UrlSignature = $this->base64UrlEncode($signature);
            $jwt = $base64UrlHeader . "." . $base64UrlClaimSet . "." . $base64UrlSignature;

            $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt
            ]);

            if ($response->successful()) {
                return $response->json('access_token');
            }
        } catch (\Exception $e) {
            Log::error("Failed to generate Google access token: " . $e->getMessage());
        }

        return null;
    }

    private function base64UrlEncode(string $data): string
    {
        return str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($data));
    }
}
