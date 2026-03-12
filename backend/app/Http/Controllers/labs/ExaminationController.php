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
        $query = Appointment::with(['patient.user', 'doctor', 'examination.analysisResults'])
            ->where('appointment_status', 'completed');

        $data = $query->latest()->get()->map(function($app) {
            // Ambil hasil analisis dari relasi examination
            $analysis = $app->examination->analysisResults->first() ?? null;

            return [
                'id'    => $app->id,
                'name'  => $app->patient->user->name,
                'date'  => \Carbon\Carbon::parse($app->appointment_date)->format('d/m/Y'),
                'eye'    => $analysis->eye_side ?? 'Keduanya',
                'result' => $analysis ? strtoupper($analysis->prediction) : 'NORMAL',
                'conf'   => $analysis ? (int)($analysis->confidence_score * 100) : 0,
                'doctor' => $app->doctor->name ?? 'dr. Budi Santoso',
                'advice' => $analysis->medical_advice ?? 'Tetap jaga kondisi kesehatan mata.'
            ];
        });

        return response()->json($data);
    }
    
}