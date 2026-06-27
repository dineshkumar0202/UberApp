<?php

use Illuminate\Support\Facades\Route;
use App\Models\User;
use App\Models\Driver;
use App\Models\Ride;

Route::get('/', function () {
    return redirect('/admin-simple');
});

Route::get('/admin-simple', function () {
    $users = User::latest()->get();
    $drivers = Driver::with(['user', 'vehicle'])->latest()->get();
    $rides = Ride::with(['customer', 'driver.user'])->latest()->get();

    return view('admin_simple', compact('users', 'drivers', 'rides'));
});

Route::post('/admin-simple/driver/{id}/approve', function ($id) {
    $driver = Driver::findOrFail($id);
    $driver->update(['is_approved' => true]);
    return back()->with('success', 'Driver approved successfully!');
});
