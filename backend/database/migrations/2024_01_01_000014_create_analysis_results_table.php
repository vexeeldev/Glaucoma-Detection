<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('analysis_results', function (Blueprint $table) {

            $table->id();

            $table->foreignId('examination_id')
                  ->constrained('examinations')
                  ->onDelete('cascade');

            $table->foreignId('fundus_image_id')
                  ->constrained('fundus_images')
                  ->onDelete('cascade');

            $table->foreignId('model_version_id')
                  ->constrained('ml_model_versions')
                  ->onDelete('restrict');   

            $table->enum('prediction', ['glaucoma', 'normal'])->nullable();
            $table->decimal('confidence_score', 5, 4)->nullable();      
            $table->decimal('glaucoma_probability', 5, 4)->nullable();  
            $table->decimal('normal_probability', 5, 4)->nullable();    

            $table->string('heatmap_image_path', 500)->nullable();      
            $table->json('raw_output')->nullable();                     

            $table->enum('status', [
                'queued',
                'processing',
                'completed',
                'failed',
            ])->default('queued');

            $table->string('error_message', 500)->nullable();
            $table->integer('processing_time_ms')->nullable();  

            $table->timestamp('analyzed_at')->nullable();

            $table->index(['examination_id', 'status']);
            $table->index('prediction');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('analysis_results');
    }
};
