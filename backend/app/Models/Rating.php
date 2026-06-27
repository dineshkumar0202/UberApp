<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Rating extends Model
{
    protected $fillable = [
        'ride_id',
        'rated_by',
        'rated_to',
        'rating',
        'review',
    ];

    public function ride(): BelongsTo
    {
        return $this->belongsTo(Ride::class);
    }

    public function ratedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rated_by');
    }

    public function ratedTo(): BelongsTo
    {
        return $this->belongsTo(User::class, 'rated_to');
    }
}
