<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: activity_logs                        ║
     * ║  Deskripsi: Audit trail semua aksi di sistem ║
     * ║  Relasi: M:1 dengan users                    ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('activity_logs', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Foreign Key (nullable: bisa ada aksi tanpa login)
            $table->foreignId('user_id')
                  ->nullable()
                  ->constrained('users')
                  ->onDelete('set null');

            // ── Aksi
            $table->string('action', 100);      // login | logout | create_appointment | upload_image
            $table->string('module', 50);        // auth | appointment | payment | examination | ml
            $table->text('description')->nullable();

            // ── Referensi ke record yang diubah
            $table->string('subject_type', 100)->nullable();    // App\Models\Appointment
            $table->unsignedBigInteger('subject_id')->nullable();

            // ── Data Perubahan
            $table->json('old_data')->nullable();   // data sebelum perubahan
            $table->json('new_data')->nullable();   // data sesudah perubahan

            // ── Request Info
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();

            // ── Index untuk query log per user
            $table->index(['user_id', 'created_at']);
            $table->index('module');
            $table->index(['subject_type', 'subject_id']);

            // ── Timestamps (hanya created_at, log tidak diupdate)
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('activity_logs');
    }
};
