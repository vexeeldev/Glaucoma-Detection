<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: specializations                      ║
     * ║  Deskripsi: Master data spesialisasi dokter  ║
     * ║  Harus dibuat SEBELUM tabel doctors          ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('specializations', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Data
            $table->string('name', 100)->unique();
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);

            // ── Timestamps
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('specializations');
    }
};
