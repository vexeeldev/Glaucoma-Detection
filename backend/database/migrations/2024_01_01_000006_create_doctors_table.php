<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('doctors', function (Blueprint $table) {

            $table->id();

            $table->foreignId('user_id')
                  ->unique()
                  ->constrained('users')
                  ->onDelete('cascade');

            $table->foreignId('specialization_id')
                  ->nullable()
                  ->constrained('specializations')
                  ->onDelete('set null');

            $table->string('doctor_id_number', 20)->unique()->nullable();
            $table->string('str_number', 50)->unique()->nullable();
            $table->date('str_expired_at')->nullable();
            $table->string('sip_number', 50)->unique()->nullable();
            $table->date('sip_expired_at')->nullable();
            
            $table->string('education', 100)->nullable();
            $table->string('alumni', 100)->nullable();
            $table->integer('graduation_year')->nullable();
            
            $table->string('office_phone', 20)->nullable();
            $table->string('office_email', 150)->nullable();

            $table->string('license_number', 50)->unique(); 
            $table->string('practice_location', 200)->nullable();
            $table->integer('experience_years')->default(0);
            $table->text('bio')->nullable();
            $table->string('profile_photo', 500)->nullable();

            $table->decimal('consultation_fee', 12, 2)->default(0);
            $table->boolean('is_available')->default(true);

            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('doctors');
    }
};
