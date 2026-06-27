<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;

class WalletService
{
    public function getOrCreate(User $user): Wallet
    {
        return Wallet::firstOrCreate(
            ['user_id' => $user->id],
            ['balance' => 0, 'currency' => 'INR'],
        );
    }

    public function credit(User $user, float $amount, string $description, ?int $rideId = null): Transaction
    {
        $wallet = $this->getOrCreate($user);
        $wallet->increment('balance', $amount);

        return Transaction::create([
            'wallet_id' => $wallet->id,
            'ride_id' => $rideId,
            'type' => Transaction::TYPE_CREDIT,
            'amount' => $amount,
            'description' => $description,
            'balance_after' => $wallet->fresh()->balance,
        ]);
    }

    public function debit(User $user, float $amount, string $description, ?int $rideId = null): Transaction
    {
        $wallet = $this->getOrCreate($user);

        if ($wallet->balance < $amount) {
            throw new \RuntimeException('Insufficient wallet balance.');
        }

        $wallet->decrement('balance', $amount);

        return Transaction::create([
            'wallet_id' => $wallet->id,
            'ride_id' => $rideId,
            'type' => Transaction::TYPE_DEBIT,
            'amount' => $amount,
            'description' => $description,
            'balance_after' => $wallet->fresh()->balance,
        ]);
    }
}
