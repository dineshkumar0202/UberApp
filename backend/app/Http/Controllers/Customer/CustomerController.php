<?php

namespace App\Http\Controllers\Customer;

use App\Http\Controllers\Controller;
use App\Models\EmergencyContact;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function profile(Request $request): JsonResponse
    {
        return response()->json(
            $request->user()->load(['wallet', 'emergencyContacts']),
        );
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'email', 'unique:users,email,'.$request->user()->id],
            'avatar' => ['sometimes', 'string'],
        ]);

        $request->user()->update($validated);

        return response()->json($request->user());
    }

    public function storeEmergencyContact(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string'],
            'phone' => ['required', 'string'],
            'relationship' => ['nullable', 'string'],
        ]);

        $contact = EmergencyContact::create([
            ...$validated,
            'user_id' => $request->user()->id,
        ]);

        return response()->json($contact, 201);
    }
}
