<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: notifications                        ║
     * ║  Deskripsi: Notifikasi multi-channel         ║
     * ║  Relasi: M:1 dengan users                    ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {

            // ── Primary Key
            $table->uuid('id')->primary();  // UUID bawaan Laravel notification

            // ── Foreign Key
            $table->foreignId('user_id')
                  ->constrained('users')
                  ->onDelete('cascade');

            // ── Konten
            $table->string('title', 200);
            $table->text('message');

            // ── Tipe & Channel
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

            // ── Status Baca
            $table->boolean('is_read')->default(false);
            $table->json('data')->nullable();           // payload tambahan (id referensi dll)

            // ── Waktu
            $table->timestamp('read_at')->nullable();
            $table->timestamp('sent_at')->nullable();

            // ── Index
            $table->index(['user_id', 'is_read']);
            $table->index('type');

            // ── Timestamps
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
