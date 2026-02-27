<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: admins                               ║
     * ║  Deskripsi: Profil admin sistem              ║
     * ║  Relasi: 1:1 dengan users                    ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('admins', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Foreign Key
            $table->foreignId('user_id')
                  ->unique()
                  ->constrained('users')
                  ->onDelete('cascade');

            // ── Level Admin
            $table->string('admin_level', 30)->default('staff');
            // Contoh level: superadmin | admin | staff

            // ── Timestamps
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('admins');
    }
};
