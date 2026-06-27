<?php

namespace App\Http\Controllers\Payment;

use App\Http\Controllers\Controller;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PaymentGatewayController extends Controller
{
    public function __construct(
        private readonly WalletService $walletService,
    ) {}

    public function getWallet(Request $request): JsonResponse
    {
        $user = $request->user();
        $wallet = $this->walletService->getOrCreate($user);
        
        $transactions = $wallet->transactions()
            ->with('ride')
            ->latest()
            ->take(15)
            ->get();

        return response()->json([
            'balance' => (float) $wallet->balance,
            'currency' => $wallet->currency,
            'transactions' => $transactions,
        ]);
    }

    public function createStripeIntent(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:10'],
        ]);

        // Mock Stripe client secret generation
        $clientSecret = 'pi_' . Str::random(24) . '_secret_' . Str::random(10);

        return response()->json([
            'client_secret' => $clientSecret,
            'amount' => $validated['amount'],
            'currency' => 'INR',
        ]);
    }

    public function confirmStripePayment(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'client_secret' => ['required', 'string'],
            'amount' => ['required', 'numeric'],
        ]);

        $user = $request->user();
        $this->walletService->credit(
            $user,
            (float) $validated['amount'],
            "Wallet top-up (Stripe)"
        );

        return response()->json([
            'success' => true,
            'message' => 'Wallet topped up successfully via Stripe.',
        ]);
    }

    public function createRazorpayOrder(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:10'],
        ]);

        $orderId = 'order_' . Str::random(18);

        return response()->json([
            'order_id' => $orderId,
            'amount' => $validated['amount'] * 100, // Razorpay works in paise
            'currency' => 'INR',
        ]);
    }

    public function confirmRazorpayPayment(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'order_id' => ['required', 'string'],
            'payment_id' => ['required', 'string'],
            'amount' => ['required', 'numeric'],
        ]);

        $user = $request->user();
        $this->walletService->credit(
            $user,
            (float) $validated['amount'],
            "Wallet top-up (Razorpay)"
        );

        return response()->json([
            'success' => true,
            'message' => 'Wallet topped up successfully via Razorpay.',
        ]);
    }
}
