<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Driver extends Model
{
    protected $fillable = [
        'user_id',
        'license_number',
        'license_expiry',
        'is_online',
        'is_approved',
        'current_latitude',
        'current_longitude',
        'rating',
        'total_rides',
    ];

    protected function casts(): array
    {
        return [
            'license_expiry' => 'date',
            'is_online' => 'boolean',
            'is_approved' => 'boolean',
            'current_latitude' => 'decimal:8',
            'current_longitude' => 'decimal:8',
            'rating' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function vehicle(): HasOne
    {
        return $this->hasOne(Vehicle::class);
    }

    public function rides(): HasMany
    {
        return $this->hasMany(Ride::class);
    }
}
