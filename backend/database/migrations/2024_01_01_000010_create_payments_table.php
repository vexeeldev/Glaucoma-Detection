<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {

            $table->id();

            $table->foreignId('appointment_id')
                  ->unique()                          
                  ->constrained('appointments')
                  ->onDelete('cascade');

            $table->string('invoice_number', 50)->unique(); 
            $table->decimal('amount', 12, 2)->default(0);

            $table->enum('payment_status', [
                'unpaid',
                'paid',
                'failed',
                'refunded',
            ])->default('unpaid');

            $table->enum('payment_method', [
                'bank_transfer',
                'virtual_account',
                'dummy',           
            ])->default('dummy');

            $table->string('transaction_id', 100)->nullable();
            $table->text('payment_proof')->nullable();   

            $table->timestamp('paid_at')->nullable();
            $table->timestamp('expired_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
