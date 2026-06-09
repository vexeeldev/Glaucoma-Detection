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
        $hariIni = now()->toDateString(); // Kunci real-time hari ini (2026-06-03)

        // --- SOLUSI DEMO: Ambil data antrean terbaru hari ini tanpa gembok patient_id yang bikin zonk ---
        $currentAppointment = Appointment::where('appointment_date', $hariIni)
            ->whereIn('appointment_status', ['pending', 'scheduled', 'confirmed', 'processing', 'completed'])
            ->latest('id') // Ambil data nomor 71 atau yang paling gres sendiri
            ->first();

        if (!$currentAppointment) {
            return response()->json([
                'status' => 'success',
                'has_queue' => false,
                'message' => 'Anda tidak memiliki antrean aktif untuk hari ini.'
            ], 200);
        }

        // 2. Hitung sisa antrean di depan (hanya berlaku jika status belum completed)
        $sisaAntreanDiDepan = 0;
        if (in_array($currentAppointment->appointment_status, ['pending', 'scheduled', 'confirmed', 'processing'])) {
            $sisaAntreanDiDepan = Appointment::where('appointment_date', $hariIni)
                ->whereIn('appointment_status', ['pending', 'scheduled', 'confirmed'])
                ->where('appointment_time', '<', $currentAppointment->appointment_time)
                ->count();
        }

        // 3. LOGIKA NOTIFIKASI DINAMIS (TERMASUK INTEGRASI HASIL AI)
        $notifikasiTeks = "Antrean Anda terjadwal pada jam " . date('H:i', strtotime($currentAppointment->appointment_time)) . " WIB.";
        
        if ($currentAppointment->appointment_status === 'completed') {
            $analysis = DB::table('examinations')
                ->join('analysis_results', 'examinations.id', '=', 'analysis_results.examination_id')
                ->where('examinations.appointment_id', $currentAppointment->id)
                ->select('analysis_results.prediction', 'analysis_results.confidence_score')
                ->first();

            if ($analysis) {
                $hasilLabel = (strtolower($analysis->prediction) === 'glaucoma' || strtolower($analysis->prediction) === 'glaukoma') ? 'GLAUKOMA' : 'NORMAL';
                $scorePersen = (float) $analysis->confidence_score <= 1.0 ? ((float) $analysis->confidence_score * 100) : (float) $analysis->confidence_score;
                
                $notifikasiTeks = "✅ Pemeriksaan Selesai! Hasil Analisis AI: " . $hasilLabel . " (" . number_format($scorePersen, 1) . "%). Silakan konsultasikan lebih lanjut dengan dokter ruangan.";
            } else {
                $notifikasiTeks = "✅ Pemeriksaan Selesai! Data rekam medis Anda sedang diarsipkan oleh sistem klinik.";
            }
        } 
        elseif ($currentAppointment->appointment_status === 'processing') {
            $notifikasiTeks = "📸 Mata retina Anda sedang difoto dan dianalisis oleh sistem AI GlaucoScan. Mohon tunggu sejenak.";
        } elseif ($currentAppointment->appointment_status === 'confirmed') {
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
                'notifikasi_pesan'   => $notifikasiTeks
            ]
        ], 200);

    } catch (\Exception $e) {
        return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
    }
}
}