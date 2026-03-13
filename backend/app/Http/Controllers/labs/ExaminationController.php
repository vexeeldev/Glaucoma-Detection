<?php

namespace App\Http\Controllers\labs;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use Carbon\Carbon;
use Illuminate\Http\Request;

class ExaminationController extends Controller
{
    public function getDetail($id)
    {
        // Ambil janji temu dengan relasi pasien dan user
        $appointment = Appointment::with('patient.user', 'doctor')->find($id);

        if (!$appointment) {
            return response()->json(['message' => 'Data tidak ditemukan'], 404);
        }

        $patient = $appointment->patient;
        
        // Hitung umur secara dinamis
        $age = Carbon::parse($patient->date_of_birth)->age;

        return response()->json([
            'id' => $appointment->id,
            'name' => $patient->user->name,
            'age' => $age . ' Tahun',
            'gender' => $patient->gender == 'L' ? 'Laki-laki' : 'Perempuan',
            'complaint' => $appointment->patient_complaint,
            'medical_history' => $patient->medical_history ?? 'Tidak ada riwayat',
            // --- PERBAIKAN DI SINI (Ganti $app jadi $appointment) ---
            'date'      => Carbon::parse($appointment->appointment_date)->translatedFormat('l, d F Y'),
            'time'      => date('H:i', strtotime($appointment->appointment_time)) . ' WIB',
            'doctor' => ($appointment->doctor && strtolower($appointment->doctor->role) === 'doctor') 
            ? $appointment->doctor->name 
            : 'Dokter Belum Terpilih',
        ]);
    }

    public function updateStatus(Request $request, $id)
    {
        $appointment = Appointment::find($id);
        if ($appointment) {
            $appointment->update(['appointment_status' => 'completed']);
            return response()->json(['status' => 'success']);
        }
        return response()->json(['status' => 'error'], 404);
    }

    public function history(Request $request)
    {
        try {
            $query = Appointment::with(['patient.user', 'doctor', 'examination.analysisResults', 'examination.fundusImage'])
                ->where('appointment_status', 'completed');

            $results = $query->latest()->get();

            $data = $results->map(function($app) {
                $examination = $app->examination;
                $analysis = $examination ? $examination->analysisResults->first() : null;
                $fundus = $examination ? $examination->fundusImage : null;

                // Pastikan confidence_score dikali 100 di sini
                $score = $analysis ? (float)$analysis->confidence_score : 0;
                if ($score <= 1 && $score > 0) {
                    $score = $score * 100;
                }

                return [
                    'id'     => $app->id,
                    'name'   => $app->patient->user->name ?? 'Tanpa Nama',
                    'date'   => $app->appointment_date ? \Carbon\Carbon::parse($app->appointment_date)->format('Y-m-d') : null,
                    'display_date' => $app->appointment_date ? \Carbon\Carbon::parse($app->appointment_date)->format('d/m/Y') : '-',
                    'eye'    => $analysis->eye_side ?? 'Keduanya',
                    'result' => $analysis ? strtoupper($analysis->prediction) : 'NORMAL',
                    'conf'   => (int)$score, // Sekarang pasti angka puluhan (0-100)
                    'doctor' => $app->doctor->name ?? 'dr. Budi Santoso',
                    'advice' => $analysis->medical_advice ?? 'Tetap jaga kondisi kesehatan mata.',
                    'image_url' => $fundus ? $fundus->file_path : null, 
                ];
            });

            $filtered = $data;

            // --- PERBAIKAN FILTER NAMA (Pakai Str::contains agar lebih aman) ---
            if ($request->filled('search')) {
                $search = strtolower($request->search);
                $filtered = $filtered->filter(function($item) use ($search) {
                    // Kita paksa semua jadi kecil pas dibandingin
                    return \Illuminate\Support\Str::contains(strtolower($item['name']), $search);
                });
            }

            // Filter Tanggal
            if ($request->filled('date')) {
                $filtered = $filtered->where('date', $request->date);
            }

            
            // Filter Hasil AI
            if ($request->filled('result') && $request->result !== 'Semua') {
                $resFilter = strtoupper($request->result); // GLAUCOMA
                
                $filtered = $filtered->filter(function($item) use ($resFilter) {
                    $itemResult = strtoupper($item['result']);
                    
                    // Logika cerdas: Kalau nyari Glaukoma/Glaucoma, ambil kata depannya aja biar pasti kena
                    if ($resFilter === 'GLAUCOMA' || $resFilter === 'GLAUKOMA') {
                        return str_contains($itemResult, 'GLAU'); 
                    }
                    
                    return str_contains($itemResult, $resFilter);
                });
            }

            return response()->json($filtered->values());
            
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
        
}