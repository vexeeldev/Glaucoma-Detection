<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('doctor_schedules', function (Blueprint $table) {

            $table->id();

            $table->foreignId('doctor_id')
                  ->constrained('doctors')
                  ->onDelete('cascade');

            $table->enum('day_of_week', ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']);
            $table->time('start_time');
            $table->time('end_time');
            $table->boolean('is_available')->default(true);

            $table->integer('max_patients')->default(10);
            $table->unique(['doctor_id', 'day_of_week']);

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('doctor_schedules');
    }
};
