<?php

namespace App\Http\Controllers\Mobile\Doctor;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Appointment;
use App\Http\Resources\AppointmentResource;

class DoctorAppointmentController extends Controller
{
    /**
     * Mengambil daftar janji temu khusus untuk dokter yang sedang login.
     */
    public function index(Request $request)
    {
        try {
            // 1. Ambil data user dari token sanctum yang sedang aktif
            $user = auth()->user();

            // 2. Cari data dokter yang terhubung dengan user_id tersebut
            $doctor = DB::table('doctors')->where('user_id', $user->id)->first();

            // Proteksi jika user tersebut bukan merupakan dokter di sistem
            if (!$doctor) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Data dokter tidak ditemukan untuk akun ini.'
                ], 404);
            }

            // 3. Query daftar janji temu dengan join ke tabel pasien dan user
            $query = DB::table('appointments')
                ->join('patients', 'appointments.patient_id', '=', 'patients.id')
                ->join('users as p_user', 'patients.user_id', '=', 'p_user.id')
                ->select(
                    'appointments.id',
                    'p_user.name as patient_name',
                    'appointments.appointment_date',
                    'appointments.appointment_status as status',
                    // Kolom 'complaint' dihapus untuk menghindari SQLSTATE[42703]
                    DB::raw("CASE 
                        WHEN lower(appointment_status) = 'glaukoma' THEN 'Glaukoma'
                        WHEN lower(appointment_status) = 'normal' THEN 'Normal'
                        WHEN lower(appointment_status) = 'completed' THEN 'Selesai'
                        WHEN lower(appointment_status) = 'confirmed' THEN 'Siap Analisis'
                        ELSE 'Proses'
                    END as result_label")
                )
                ->where('appointments.doctor_id', $doctor->id)
                // Filter status agar hanya menampilkan yang sudah bayar atau selesai
                ->whereIn('appointments.appointment_status', ['confirmed', 'completed', 'glaukoma', 'normal']);

            // 4. Fitur pencarian berdasarkan nama pasien
            if ($request->has('search')) {
                $query->where('p_user.name', 'like', '%' . $request->search . '%');
            }

            $appointments = $query->orderBy('appointments.appointment_date', 'asc')->get();

            return response()->json([
                'status' => 'success',
                'message' => 'Daftar janji temu berhasil diambil',
                'data' => $appointments
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Terjadi kesalahan: ' . $e->getMessage()
            ], 500);
        }
    }
    public function show($id)
    {
        try {
            $user = auth()->user();
            $doctor = DB::table('doctors')->where('user_id', $user->id)->first();

            // Mengambil data appointment dengan relasi yang lebih lengkap
            $appointment = Appointment::with([
                'patient.user', 
                'examination', // Data hasil scan AI dari Web Lab
                'patient.appointments' => function($query) use ($id) {
                    // Ambil 3 riwayat terakhir yang sudah selesai
                    $query->where('id', '!=', $id)
                        ->whereIn('appointment_status', ['glaukoma', 'normal'])
                        ->orderBy('appointment_date', 'desc')
                        ->limit(3);
                }
            ])
            ->where('doctor_id', $doctor->id)
            ->where('id', $id)
            ->first();

            if (!$appointment) {
                return response()->json(['status' => 'error', 'message' => 'Data tidak ditemukan.'], 404);
            }

            return response()->json([
                'status' => 'success',
                'data' => new AppointmentResource($appointment)
            ]);

        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}