<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Transaction extends Model
{
    public const TYPE_CREDIT = 'credit';

    public const TYPE_DEBIT = 'debit';

    protected $fillable = [
        'wallet_id',
        'ride_id',
        'type',
        'amount',
        'description',
        'reference',
        'balance_after',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'balance_after' => 'decimal:2',
        ];
    }

    public function wallet(): BelongsTo
    {
        return $this->belongsTo(Wallet::class);
    }

    public function ride(): BelongsTo
    {
        return $this->belongsTo(Ride::class);
    }
}
