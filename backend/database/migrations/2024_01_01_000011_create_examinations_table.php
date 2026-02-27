<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: examinations                         ║
     * ║  Deskripsi: Sesi pemeriksaan retina          ║
     * ║  Relasi: 1:1 dengan appointments             ║
     * ║          M:1 dengan patients                 ║
     * ║          M:1 dengan doctors                  ║
     * ║  Status flow:                                ║
     * ║    pending → image_uploaded                  ║
     * ║      → processing → completed / failed       ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('examinations', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Foreign Keys
            $table->foreignId('appointment_id')
                  ->unique()
                  ->constrained('appointments')
                  ->onDelete('cascade');

            $table->foreignId('patient_id')
                  ->constrained('patients')
                  ->onDelete('cascade');

            $table->foreignId('doctor_id')
                  ->constrained('doctors')
                  ->onDelete('cascade');

            // ── Kode Unik Pemeriksaan
            $table->string('examination_code', 30)->unique(); // EXM-20240101-001

            // ── Waktu
            $table->date('examination_date');
            $table->time('examination_time')->nullable();

            // ── Status
            $table->enum('status', [
                'pending',
                'image_uploaded',
                'processing',
                'completed',
                'failed',
            ])->default('pending');

            // ── Catatan Medis
            $table->text('clinical_notes')->nullable();         // catatan klinis umum
            $table->text('doctor_diagnosis')->nullable();       // diagnosis final dokter
            $table->text('recommendation')->nullable();         // rekomendasi tindak lanjut

            // ── Index
            $table->index(['patient_id', 'examination_date']);
            $table->index('status');

            // ── Timestamps
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('examinations');
    }
};
