<?php

namespace App\Http\Controllers\Mobile\patient;

use App\Http\Controllers\Controller;
use App\Models\Doctor;
use App\Models\Specialization;
use App\Models\Schedule;
use App\Models\Appointment;
use Illuminate\Http\Request;

class DoctorController extends Controller
{
    /**
     * GET /doctors
     * Deskripsi: List semua dokter aktif dengan filter
     */
    public function index(Request $request)
    {
        $query = Doctor::with(['user', 'specialization']);

        // Filter: Nama (lewat tabel users)
        if ($request->has('search')) {
            $query->whereHas('user', function($q) use ($request) {
                $q->where('name', 'like', '%' . $request->search . '%');
            });
        }

        // Filter: Spesialisasi ID
        if ($request->has('specialization_id')) {
            $query->where('specialization_id', $request->specialization_id);
        }

        // Filter: Tersedia (is_available biasanya boolean)
        if ($request->has('is_available')) {
            $query->where('is_available', $request->is_available);
        }

        $doctors = $query->get()->map(function($doctor) {
            return [
                'id' => $doctor->id,
                'name' => $doctor->user->name,
                'specialization' => $doctor->specialization->name,
                'experience' => $doctor->experience_years . ' Tahun',
                'consultation_fee' => $doctor->consultation_fee,
                'is_available' => $doctor->is_available,
                'profile_photo' => $doctor->profile_photo_url,
            ];
        });

        return response()->json([
            'status' => 'success',
            'message' => 'List dokter berhasil diambil',
            'data' => $doctors
        ]);
    }

    /**
     * GET /doctors/{id}
     * Deskripsi: Detail profil dokter lengkap
     */
    public function show($id)
    {
        $doctor = Doctor::with(['user', 'specialization', 'schedules'])->find($id);

        if (!$doctor) {
            return response()->json(['message' => 'Dokter tidak ditemukan'], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'id' => $doctor->id,
                'name' => $doctor->user->name,
                'email' => $doctor->user->email,
                'specialization' => $doctor->specialization->name,
                'biography' => $doctor->biography,
                'consultation_fee' => $doctor->consultation_fee,
                'schedules' => $doctor->schedules, // List hari praktik rutin
            ]
        ]);
    }

    /**
     * GET /doctors/{id}/schedules
     * Deskripsi: Cek slot jam dan sisa kuota pada tanggal tertentu
     */
   public function schedules(Request $request, $id = null)
{
    try {
        $request->validate([
            'date' => 'required|date'
        ]);

        $date = $request->date;
        $dayName = strtolower(date('l', strtotime($date))); 

        // Query Utama: Cari dokter yang punya jadwal di hari tersebut
        $query = \App\Models\Doctor::with(['user', 'specialization', 'schedules' => function($q) use ($dayName) {
            $q->where('day_of_week', $dayName);
        }]);

        // Kalau ada ID, berarti cari spesifik 1 dokter. Kalau ID kosong, cari semua dokter hari itu.
        if ($id) {
            $query->where('id', $id);
        }

        // Filter hanya yang punya jadwal di hari tersebut
        $query->whereHas('schedules', function($q) use ($dayName) {
            $q->where('day_of_week', $dayName);
        });

        $doctors = $query->get();

        if ($doctors->isEmpty()) {
            return response()->json([
                'status' => 'info',
                'message' => "Tidak ada dokter yang praktik pada hari $dayName ($date).",
            ], 200);
        }

        $result = $doctors->map(function($doctor) use ($date) {
            return [
                'doctor_info' => [
                    'id' => $doctor->id,
                    'name' => $doctor->user->name,
                    'specialization' => $doctor->specialization->name,
                    'biography' => $doctor->biography,
                    'consultation_fee' => $doctor->consultation_fee,
                ],
                'available_slots' => $doctor->schedules->map(function($slot) use ($doctor, $date) {
                    // Hitung booking per slot jam
                    $bookedCount = \DB::table('appointments')
                        ->where('doctor_id', $doctor->id)
                        ->where('appointment_date', $date)
                        ->where('appointment_time', $slot->start_time)
                        ->whereNotIn('appointment_status', ['cancelled', 'rejected']) 
                        ->count();

                    return [
                        'schedule_id' => $slot->id,
                        'time' => $slot->start_time . ' - ' . $slot->end_time,
                        'status' => $slot->is_available ? 'Buka' : 'Tutup',
                        'max_patients' => $slot->max_patients,
                        'booked' => $bookedCount,
                        'remaining' => max(0, $slot->max_patients - $bookedCount),
                        'is_full' => ($slot->max_patients - $bookedCount) <= 0
                    ];
                })
            ];
        });

        return response()->json([
            'status' => 'success',
            'search_details' => [
                'requested_date' => $date,
                'day' => $dayName,
                'total_doctors_found' => $doctors->count()
            ],
            'data' => $result
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'message' => $e->getMessage()
        ], 500);
    }
}
    /**
     * GET /specializations
     * Deskripsi: Master data spesialisasi
     */
    public function specializations()
    {
        $data = Specialization::all();
        return response()->json([
            'status' => 'success',
            'data' => $data
        ]);
    }
}