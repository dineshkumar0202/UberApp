<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone')->unique()->after('email');
            $table->string('role')->default('customer')->after('password');
            $table->string('avatar')->nullable()->after('role');
            $table->boolean('is_active')->default(true)->after('avatar');
            $table->timestamp('phone_verified_at')->nullable()->after('email_verified_at');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['phone', 'role', 'avatar', 'is_active', 'phone_verified_at']);
        });
    }
};
