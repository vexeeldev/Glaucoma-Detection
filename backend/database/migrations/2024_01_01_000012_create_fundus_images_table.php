<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: fundus_images                        ║
     * ║  Deskripsi: Metadata gambar retina pasien    ║
     * ║  Relasi: M:1 dengan examinations             ║
     * ║          M:1 dengan users (uploaded_by)      ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('fundus_images', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Foreign Keys
            $table->foreignId('examination_id')
                  ->constrained('examinations')
                  ->onDelete('cascade');

            $table->foreignId('uploaded_by')
                  ->constrained('users')
                  ->onDelete('cascade');

            // ── File Info
            $table->string('original_filename', 255);
            $table->string('stored_filename', 255)->unique();
            $table->string('file_path', 500);
            $table->string('file_url', 500)->nullable();
            $table->enum('file_format', ['jpg', 'jpeg', 'png'])->default('jpg');
            $table->unsignedBigInteger('file_size_bytes')->nullable();  // ukuran file

            // ── Dimensi Gambar
            $table->unsignedInteger('image_width_px')->nullable();
            $table->unsignedInteger('image_height_px')->nullable();

            // ── Info Mata
            $table->enum('eye_side', ['left', 'right', 'both'])->default('right');

            // ── Info Alat
            $table->string('device_name', 100)->nullable();         // nama alat kamera
            $table->string('device_model', 100)->nullable();        // model alat
            $table->text('capture_notes')->nullable();              // catatan saat pengambilan

            // ── Validasi
            $table->boolean('is_valid')->default(true);             // gambar valid atau tidak
            $table->text('invalid_reason')->nullable();             // alasan jika tidak valid

            // ── Waktu
            $table->timestamp('captured_at')->nullable();           // waktu foto diambil
            $table->timestamp('uploaded_at')->nullable();           // waktu diupload

            // ── Index
            $table->index('examination_id');

            // ── Timestamps
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fundus_images');
    }
};
