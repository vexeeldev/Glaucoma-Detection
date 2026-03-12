<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('ml_model_versions', function (Blueprint $table) {

            $table->id();

            $table->string('version_name', 30)->unique();  
            $table->string('architecture', 50)->nullable(); 
            $table->string('dataset_used', 200)->nullable(); 

            $table->decimal('accuracy', 5, 4)->nullable();      
            $table->decimal('sensitivity', 5, 4)->nullable();  
            $table->decimal('specificity', 5, 4)->nullable();    
            $table->decimal('auc_roc', 5, 4)->nullable();      
            $table->decimal('f1_score', 5, 4)->nullable();      
            $table->decimal('precision', 5, 4)->nullable();
            $table->integer('total_training_data')->nullable();
            $table->integer('total_validation_data')->nullable();

            $table->boolean('is_active')->default(false);   
            $table->text('description')->nullable();
            $table->text('changelog')->nullable();        

            $table->timestamp('deployed_at')->nullable();
            $table->foreignId('deployed_by')
                  ->nullable()
                  ->constrained('users')
                  ->onDelete('set null');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ml_model_versions');
    }
};
