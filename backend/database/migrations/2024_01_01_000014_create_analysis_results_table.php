<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: analysis_results                     ║
     * ║  Deskripsi: Hasil analisis ML per gambar     ║
     * ║  Relasi: M:1 dengan examinations             ║
     * ║          M:1 dengan fundus_images            ║
     * ║          M:1 dengan ml_model_versions        ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('analysis_results', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Foreign Keys
            $table->foreignId('examination_id')
                  ->constrained('examinations')
                  ->onDelete('cascade');

            $table->foreignId('fundus_image_id')
                  ->constrained('fundus_images')
                  ->onDelete('cascade');

            $table->foreignId('model_version_id')
                  ->constrained('ml_model_versions')
                  ->onDelete('restrict');   // jangan hapus model jika masih ada hasil

            // ── Hasil Prediksi
            $table->enum('prediction', ['glaucoma', 'normal'])->nullable();
            $table->decimal('confidence_score', 5, 4)->nullable();      // 0.9200 = 92%
            $table->decimal('glaucoma_probability', 5, 4)->nullable();  // probabilitas glaukoma
            $table->decimal('normal_probability', 5, 4)->nullable();    // probabilitas normal

            // ── Output Visualisasi
            $table->string('heatmap_image_path', 500)->nullable();      // Grad-CAM heatmap
            $table->json('raw_output')->nullable();                     // full JSON dari ML service

            // ── Status Proses
            $table->enum('status', [
                'queued',
                'processing',
                'completed',
                'failed',
            ])->default('queued');

            $table->string('error_message', 500)->nullable();
            $table->integer('processing_time_ms')->nullable();  // berapa ms proses analisis

            // ── Waktu Analisis
            $table->timestamp('analyzed_at')->nullable();

            // ── Index untuk query riwayat
            $table->index(['examination_id', 'status']);
            $table->index('prediction');

            // ── Timestamps
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('analysis_results');
    }
};
