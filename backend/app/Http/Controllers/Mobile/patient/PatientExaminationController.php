<?php

namespace App\Http\Controllers\Mobile\Patient;

use App\Http\Controllers\Controller;
use App\Models\Appointment; 
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PatientExaminationController extends Controller
{
    public function getPatientQueueStatus(Request $request)
    {
        try {
            $user = $request->user(); 
            $hariIni = now()->toDateString();

            $currentAppointment = Appointment::where('patient_id', $user->id)
                ->where('appointment_date', $hariIni)
                ->whereIn('appointment_status', ['pending', 'scheduled', 'confirmed', 'processing'])
                ->first();

            if (!$currentAppointment) {
                return response()->json([
                    'status' => 'success',
                    'has_queue' => false,
                    'message' => 'Anda tidak memiliki antrean aktif untuk hari ini.'
                ], 200);
            }

            // 2. Hitung berapa banyak pasien yang mengantre DI DEPANNYA (yang jam janjinya lebih awal)
            $sisaAntreanDiDepan = Appointment::where('appointment_date', $hariIni)
                ->whereIn('appointment_status', ['pending', 'scheduled', 'confirmed'])
                ->where('appointment_time', '<', $currentAppointment->appointment_time)
                ->count();

            // 3. Susun teks pesan notifikasi dinamis berdasarkan status antrean riil
            $notifikasiTeks = "Antrean Anda terjadwal pada jam " . date('H:i', strtotime($currentAppointment->appointment_time)) . " WIB.";
            
            if ($currentAppointment->appointment_status === 'confirmed') {
                $notifikasiTeks = "🚨 Panggilan! Silakan menuju ke ruang lab, giliran Anda telah tiba.";
            } elseif ($sisaAntreanDiDepan == 0) {
                $notifikasiTeks = "⏳ Bersiaplah! Anda adalah antrean berikutnya setelah pasien di dalam selesai.";
            } elseif ($sisaAntreanDiDepan > 0) {
                $notifikasiTeks = "🔔 Pengingat: Ada " . $sisaAntreanDiDepan . " pasien lagi di depan Anda. Harap tunggu di area ruang tunggu.";
            }

            return response()->json([
                'status' => 'success',
                'has_queue' => true,
                'data' => [
                    'appointment_id'     => $currentAppointment->id,
                    'jam_pemeriksaan'    => $currentAppointment->appointment_time,
                    'status_saat_ini'    => $currentAppointment->appointment_status,
                    'sisa_antrean_depan' => $sisaAntreanDiDepan,
                    'notifikasi_pesan'   => $notifikasiTeks // ← Tinggal di-fetch langsung di layar Flutter Pasien
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}