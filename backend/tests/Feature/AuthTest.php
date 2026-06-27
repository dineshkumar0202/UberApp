<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_request_otp(): void
    {
        $response = $this->postJson('/api/v1/auth/otp/send', [
            'phone' => '+919876543210'
        ]);

        $response->assertStatus(200)
            ->assertJson(['message' => 'OTP sent successfully.']);

        $this->assertDatabaseHas('phone_verifications', [
            'phone' => '+919876543210',
            'otp' => '123456' // In local/testing env it defaults to 123456
        ]);
    }

    public function test_user_can_verify_otp_for_unregistered_number(): void
    {
        // First send OTP
        $this->postJson('/api/v1/auth/otp/send', ['phone' => '+919876543210']);

        // Verify OTP
        $response = $this->postJson('/api/v1/auth/otp/verify', [
            'phone' => '+919876543210',
            'otp' => '123456'
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'registered' => false,
                'phone' => '+919876543210'
            ]);

        // Code should be deleted after verify
        $this->assertDatabaseMissing('phone_verifications', [
            'phone' => '+919876543210'
        ]);
    }

    public function test_user_can_verify_otp_and_login_if_registered(): void
    {
        $user = User::create([
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'phone' => '+919876543210',
            'password' => Hash::make('password123'),
            'role' => 'customer',
        ]);

        // Send OTP
        $this->postJson('/api/v1/auth/otp/send', ['phone' => '+919876543210']);

        // Verify OTP
        $response = $this->postJson('/api/v1/auth/otp/verify', [
            'phone' => '+919876543210',
            'otp' => '123456',
            'fcm_token' => 'sample_fcm_token'
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'registered' => true,
                'user' => [
                    'phone' => '+919876543210',
                    'fcm_token' => 'sample_fcm_token'
                ]
            ])
            ->assertJsonStructure(['token', 'user']);

        $user->refresh();
        $this->assertNotNull($user->phone_verified_at);
        $this->assertEquals('sample_fcm_token', $user->fcm_token);
    }

    public function test_cannot_verify_invalid_otp(): void
    {
        $this->postJson('/api/v1/auth/otp/send', ['phone' => '+919876543210']);

        $response = $this->postJson('/api/v1/auth/otp/verify', [
            'phone' => '+919876543210',
            'otp' => '999999' // Invalid code
        ]);

        $response->assertStatus(422)
            ->assertJson(['message' => 'Invalid or expired OTP.']);
    }

    public function test_user_can_register(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Jane Doe',
            'email' => 'jane@example.com',
            'phone' => '+919876543211',
            'password' => 'SecurePassword123!',
            'role' => 'customer',
            'fcm_token' => 'another_fcm_token'
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'registered' => true,
                'user' => [
                    'phone' => '+919876543211',
                    'name' => 'Jane Doe',
                    'fcm_token' => 'another_fcm_token'
                ]
            ])
            ->assertJsonStructure(['token', 'user']);

        $this->assertDatabaseHas('users', [
            'phone' => '+919876543211',
            'fcm_token' => 'another_fcm_token'
        ]);
    }

    public function test_user_can_login(): void
    {
        $user = User::create([
            'name' => 'John Login',
            'email' => 'login@example.com',
            'phone' => '+919876543212',
            'password' => Hash::make('password123'),
            'role' => 'driver',
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'phone' => '+919876543212',
            'password' => 'password123',
            'fcm_token' => 'login_fcm_token'
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'registered' => true,
                'user' => [
                    'phone' => '+919876543212',
                    'fcm_token' => 'login_fcm_token'
                ]
            ])
            ->assertJsonStructure(['token', 'user']);
    }

    public function test_authenticated_user_can_update_fcm_token(): void
    {
        $user = User::create([
            'name' => 'Token User',
            'email' => 'token@example.com',
            'phone' => '+919876543213',
            'password' => Hash::make('password123'),
            'role' => 'customer',
        ]);

        $token = $user->createToken('test')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/v1/notifications/fcm-token', [
                'fcm_token' => 'updated_fcm_token_value'
            ]);

        $response->assertStatus(200)
            ->assertJson(['message' => 'FCM token updated successfully.']);

        $user->refresh();
        $this->assertEquals('updated_fcm_token_value', $user->fcm_token);
    }
}
