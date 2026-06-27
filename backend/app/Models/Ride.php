<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Ride extends Model
{
    public const STATUS_PENDING = 'pending';

    public const STATUS_SEARCHING = 'searching';

    public const STATUS_ACCEPTED = 'accepted';

    public const STATUS_ARRIVED = 'arrived';

    public const STATUS_STARTED = 'started';

    public const STATUS_COMPLETED = 'completed';

    public const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'customer_id',
        'driver_id',
        'pickup_address',
        'pickup_latitude',
        'pickup_longitude',
        'drop_address',
        'drop_latitude',
        'drop_longitude',
        'ride_type',
        'status',
        'distance_km',
        'duration_minutes',
        'base_fare',
        'surge_multiplier',
        'discount_amount',
        'total_fare',
        'payment_method',
        'payment_status',
        'started_at',
        'completed_at',
        'cancelled_at',
        'cancellation_reason',
    ];

    protected function casts(): array
    {
        return [
            'pickup_latitude' => 'decimal:8',
            'pickup_longitude' => 'decimal:8',
            'drop_latitude' => 'decimal:8',
            'drop_longitude' => 'decimal:8',
            'distance_km' => 'decimal:2',
            'base_fare' => 'decimal:2',
            'surge_multiplier' => 'decimal:2',
            'discount_amount' => 'decimal:2',
            'total_fare' => 'decimal:2',
            'started_at' => 'datetime',
            'completed_at' => 'datetime',
            'cancelled_at' => 'datetime',
        ];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function driver(): BelongsTo
    {
        return $this->belongsTo(Driver::class);
    }

    public function payment(): HasOne
    {
        return $this->hasOne(Payment::class);
    }

    public function rating(): HasOne
    {
        return $this->hasOne(Rating::class);
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }
}
