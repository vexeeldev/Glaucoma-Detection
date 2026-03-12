<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('activity_logs', function (Blueprint $table) {

            $table->id();

            $table->foreignId('user_id')
                  ->nullable()
                  ->constrained('users')
                  ->onDelete('set null');

            $table->string('action', 100);      
            $table->string('module', 50);       
            $table->text('description')->nullable();

            $table->string('subject_type', 100)->nullable();   
            $table->unsignedBigInteger('subject_id')->nullable();

            $table->json('old_data')->nullable();   
            $table->json('new_data')->nullable();   

            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();

            $table->index(['user_id', 'created_at']);
            $table->index('module');
            $table->index(['subject_type', 'subject_id']);

            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('activity_logs');
    }
};
