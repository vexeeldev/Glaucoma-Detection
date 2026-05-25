<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AdminDashboardController extends Controller
{
    public function getDashboardData(Request $request)
    {
        try {
            // 1. KPI Stats - Data Kumulatif
            $totalPatients = DB::table('patients')->count();
            $totalDoctors = DB::table('doctors')->count();
            
            // Pemeriksaan khusus hari ini
            $examsToday = DB::table('appointments')
                ->whereDate('appointment_date', Carbon::today())
                ->count();

            // Total yang sudah memiliki hasil diagnosa
            $glaucomaDetected = DB::table('appointments')
                ->whereIn('appointment_status', ['glaukoma', 'confirmed']) // Sesuaikan mapping statusmu
                ->count();

            // 2. Secondary Stats
            $pendingAppointments = DB::table('appointments')
                ->whereIn('appointment_status', ['pending_payment', 'pending_confirmation'])
                ->count();

            // 3. Data untuk BarChart (Mapping Status ke Kategori Grafik)
            $monthlyData = DB::table('appointments')
                ->select(
                    DB::raw("to_char(appointment_date, 'Mon') as name"),
                    // Mapping: 'completed' masuk ke Normal, 'confirmed' masuk ke Glaukoma
                    DB::raw("count(case when lower(appointment_status) = 'completed' then 1 end) as \"Normal\""),
                    DB::raw("count(case when lower(appointment_status) = 'confirmed' then 1 end) as \"Glaukoma\""),
                    // Menampung sisa data (4 pending + 12 cancelled dll) agar totalnya tetap 29
                    DB::raw("count(case when lower(appointment_status) NOT IN ('completed', 'confirmed') then 1 end) as \"Lainnya\"")
                )
                ->whereYear('appointment_date', date('Y'))
                ->groupBy('name', DB::raw("extract(month from appointment_date)"))
                ->orderBy(DB::raw("extract(month from appointment_date)"))
                ->get();

            // 4. Data untuk PieChart
            $pieData = [
                ['name' => 'Glaukoma', 'value' => $glaucomaDetected],
                ['name' => 'Normal', 'value' => DB::table('appointments')->where('appointment_status', 'completed')->count()],
                ['name' => 'Proses/Batal', 'value' => $pendingAppointments]
            ];

            // 5. Recent Exams Table
            $recentExams = DB::table('appointments')
                ->join('patients', 'appointments.patient_id', '=', 'patients.id')
                ->join('users as p_user', 'patients.user_id', '=', 'p_user.id')
                ->join('doctors', 'appointments.doctor_id', '=', 'doctors.id')
                ->join('users as d_user', 'doctors.user_id', '=', 'd_user.id')
                ->select(
                    'appointments.id',
                    'p_user.name as patient',
                    'd_user.name as doctor',
                    'appointments.appointment_date as date',
                    // Logika untuk menampilkan hasil:
                    DB::raw("CASE 
                        WHEN lower(appointment_status) = 'glaukoma' THEN 'Glaukoma'
                        WHEN lower(appointment_status) = 'normal' THEN 'Normal'
                        WHEN lower(appointment_status) = 'completed' THEN 'Selesai'
                        WHEN lower(appointment_status) = 'confirmed' THEN 'Siap Analisis'
                        ELSE 'Proses'
                    END as result")
                )
                ->orderBy('appointments.created_at', 'desc')
                ->limit(5)
                ->get();

            return response()->json([
                'status' => 'success',
                'data' => [
                    'kpi' => [
                        'total_patients' => $totalPatients,
                        'total_doctors' => $totalDoctors,
                        'exams_today' => $examsToday,
                        'glaucoma_total' => $glaucomaDetected,
                    ],
                    'secondary' => [
                        'pending' => $pendingAppointments,
                        'ml_version' => 'v1.0.0-stable'
                    ],
                    'charts' => [
                        'monthly' => $monthlyData,
                        'pie' => $pieData
                    ],
                    'recent_exams' => $recentExams
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}