<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: doctors                              ║
     * ║  Deskripsi: Profil lengkap dokter            ║
     * ║  Relasi: 1:1 dengan users                    ║
     * ║          M:1 dengan specializations          ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('doctors', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Foreign Keys
            $table->foreignId('user_id')
                  ->unique()
                  ->constrained('users')
                  ->onDelete('cascade');

            $table->foreignId('specialization_id')
                  ->nullable()
                  ->constrained('specializations')
                  ->onDelete('set null');

            // ── Profesional
            $table->string('license_number', 50)->unique(); // Nomor SIP/STR
            $table->string('practice_location', 200)->nullable();
            $table->integer('experience_years')->default(0);
            $table->text('bio')->nullable();
            $table->string('profile_photo', 500)->nullable();

            // ── Konsultasi
            $table->decimal('consultation_fee', 12, 2)->default(0);
            $table->boolean('is_available')->default(true);

            // ── Timestamps
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('doctors');
    }
};
