<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: users                                ║
     * ║  Deskripsi: Base table untuk semua role      ║
     * ║  Role: patient | doctor | admin              ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Identitas
            $table->string('name', 100);
            $table->string('email', 150)->unique();
            $table->string('password', 255);
            $table->string('phone', 20)->nullable();

            // ── Role & Status
            $table->enum('role', ['patient', 'doctor', 'admin'])->default('patient');
            $table->boolean('is_active')->default(true);

            // ── Auth
            $table->string('remember_token', 100)->nullable();
            $table->timestamp('email_verified_at')->nullable();

            // ── Timestamps
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
