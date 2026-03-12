<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('patients', function (Blueprint $table) {

            $table->id();

            $table->foreignId('user_id')
                  ->unique()
                  ->constrained('users')
                  ->onDelete('cascade');

            $table->string('medical_record_number', 20)->unique()->nullable();
            $table->string('bpjs_number', 20)->unique()->nullable();
            
            $table->enum('marital_status', ['single', 'married', 'divorced', 'widowed'])->nullable();
            $table->string('occupation', 100)->nullable();
            $table->enum('patient_status', ['active', 'inactive', 'pending'])->default('active');
            $table->date('registration_date')->nullable();

            $table->date('date_of_birth')->nullable();
            $table->enum('gender', ['male', 'female'])->nullable();

            $table->text('address')->nullable();
            $table->string('city', 80)->nullable();
            $table->string('province', 80)->nullable();
            $table->string('postal_code', 10)->nullable();

            $table->string('emergency_contact_name', 100)->nullable();
            $table->string('emergency_contact_phone', 20)->nullable();
            $table->string('emergency_contact_relation', 50)->nullable();

            $table->string('blood_type', 5)->nullable();        
            $table->text('medical_history')->nullable();        
            $table->text('current_medications')->nullable();    
            $table->text('allergies')->nullable();              

            $table->string('insurance_provider', 100)->nullable();
            $table->string('insurance_number', 50)->nullable();

            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('patients');
    }
};
