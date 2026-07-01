<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    protected OtpService $otpService;

    public function __construct(OtpService $otpService)
    {
        $this->otpService = $otpService;
    }

    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'unique:users,email'],
            'phone' => ['required', 'string', 'unique:users,phone'],
            'password' => ['required', Password::defaults()],
            'role' => ['required', 'in:customer,driver'],
            'fcm_token' => ['nullable', 'string'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'] ?? null,
            'phone' => $validated['phone'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
            'fcm_token' => $validated['fcm_token'] ?? null,
            'phone_verified_at' => now(), // Assume email was verified
        ]);

        // Always create a wallet for the user
        $user->wallet()->create([
            'balance' => 0.00,
            'currency' => 'INR',
        ]);

        // If the user registered as a driver, also store their driver record
        if ($user->role === 'driver') {
            $user->driver()->create([
                'license_number' => '',
                'license_expiry' => now()->addYears(5),
                'is_online' => false,
                'is_approved' => false,
                'current_latitude' => 12.9716,
                'current_longitude' => 77.5946,
                'rating' => 5.0,
                'total_rides' => 0,
            ]);
        }

        $token = $user->createToken('auth')->plainTextToken;
        $user->load(['wallet', 'driver']);

        return response()->json([
            'user' => $user,
            'token' => $token,
            'registered' => true,
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['nullable', 'email'],
            'phone' => ['nullable', 'string'],
            'password' => ['required', 'string'],
            'fcm_token' => ['nullable', 'string'],
        ]);

        $user = null;
        if (!empty($validated['email'])) {
            $user = User::where('email', $validated['email'])->first();
        } elseif (!empty($validated['phone'])) {
            $user = User::where('phone', $validated['phone'])->first();
        } else {
            return response()->json(['message' => 'Please provide an email or phone number.'], 422);
        }

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            return response()->json(['message' => 'Invalid credentials.'], 401);
        }

        $updateData = [];
        if (!empty($validated['fcm_token'])) {
            $updateData['fcm_token'] = $validated['fcm_token'];
        }
        if (empty($user->phone_verified_at)) {
            $updateData['phone_verified_at'] = now();
        }

        if (!empty($updateData)) {
            $user->update($updateData);
        }

        $user->load(['wallet', 'driver']);
        $token = $user->createToken('auth')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
            'registered' => true,
        ]);
    }

    public function sendOtp(Request $request): JsonResponse
    {
        $request->validate(['phone' => ['required', 'string']]);

        $this->otpService->sendOtp($request->input('phone'));

        return response()->json(['message' => 'OTP sent successfully.']);
    }

    public function verifyOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'phone' => ['required', 'string'],
            'otp' => ['required', 'string'],
            'fcm_token' => ['nullable', 'string'],
        ]);

        $isValid = $this->otpService->verifyOtp($validated['phone'], $validated['otp']);

        if (! $isValid) {
            return response()->json(['message' => 'Invalid or expired OTP.'], 422);
        }

        $user = User::where('phone', $validated['phone'])->first();

        if (! $user) {
            // New user, OTP is verified but registration needs to be completed
            return response()->json([
                'message' => 'OTP verified successfully.',
                'registered' => false,
                'phone' => $validated['phone'],
            ]);
        }

        // Existing user, log them in
        $updateData = ['phone_verified_at' => now()];
        if (!empty($validated['fcm_token'])) {
            $updateData['fcm_token'] = $validated['fcm_token'];
        }
        $user->update($updateData);

        $user->load(['wallet', 'driver']);
        $token = $user->createToken('auth')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
            'registered' => true,
        ]);
    }

    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate(['phone' => ['required', 'string']]);

        // Send OTP for forgot password verification
        $this->otpService->sendOtp($request->input('phone'));

        return response()->json(['message' => 'Verification OTP sent.']);
    }

    public function logout(Request $request): JsonResponse
    {
        // Remove FCM token on logout to prevent notifications to logged out devices
        $user = $request->user();
        if ($user) {
            $user->update(['fcm_token' => null]);
            $user->currentAccessToken()->delete();
        }

        return response()->json(['message' => 'Logged out successfully.']);
    }
}
