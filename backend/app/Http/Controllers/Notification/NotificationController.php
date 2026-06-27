<?php

namespace App\Http\Controllers\Notification;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        return response()->json(
            Notification::where('user_id', $request->user()->id)
                ->latest()
                ->paginate(20),
        );
    }

    public function markAsRead(Request $request, Notification $notification): JsonResponse
    {
        abort_unless($notification->user_id === $request->user()->id, 403);

        $notification->update(['read_at' => now()]);

        return response()->json($notification);
    }

    public function updateFcmToken(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'fcm_token' => ['required', 'string'],
        ]);

        $request->user()->update([
            'fcm_token' => $validated['fcm_token']
        ]);

        return response()->json([
            'message' => 'FCM token updated successfully.'
        ]);
    }
}
