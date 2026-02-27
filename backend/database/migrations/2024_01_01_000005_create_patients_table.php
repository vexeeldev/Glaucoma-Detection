<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: patients                             ║
     * ║  Deskripsi: Profil lengkap pasien            ║
     * ║  Relasi: 1:1 dengan users                    ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('patients', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Foreign Key ke users
            $table->foreignId('user_id')
                  ->unique()
                  ->constrained('users')
                  ->onDelete('cascade');

            // ── Data Pribadi
            $table->date('date_of_birth')->nullable();
            $table->enum('gender', ['male', 'female'])->nullable();

            // ── Alamat
            $table->text('address')->nullable();
            $table->string('city', 80)->nullable();
            $table->string('province', 80)->nullable();
            $table->string('postal_code', 10)->nullable();

            // ── Kontak Darurat
            $table->string('emergency_contact_name', 100)->nullable();
            $table->string('emergency_contact_phone', 20)->nullable();
            $table->string('emergency_contact_relation', 50)->nullable();

            // ── Medis
            $table->string('blood_type', 5)->nullable();        // A, B, AB, O (±)
            $table->text('medical_history')->nullable();        // riwayat penyakit
            $table->text('current_medications')->nullable();    // obat yang sedang dikonsumsi
            $table->text('allergies')->nullable();              // alergi

            // ── Asuransi
            $table->string('insurance_provider', 100)->nullable();
            $table->string('insurance_number', 50)->nullable();

            // ── Timestamps
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patients');
    }
};
