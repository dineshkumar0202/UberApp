<?php

namespace App\Http\Controllers\Wallet;

use App\Http\Controllers\Controller;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    public function __construct(
        private readonly WalletService $walletService,
    ) {}

    public function show(Request $request): JsonResponse
    {
        return response()->json($this->walletService->getOrCreate($request->user()));
    }

    public function topUp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:1'],
        ]);

        $transaction = $this->walletService->credit(
            $request->user(),
            (float) $validated['amount'],
            'Wallet top-up',
        );

        return response()->json($transaction, 201);
    }

    public function transactions(Request $request): JsonResponse
    {
        $wallet = $this->walletService->getOrCreate($request->user());

        return response()->json(
            $wallet->transactions()->latest()->paginate(15),
        );
    }
}
