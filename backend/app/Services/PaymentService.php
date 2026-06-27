<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\Ride;
use App\Models\User;

class PaymentService
{
    public function __construct(
        private readonly WalletService $walletService,
    ) {}

    public function process(Ride $ride, User $user, string $method, ?string $transactionId = null): Payment
    {
        $payment = Payment::create([
            'ride_id' => $ride->id,
            'user_id' => $user->id,
            'amount' => $ride->total_fare,
            'method' => $method,
            'status' => Payment::STATUS_PENDING,
            'transaction_id' => $transactionId,
        ]);

        if ($method === 'wallet') {
            $this->walletService->debit($user, (float) $ride->total_fare, "Ride #{$ride->id}", $ride->id);
        }

        $payment->update([
            'status' => Payment::STATUS_COMPLETED,
            'paid_at' => now(),
        ]);

        $ride->update(['payment_status' => Payment::STATUS_COMPLETED]);

        return $payment->fresh();
    }
}
