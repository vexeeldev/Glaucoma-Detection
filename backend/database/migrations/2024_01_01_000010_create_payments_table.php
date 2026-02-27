<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * ╔══════════════════════════════════════════════╗
     * ║  TABEL: payments                             ║
     * ║  Deskripsi: Data pembayaran tiap appointment ║
     * ║  Relasi: 1:1 dengan appointments             ║
     * ╚══════════════════════════════════════════════╝
     */
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {

            // ── Primary Key
            $table->id();

            // ── Foreign Key
            $table->foreignId('appointment_id')
                  ->unique()                          // 1 appointment hanya 1 payment
                  ->constrained('appointments')
                  ->onDelete('cascade');

            // ── Invoice
            $table->string('invoice_number', 50)->unique(); // INV-20240101-001

            // ── Nominal
            $table->decimal('amount', 12, 2)->default(0);

            // ── Status
            $table->enum('payment_status', [
                'unpaid',
                'paid',
                'failed',
                'refunded',
            ])->default('unpaid');

            // ── Metode Pembayaran
            $table->enum('payment_method', [
                'bank_transfer',
                'virtual_account',
                'dummy',            // untuk simulasi/testing
            ])->default('dummy');

            // ── Detail Transaksi
            $table->string('transaction_id', 100)->nullable();
            $table->text('payment_proof')->nullable();   // path foto bukti bayar

            // ── Waktu
            $table->timestamp('paid_at')->nullable();
            $table->timestamp('expired_at')->nullable();

            // ── Timestamps
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
