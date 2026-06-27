<?php

namespace App\Http\Controllers\Payment;

use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Ride;
use App\Services\PaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function __construct(
        private readonly PaymentService $paymentService,
    ) {}

    public function process(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'ride_id' => ['required', 'exists:rides,id'],
            'method' => ['required', 'string'],
            'transaction_id' => ['nullable', 'string'],
        ]);

        $ride = Ride::findOrFail($validated['ride_id']);
        $payment = $this->paymentService->process(
            $ride,
            $request->user(),
            $validated['method'],
            $validated['transaction_id'] ?? null,
        );

        return response()->json($payment, 201);
    }

    public function show(Payment $payment): JsonResponse
    {
        return response()->json($payment->load('ride'));
    }
}
