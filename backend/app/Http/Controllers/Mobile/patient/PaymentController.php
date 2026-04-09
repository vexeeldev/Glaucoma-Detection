<?php

namespace App\Http\Controllers\Mobile\patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PaymentController extends Controller
{
    public function show($appointment_id)
    {
        $payment = DB::table('payments')
            ->where('appointment_id', $appointment_id)
            ->first();

        if (!$payment) {
            return response()->json(['message' => 'Invoice tidak ditemukan'], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $payment
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'appointment_id' => 'required|exists:appointments,id',
            'payment_method' => 'required'
        ]);

        return DB::transaction(function () use ($request) {
            $payment = DB::table('payments')
                ->where('appointment_id', $request->appointment_id)
                ->first();

            // LOGIKA QRIS SIMULASI
            if (strtolower($request->payment_method) == 'qris') {
                // Ganti URL ini dengan URL Ngrok kamu nanti
                $ngrokUrl = "https://your-ngrok-id.ngrok-free.app"; 
                $paymentUrl = $ngrokUrl . "/pay/" . $payment->invoice_number;

                return response()->json([
                    'status' => 'pending',
                    'message' => 'Silakan scan QRIS untuk menyelesaikan pembayaran',
                    'payment_url' => $paymentUrl, // Ini yang diubah jadi QR di Flutter
                    'data' => $payment
                ]);
            }

            // FLOW NORMAL (Jika bukan QRIS, misal Tunai/Manual)
            DB::table('payments')
                ->where('appointment_id', $request->appointment_id)
                ->update([
                    'payment_status' => 'paid',
                    'payment_method' => $request->payment_method,
                    'paid_at' => now(),
                    'updated_at' => now()
                ]);

            DB::table('appointments')
                ->where('id', $request->appointment_id)
                ->update([
                    'appointment_status' => 'confirmed', // Langsung confirmed sesuai mau kamu
                    'updated_at' => now()
                ]);

            $updatedPayment = DB::table('payments')->where('appointment_id', $request->appointment_id)->first();

            return response()->json([
                'status' => 'success',
                'message' => 'Pembayaran berhasil dikonfirmasi.',
                'data' => $updatedPayment
            ]);
        });
    }
}