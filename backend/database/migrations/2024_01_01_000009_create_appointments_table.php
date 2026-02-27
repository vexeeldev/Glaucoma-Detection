<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: appointments                         ║
     * ║  Deskripsi: Data janji temu pasien-dokter    ║
     * ║  Relasi: M:1 dengan patients                 ║
     * ║          M:1 dengan doctors                  ║
     * ║  Status flow:                                ║
     * ║    pending_payment                           ║
     * ║       ↓                                      ║
     * ║    pending_confirmation                      ║
     * ║       ↓                                      ║
     * ║    confirmed / rejected                      ║
     * ║       ↓                                      ║
     * ║    completed / cancelled                     ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('appointments', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Foreign Keys
            $table->foreignId('patient_id')
                  ->constrained('patients')
                  ->onDelete('cascade');

            $table->foreignId('doctor_id')
                  ->constrained('doctors')
                  ->onDelete('cascade');

            // ── Waktu Janji
            $table->date('appointment_date');
            $table->time('appointment_time');

            // ── Status
            $table->enum('appointment_status', [
                'pending_payment',
                'pending_confirmation',
                'confirmed',
                'rejected',
                'completed',
                'cancelled',
            ])->default('pending_payment');

            // ── Keluhan & Catatan
            $table->text('patient_complaint')->nullable();
            $table->text('doctor_notes')->nullable();
            $table->string('rejection_reason', 255)->nullable();

            // ── Konfirmasi (siapa yang konfirmasi + kapan)
            $table->foreignId('confirmed_by')
                  ->nullable()
                  ->constrained('users')
                  ->onDelete('set null');
            $table->timestamp('confirmed_at')->nullable();

            // ── Index untuk query cepat
            $table->index(['doctor_id', 'appointment_date']);
            $table->index(['patient_id', 'appointment_status']);

            // ── Timestamps
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('appointments');
    }
};
