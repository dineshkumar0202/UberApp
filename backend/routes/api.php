<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Customer\CustomerController;
use App\Http\Controllers\Driver\DriverController;
use App\Http\Controllers\Notification\NotificationController;
use App\Http\Controllers\Payment\PaymentController;
use App\Http\Controllers\Payment\PaymentGatewayController;
use App\Http\Controllers\Ride\RideController;
use App\Http\Controllers\Support\SupportController;
use App\Http\Controllers\Wallet\WalletController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::prefix('auth')->group(function (): void {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);
        Route::post('otp/send', [AuthController::class, 'sendOtp']);
        Route::post('otp/verify', [AuthController::class, 'verifyOtp']);
        Route::post('forgot-password', [AuthController::class, 'forgotPassword']);
    });

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::post('auth/logout', [AuthController::class, 'logout']);

        Route::prefix('customer')->middleware('role:customer')->group(function (): void {
            Route::get('profile', [CustomerController::class, 'profile']);
            Route::put('profile', [CustomerController::class, 'updateProfile']);
            Route::post('emergency-contacts', [CustomerController::class, 'storeEmergencyContact']);
        });

        Route::prefix('driver')->middleware('role:driver')->group(function (): void {
            Route::get('profile', [DriverController::class, 'profile']);
            Route::put('profile', [DriverController::class, 'updateProfile']);
            Route::post('online', [DriverController::class, 'goOnline']);
            Route::post('offline', [DriverController::class, 'goOffline']);
            Route::post('location', [DriverController::class, 'updateLocation']);
            Route::post('documents', [DriverController::class, 'uploadDocuments']);
            Route::get('rides/pending', [DriverController::class, 'getPendingRides']);
        });

        Route::prefix('rides')->group(function (): void {
            Route::get('/', [RideController::class, 'index']);
            Route::post('/', [RideController::class, 'store'])->middleware('role:customer');
            Route::get('{ride}', [RideController::class, 'show']);
            Route::post('{ride}/accept', [RideController::class, 'accept'])->middleware('role:driver');
            Route::post('{ride}/reject', [RideController::class, 'reject'])->middleware('role:driver');
            Route::post('{ride}/arrive', [RideController::class, 'arrive'])->middleware('role:driver');
            Route::post('{ride}/start', [RideController::class, 'start'])->middleware('role:driver');
            Route::post('{ride}/complete', [RideController::class, 'complete'])->middleware('role:driver');
            Route::post('{ride}/cancel', [RideController::class, 'cancel']);
            Route::post('{ride}/rate', [RideController::class, 'rate'])->middleware('role:customer');
        });

        Route::prefix('wallet')->group(function (): void {
            Route::get('/', [WalletController::class, 'show']);
            Route::post('top-up', [WalletController::class, 'topUp']);
            Route::get('transactions', [WalletController::class, 'transactions']);
            Route::get('dashboard', [PaymentGatewayController::class, 'getWallet']);
        });

        Route::prefix('payment/stripe')->group(function (): void {
            Route::post('intent', [PaymentGatewayController::class, 'createStripeIntent']);
            Route::post('confirm', [PaymentGatewayController::class, 'confirmStripePayment']);
        });

        Route::prefix('payment/razorpay')->group(function (): void {
            Route::post('order', [PaymentGatewayController::class, 'createRazorpayOrder']);
            Route::post('confirm', [PaymentGatewayController::class, 'confirmRazorpayPayment']);
        });

        Route::prefix('payments')->group(function (): void {
            Route::post('/', [PaymentController::class, 'process']);
            Route::get('{payment}', [PaymentController::class, 'show']);
        });

        Route::prefix('notifications')->group(function (): void {
            Route::get('/', [NotificationController::class, 'index']);
            Route::post('fcm-token', [NotificationController::class, 'updateFcmToken']);
            Route::post('{notification}/read', [NotificationController::class, 'markAsRead']);
        });

        Route::prefix('support')->group(function (): void {
            Route::get('tickets', [SupportController::class, 'index']);
            Route::post('tickets', [SupportController::class, 'store']);
            Route::get('tickets/{ticket}', [SupportController::class, 'show']);
        });
    });
});
