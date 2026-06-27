<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('drivers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('license_number')->nullable();
            $table->date('license_expiry')->nullable();
            $table->boolean('is_online')->default(false);
            $table->boolean('is_approved')->default(false);
            $table->decimal('current_latitude', 10, 8)->nullable();
            $table->decimal('current_longitude', 11, 8)->nullable();
            $table->decimal('rating', 3, 2)->default(5.00);
            $table->unsignedInteger('total_rides')->default(0);
            $table->timestamps();
        });

        Schema::create('vehicles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('driver_id')->constrained()->cascadeOnDelete();
            $table->string('make');
            $table->string('model');
            $table->unsignedSmallInteger('year');
            $table->string('color');
            $table->string('plate_number')->unique();
            $table->string('vehicle_type');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('rides', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('driver_id')->nullable()->constrained()->nullOnDelete();
            $table->string('pickup_address');
            $table->decimal('pickup_latitude', 10, 8);
            $table->decimal('pickup_longitude', 11, 8);
            $table->string('drop_address');
            $table->decimal('drop_latitude', 10, 8);
            $table->decimal('drop_longitude', 11, 8);
            $table->string('ride_type');
            $table->string('status')->default('pending');
            $table->decimal('distance_km', 8, 2)->nullable();
            $table->unsignedInteger('duration_minutes')->nullable();
            $table->decimal('base_fare', 10, 2)->nullable();
            $table->decimal('surge_multiplier', 4, 2)->default(1.00);
            $table->decimal('discount_amount', 10, 2)->default(0);
            $table->decimal('total_fare', 10, 2)->nullable();
            $table->string('payment_method');
            $table->string('payment_status')->default('pending');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->text('cancellation_reason')->nullable();
            $table->text('polyline')->nullable();
            $table->timestamps();
        });

        Schema::create('wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->decimal('balance', 12, 2)->default(0);
            $table->string('currency', 3)->default('INR');
            $table->timestamps();
        });

        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ride_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->decimal('amount', 10, 2);
            $table->string('method');
            $table->string('status')->default('pending');
            $table->string('transaction_id')->nullable();
            $table->json('gateway_response')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();
        });

        Schema::create('ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ride_id')->constrained()->cascadeOnDelete();
            $table->foreignId('rated_by')->constrained('users')->cascadeOnDelete();
            $table->foreignId('rated_to')->constrained('users')->cascadeOnDelete();
            $table->unsignedTinyInteger('rating');
            $table->text('review')->nullable();
            $table->timestamps();
        });

        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->text('body');
            $table->string('type');
            $table->json('data')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
        });

        Schema::create('coupons', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->string('description')->nullable();
            $table->string('discount_type');
            $table->decimal('discount_value', 10, 2);
            $table->unsignedInteger('max_uses')->nullable();
            $table->unsignedInteger('used_count')->default(0);
            $table->decimal('min_fare', 10, 2)->nullable();
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_id')->constrained()->cascadeOnDelete();
            $table->foreignId('ride_id')->nullable()->constrained()->nullOnDelete();
            $table->string('type');
            $table->decimal('amount', 10, 2);
            $table->string('description');
            $table->string('reference')->nullable();
            $table->decimal('balance_after', 12, 2);
            $table->timestamps();
        });

        Schema::create('emergency_contacts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name');
            $table->string('phone');
            $table->string('relationship')->nullable();
            $table->timestamps();
        });

        Schema::create('support_tickets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('ride_id')->nullable()->constrained()->nullOnDelete();
            $table->string('subject');
            $table->text('message');
            $table->string('status')->default('open');
            $table->string('priority')->default('normal');
            $table->text('admin_reply')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('support_tickets');
        Schema::dropIfExists('emergency_contacts');
        Schema::dropIfExists('transactions');
        Schema::dropIfExists('coupons');
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('ratings');
        Schema::dropIfExists('payments');
        Schema::dropIfExists('wallets');
        Schema::dropIfExists('rides');
        Schema::dropIfExists('vehicles');
        Schema::dropIfExists('drivers');
    }
};
