<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('appointments', function (Blueprint $table) {

            $table->id();
            $table->foreignId('patient_id')
                  ->constrained('patients')
                  ->onDelete('cascade');

            $table->foreignId('doctor_id')
                  ->constrained('doctors')
                  ->onDelete('cascade');

            $table->date('appointment_date');
            $table->time('appointment_time');

            $table->enum('appointment_status', [
                'pending_payment',
                'pending_confirmation',
                'confirmed',
                'rejected',
                'completed',
                'cancelled',
            ])->default('pending_payment');

            $table->text('patient_complaint')->nullable();
            $table->text('doctor_notes')->nullable();
            $table->string('rejection_reason', 255)->nullable();

            $table->foreignId('confirmed_by')
                  ->nullable()
                  ->constrained('users')
                  ->onDelete('set null');
            $table->timestamp('confirmed_at')->nullable();

            $table->index(['doctor_id', 'appointment_date']);
            $table->index(['patient_id', 'appointment_status']);

            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('appointments');
    }
};
