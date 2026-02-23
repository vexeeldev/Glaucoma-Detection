<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
            Schema::create('detections', function (Blueprint $table) {
            $table->id();
            $table->string('patient_name');
            $table->string('image_path'); // Tempat nyimpen lokasi foto mata
            $table->jsonb('ml_results')->nullable(); // Sesuai rencana kita pakai JSONB buat hasil ML
            $table->string('status')->default('pending'); // Biar tau Flask udah kelar apa belum
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('detections');
    }
};
