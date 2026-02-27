<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: doctor_schedules                     ║
     * ║  Deskripsi: Jadwal praktik dokter per hari   ║
     * ║  Relasi: M:1 dengan doctors                  ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('doctor_schedules', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Foreign Key
            $table->foreignId('doctor_id')
                  ->constrained('doctors')
                  ->onDelete('cascade');

            // ── Jadwal
            $table->enum('day_of_week', ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']);
            $table->time('start_time');
            $table->time('end_time');
            $table->boolean('is_available')->default(true);

            // ── Kuota per sesi
            $table->integer('max_patients')->default(10);

            // ── Constraint: 1 dokter tidak boleh punya 2 jadwal di hari yang sama
            $table->unique(['doctor_id', 'day_of_week']);

            // ── Timestamps
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('doctor_schedules');
    }
};
