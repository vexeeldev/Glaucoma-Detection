<?php

namespace App\Http\Controllers\Mobile\patient;

use App\Http\Controllers\Controller; 
use Illuminate\Support\Facades\DB;

class PaymentSimulationController extends Controller
{
    public function process($invoice)
    {
        return DB::transaction(function () use ($invoice) {
            $payment = DB::table('payments')->where('invoice_number', $invoice)->first();

            if (!$payment) {
                return "<h1 style='text-align:center; margin-top:50px;'>Invoice Tidak Ditemukan</h1>";
            }
            
            if ($payment->payment_status !== 'paid') {
                // 1. Update Payment
                DB::table('payments')->where('invoice_number', $invoice)->update([
                    'payment_status' => 'paid',
                    'paid_at' => now()
                ]);

                // 2. Update Appointment jadi Confirmed
                DB::table('appointments')->where('id', $payment->appointment_id)->update([
                    'appointment_status' => 'confirmed'
                ]);

                // 3. Tambahkan Notifikasi (Biar pasien dapet info di lonceng)
                // Ambil patient_id dari appointment
                $appointment = DB::table('appointments')->where('id', $payment->appointment_id)->first();
                
                DB::table('notifications')->insert([
                    'user_id'    => $appointment->patient_id,
                    'title'      => 'Pembayaran Berhasil!',
                    'message'    => 'Invoice ' . $invoice . ' telah lunas via QRIS.',
                    'type'       => 'PAYMENT_SUCCESS',
                    'related_id' => $appointment->id,
                    'created_at' => now()
                ]);
            }

            return "
                <div style='text-align:center; padding:50px; font-family:sans-serif;'>
                    <div style='font-size:70px;'>✅</div>
                    <h1 style='color:#2ecc71;'>Payment Success!</h1>
                    <p>Pembayaran untuk <b>$invoice</b> telah berhasil.</p>
                    <p>Halaman ini bisa ditutup, silakan cek aplikasi <b>GlaucoScan</b> kamu.</p>
                </div>
            ";
        });
    }
}