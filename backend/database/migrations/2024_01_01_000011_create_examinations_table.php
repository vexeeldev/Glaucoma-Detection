<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('examinations', function (Blueprint $table) {

            $table->id();

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

            $table->text('clinical_notes')->nullable();        
            $table->text('doctor_diagnosis')->nullable();       
            $table->text('recommendation')->nullable();        
            $table->index(['patient_id', 'examination_date']);
            $table->index('status');

            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('examinations');
    }
};
