<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: ml_model_versions                    ║
     * ║  Deskripsi: Registry versi model ML          ║
     * ║  Hanya 1 model yang is_active = true         ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('ml_model_versions', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Identitas Model
            $table->string('version_name', 30)->unique();   // v1.0.0
            $table->string('architecture', 50)->nullable(); // EfficientNetB4, ResNet50, VGG19, dll
            $table->string('model_file_path', 500)->nullable();
            $table->string('dataset_used', 200)->nullable(); // nama dataset training

            // ── Metrik Performa Model
            $table->decimal('accuracy', 5, 4)->nullable();       // 0.9523 = 95.23%
            $table->decimal('sensitivity', 5, 4)->nullable();    // True Positive Rate
            $table->decimal('specificity', 5, 4)->nullable();    // True Negative Rate
            $table->decimal('auc_roc', 5, 4)->nullable();        // Area Under Curve
            $table->decimal('f1_score', 5, 4)->nullable();       // F1 Score
            $table->decimal('precision', 5, 4)->nullable();
            $table->integer('total_training_data')->nullable();
            $table->integer('total_validation_data')->nullable();

            // ── Status
            $table->boolean('is_active')->default(false);   // hanya 1 yang aktif
            $table->text('description')->nullable();
            $table->text('changelog')->nullable();          // perubahan dari versi sebelumnya

            // ── Deployment
            $table->timestamp('deployed_at')->nullable();
            $table->foreignId('deployed_by')
                  ->nullable()
                  ->constrained('users')
                  ->onDelete('set null');

            // ── Timestamps
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ml_model_versions');
    }
};
