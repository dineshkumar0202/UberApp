<?php

namespace App\Services;

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class OtpService
{
    /**
     * Generate a new OTP and save it in the database.
     *
     * @param string $phone
     * @return string
     */
    public function sendOtp(string $phone): string
    {
        // Generate a 6-digit OTP code (always 123456 in local/testing environment, random in production)
        $otp = app()->environment('local', 'testing') ? '123456' : (string) rand(100000, 999999);

        // Store OTP in database with a 10-minute expiration
        DB::table('phone_verifications')->insert([
            'phone' => $phone,
            'otp' => $otp,
            'expires_at' => Carbon::now()->addMinutes(10),
            'created_at' => Carbon::now(),
            'updated_at' => Carbon::now(),
        ]);

        // Log OTP to standard laravel.log so developers can view it locally
        Log::info("OTP code sent to phone [{$phone}]: {$otp}");

        // If Twilio settings are configured in the environment, we could call Twilio API here
        $twilioSid = env('TWILIO_SID');
        $twilioAuthToken = env('TWILIO_AUTH_TOKEN');
        $twilioNumber = env('TWILIO_NUMBER');

        if ($twilioSid && $twilioAuthToken && $twilioNumber) {
            try {
                $client = new \Twilio\Rest\Client($twilioSid, $twilioAuthToken);
                $client->messages->create($phone, [
                    'from' => $twilioNumber,
                    'body' => "Your Ridoo verification code is: {$otp}"
                ]);
            } catch (\Exception $e) {
                Log::error("Failed to send OTP via Twilio: " . $e->getMessage());
            }
        }

        return $otp;
    }

    /**
     * Verify if the provided OTP matches and is not expired.
     *
     * @param string $phone
     * @param string $otp
     * @return bool
     */
    public function verifyOtp(string $phone, string $otp): bool
    {
        $verification = DB::table('phone_verifications')
            ->where('phone', $phone)
            ->where('otp', $otp)
            ->where('expires_at', '>', Carbon::now())
            ->orderBy('created_at', 'desc')
            ->first();

        if ($verification) {
            // Delete code after successful verification so it cannot be reused
            DB::table('phone_verifications')
                ->where('id', $verification->id)
                ->delete();

            return true;
        }

        return false;
    }
}
