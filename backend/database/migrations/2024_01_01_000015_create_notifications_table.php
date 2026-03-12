<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {

            $table->uuid('id')->primary(); 
            $table->foreignId('user_id')
                  ->constrained('users')
                  ->onDelete('cascade');

            $table->string('title', 200);
            $table->text('message');

            $table->enum('type', [
                'appointment_created',
                'appointment_confirmed',
                'appointment_rejected',
                'payment_confirmed',
                'examination_completed',
                'analysis_ready',
                'system',
            ])->default('system');

            $table->enum('channel', ['push', 'email', 'sms'])->default('push');

            $table->boolean('is_read')->default(false);
            $table->json('data')->nullable();          

            $table->timestamp('read_at')->nullable();
            $table->timestamp('sent_at')->nullable();

            $table->index(['user_id', 'is_read']);
            $table->index('type');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
