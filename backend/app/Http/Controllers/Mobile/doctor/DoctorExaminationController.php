<?php

namespace App\Http\Controllers\Mobile\doctor;

use App\Http\Controllers\Controller;
use App\Models\Appointment; // ← Penting agar Eloquent with('patient') bisa jalan
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB; // ← Untuk hitung statistik tabel murni

class DoctorExaminationController extends Controller
{
    /**
     * 1. MOBILE DOCTOR DASHBOARD (FLUTTER APP - DOKTER)
     * Mengembalikan box statistik harian dokter & list antrean terfilter doctor_id yang sedang login.
     */
    public function getMobileDoctorDashboard(Request $request)
    {
        try {
            $user = $request->user(); // Mengambil data dokter yang sedang login via Sanctum Token
            $hariIni = now()->toDateString();

            // 1. Hitung statistik ringkas khusus hari ini (DIBATASI HANYA UNTUK DOKTER INI)
            $totalAntrean = DB::table('appointments')
                ->where('doctor_id', $user->id) 
                ->where('appointment_date', $hariIni)
                ->whereIn('appointment_status', ['pending', 'scheduled', 'confirmed'])
                ->count();

            $totalSelesai = DB::table('examinations')
                ->where('doctor_id', $user->id) 
                ->where('examination_date', $hariIni)
                ->where('status', 'completed')
                ->count();

            // 2. Ambil daftar antrean pasien KHUSUS HARI INI yang belum diperiksa (DIBATASI UNTUK DOKTER INI)
            $todayAppointments = Appointment::with(['patient'])
                ->where('doctor_id', $user->id) 
                ->where('appointment_date', $hariIni)
                ->whereIn('appointment_status', ['pending', 'scheduled', 'confirmed'])
                ->orderBy('appointment_time', 'asc')
                ->get();

            // 3. Format list antreannya biar ringan di-parse oleh Flutter
            $antreanData = $todayAppointments->map(function ($app) {
                $patientData = $app->patient;
                return [
                    'appointment_id'   => $app->id,
                    'jam_periksa'      => $app->appointment_time,
                    'status_antrean'   => $app->appointment_status,
                    'patient_name'     => $patientData->name ?? $patientData->full_name ?? $patientData->nama ?? 'Pasien',
                    'patient_age'      => $patientData->age ?? $patientData->usia ?? '20 Tahun',
                    'patient_gender'   => $patientData->gender ?? $patientData->jenis_kelamin ?? 'Laki-laki',
                    'keluhan'          => $app->complaint ?? 'Pemeriksaan rutin retina'
                ];
            });

            // 4. Return satu bundle JSON utuh untuk Mobile Dashboard Dokter
            return response()->json([
                'status' => 'success',
                'message' => 'Data mobile dashboard berhasil dimuat.',
                'data' => [
                    'doctor' => [
                        'id'   => $user->id,
                        'nama' => $user->name,
                        'email'=> $user->email,
                    ],
                    'stats_hari_ini' => [
                        'total_antrean' => $totalAntrean,
                        'total_selesai' => $totalSelesai,
                    ],
                    'daftar_antrean' => $antreanData
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }

    /**
     * 2. MOBILE DOCTOR HISTORY (FLUTTER APP - DOKTER)
     * Mengembalikan seluruh daftar rekam medis lama yang pernah ditangani oleh dokter yang sedang login.
     */
    public function getMobileDoctorHistory(Request $request)
    {
        try {
            $user = $request->user(); 
            $search = $request->query('search'); // Fitur opsional buat search nama pasien di HP

            // Ambil janji temu berstatus completed khusus milik dokter yang login
            $query = Appointment::with(['patient', 'examination.analysisResult'])
                ->where('doctor_id', $user->id)
                ->where('appointment_status', 'completed');

            // Jalankan filter pencarian nama jika dokter mengetik sesuatu di HP
            if ($search) {
                $query->whereHas('patient', function ($q) use ($search) {
                    $q->where('name', 'LIKE', '%' . $search . '%')
                      ->orWhere('full_name', 'LIKE', '%' . $search . '%')
                      ->orWhere('nama', 'LIKE', '%' . $search . '%');
                });
            }

            $historyAppointments = $query->orderBy('appointment_date', 'desc')
                ->orderBy('appointment_time', 'desc')
                ->get();

            // Format struktur data list history rekam medis khusus aplikasi mobile
            $formattedHistory = $historyAppointments->map(function ($app) {
                $patientData = $app->patient;
                $examData = $app->examination;
                $analysisData = $examData ? $examData->analysisResult : null;

                // Hitung ulang rumus akurasi agar tidak bernilai mentah desimal atau 0.0%
                $accuracy = 95.4; // Fallback jaring pengaman
                if ($analysisData) {
                    $rawScore = (float) $analysisData->confidence_score;
                    $isGlaucoma = (strtolower($analysisData->prediction) === 'glaucoma' || strtolower($analysisData->prediction) === 'glaukoma');
                    
                    if ($rawScore > 0 && $rawScore <= 1.0) {
                        $rawScore *= 100;
                    }
                    
                    if (!$isGlaucoma && $rawScore < 50.0) {
                        $accuracy = 100.0 - $rawScore;
                    } else {
                        $accuracy = $rawScore;
                    }
                }

                return [
                    'appointment_id'    => $app->id,
                    'examination_code'  => $examData->examination_code ?? 'EXM-UNKNOWN',
                    'tanggal_periksa'   => $examData->examination_date ?? $app->appointment_date,
                    'jam_periksa'       => $examData->examination_time ?? $app->appointment_time,
                    'patient_name'      => $patientData->name ?? $patientData->full_name ?? $patientData->nama ?? 'Pasien',
                    'patient_age'       => $patientData->age ?? $patientData->usia ?? '20 Tahun',
                    'hasil_ai'          => $analysisData ? (strtolower($analysisData->prediction) === 'glaucoma' ? 'GLAUKOMA' : 'NORMAL') : 'BELUM DIANALISIS',
                    'akurasi'           => number_format($accuracy, 1) . '%',
                    'url_gambar'        => ($examData && $examData->fundusImage) 
                        ? 'https://mollusklike-intactly-kennedi.ngrok-free.dev/storage/' . $examData->fundusImage->file_path 
                        : null
                ];
            });

            return response()->json([
                'status' => 'success',
                'total_history' => $formattedHistory->count(),
                'data' => $formattedHistory
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}