<?php

namespace App\Http\Controllers\Support;

use App\Http\Controllers\Controller;
use App\Models\SupportTicket;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SupportController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        return response()->json(
            SupportTicket::where('user_id', $request->user()->id)
                ->latest()
                ->paginate(15),
        );
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'subject' => ['required', 'string'],
            'message' => ['required', 'string'],
            'ride_id' => ['nullable', 'exists:rides,id'],
            'priority' => ['nullable', 'string'],
        ]);

        $ticket = SupportTicket::create([
            ...$validated,
            'user_id' => $request->user()->id,
            'status' => SupportTicket::STATUS_OPEN,
        ]);

        return response()->json($ticket, 201);
    }

    public function show(Request $request, SupportTicket $ticket): JsonResponse
    {
        abort_unless($ticket->user_id === $request->user()->id, 403);

        return response()->json($ticket);
    }
}
