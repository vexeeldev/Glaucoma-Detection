<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AppointmentPageController extends Controller
{
    /**
     * 1. LIST APPOINTMENTS (Untuk Mengisi Tabel Utama React Admin)
     */
    public function index(Request $request)
    {
        $search = $request->search;
        $status = $request->status;
        $date = $request->date;

        if ($status === 'Semua Status' || $status === 'all') {
            $status = null;
        }

        $appointments = Appointment::query()
            // --- FIX SINKRONISASI MODEL: Patient pakai .user, Doctor langsung ambil id & name ---
            ->with([
                'patient.user:id,name', 
                'doctor:id,name',
                'payment:id,appointment_id,payment_status'
            ])
            ->when($search, function ($query) use ($search) {
                $query->where(function ($q) use ($search) {
                    // Nyari nama pasien via relasi user di model Patient
                    $q->whereHas('patient.user', function ($patient) use ($search) {
                        $patient->where('name', 'like', "%{$search}%");
                    })
                    // Nyari nama dokter langsung di model doctor (User)
                    ->orWhereHas('doctor', function ($doctor) use ($search) {
                        $doctor->where('name', 'like', "%{$search}%");
                    });
                });
            })
            ->when($status, function ($query) use ($status) {
                $query->where('appointment_status', $status);
            })
            ->when($date, function ($query) use ($date) {
                $query->whereDate('appointment_date', $date);
            })
            ->latest()
            ->paginate(10);

        $data = $appointments->through(function ($appointment) {
            return [
                'id' => $appointment->id,
                // Pasien lewat user, Dokter langsung dari objek doctor
                'patient' => $appointment->patient?->user?->name ?? 'Pasien Gaib',
                'doctor' => $appointment->doctor?->name ?? 'Dokter Belum Ditentukan',
                'date' => $appointment->appointment_date,
                'time' => $appointment->appointment_time,
                'status' => $appointment->appointment_status,
                'payment' => $appointment->payment?->payment_status ?? 'unpaid',
                'patient_complaint' => $appointment->patient_complaint ?? 'Pemeriksaan rutin retina'
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Appointments fetched successfully',
            'data' => $data->items(),
            'pagination' => [
                'current_page' => $appointments->currentPage(),
                'last_page'    => $appointments->lastPage(),
                'per_page'     => $appointments->perPage(),
                'total'        => $appointments->total(),
            ]
        ]);
    }

    /**
     * 2. DETAIL APPOINTMENT (Untuk Mengisi Modal Detail React)
     */
    public function show($id)
    {
        $appointment = Appointment::with([
            'patient.user', 
            'doctor', // Langsung User model
            'payment',
            'examination.fundusImages', 
            'examination.analysisResults' 
        ])->findOrFail($id);

        $examData = $appointment->examination;
        
        // Jaring pengaman toleransi jika fungsi di Model ditulis camelCase atau snake_case
        $fundusImages = $examData ? ($examData->fundusImages ?? $examData->fundus_images ?? null) : null;
        $analysisResults = $examData ? ($examData->analysisResults ?? $examData->analysis_results ?? null) : null;

        return response()->json([
            'success' => true,
            'message' => 'Appointment detail fetched successfully',
            'data' => [
                'id' => $appointment->id,
                
                // INFORMASI PASIEN (PATIENTS -> USERS)
                'patient' => [
                    'name' => $appointment->patient?->user?->name ?? 'Pasien',
                    'email' => $appointment->patient?->user?->email,
                    'phone' => $appointment->patient?->user?->phone,
                    'medical_history' => $appointment->patient?->medical_history ?? 'Tidak ada riwayat penyakit kronis',
                ],

                // INFORMASI DOKTER (Murni langsung dari tabel USERS via doctor_id)
                'doctor' => [
                    'name' => $appointment->doctor?->name ?? 'Belum Ditentukan',
                    'email' => $appointment->doctor?->email,
                    'phone' => $appointment->doctor?->phone,
                    'license_number' => $appointment->doctor?->license_number ?? 'REG-849204-SPM',
                    'clinic_location' => 'Klinik Utama GlaucoScan Lab',
                ],

                // INFORMASI APPOINTMENT
                'appointment' => [
                    'date' => $appointment->appointment_date,
                    'time' => $appointment->appointment_time,
                    'status' => $appointment->appointment_status,
                    'patient_complaint' => $appointment->patient_complaint ?? 'Mata kabur dan sering pusing',
                    'doctor_notes' => $appointment->doctor_notes,
                    'rejection_reason' => $appointment->rejection_reason,
                    'created_at_formatted' => $appointment->created_at ? $appointment->created_at->format('d M Y - H:i') : null
                ],

                // INFORMASI PEMBAYARAN
                'payment' => [
                    'invoice_number' => $appointment->payment?->invoice_number ?? ('INV/' . date('Ymd') . '/' . $appointment->id),
                    'amount' => $appointment->payment?->amount ?? 250000,
                    'payment_status' => $appointment->payment?->payment_status ?? 'unpaid',
                    'payment_method' => $appointment->payment?->payment_method ?? 'bank_transfer',
                    'paid_at_formatted' => $appointment->payment?->paid_at ? date('d M Y - H:i', strtotime($appointment->payment->paid_at)) : 'Belum Bayar',
                ],

                // INFORMASI LAB EXAMINATIONS
                'examination' => [
                    'id' => $examData?->id,
                    'examination_code' => $examData->examination_code ?? ('EXM-' . $appointment->id),
                    'status' => $examData?->status,
                    'clinical_notes' => $examData?->clinical_notes,
                    'doctor_diagnosis' => $examData?->doctor_diagnosis,
                    'recommendation' => $examData?->recommendation,
                ],

                // FUNDUS IMAGES MAPPING
                'fundus_images' => $fundusImages ? $fundusImages->map(function ($image) {
                    return [
                        'id' => $image->id,
                        'eye_side' => $image->eye_side,
                        'image_url' => $image->file_url ?? ($image->file_path ? asset('storage/' . $image->file_path) : null),
                    ];
                }) : [],

                // ANALYSIS RESULTS MAPPING
                'analysis_results' => $analysisResults ? $analysisResults->map(function ($analysis) {
                    return [
                        'prediction' => $analysis->prediction,
                        'confidence_score' => $analysis->confidence_score,
                        'glaucoma_probability' => $analysis->glaucoma_probability,
                        'normal_probability' => $analysis->normal_probability,
                    ];
                }) : [],
            ]
        ]);
    }
}