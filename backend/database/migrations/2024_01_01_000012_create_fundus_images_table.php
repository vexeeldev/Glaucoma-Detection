<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('fundus_images', function (Blueprint $table) {

            $table->id();

            $table->foreignId('examination_id')
                  ->constrained('examinations')
                  ->onDelete('cascade');

            $table->foreignId('uploaded_by')
                  ->constrained('users')
                  ->onDelete('cascade');

            $table->string('original_filename', 255);
            $table->string('stored_filename', 255)->unique();
            $table->string('file_path', 500);
            $table->string('file_url', 500)->nullable();
            $table->enum('file_format', ['jpg', 'jpeg', 'png'])->default('jpg');
            $table->unsignedBigInteger('file_size_bytes')->nullable(); 

            $table->unsignedInteger('image_width_px')->nullable();
            $table->unsignedInteger('image_height_px')->nullable();

            $table->enum('eye_side', ['left', 'right', 'both'])->default('right');

            $table->string('device_name', 100)->nullable();        
            $table->string('device_model', 100)->nullable();        
            $table->text('capture_notes')->nullable();             
            $table->boolean('is_valid')->default(true);             
            $table->text('invalid_reason')->nullable();           

            $table->timestamp('captured_at')->nullable();          
            $table->timestamp('uploaded_at')->nullable();           

            $table->index('examination_id');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('fundus_images');
    }
};
