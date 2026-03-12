<?php

namespace App\Http\Controllers\labs;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Patient;
use App\Models\Examination;
use App\Models\AnalysisResult;
use App\Models\Appointment;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        try {
            // Helper function untuk hitung trend (Persentase perubahan)
            $getTrend = function ($model, $whereClause = []) {
                $now = Carbon::now();
                
                // Hitung data bulan ini
                $thisMonth = $model::where($whereClause)
                    ->whereMonth('created_at', $now->month)
                    ->whereYear('created_at', $now->year)
                    ->count();

                // Hitung data bulan lalu
                $lastMonth = $model::where($whereClause)
                    ->whereMonth('created_at', $now->subMonth()->month)
                    ->whereYear('created_at', $now->subMonth()->year)
                    ->count();

                if ($lastMonth == 0) return $thisMonth > 0 ? '+100%' : '0%';
                
                $diff = (($thisMonth - $lastMonth) / $lastMonth) * 100;
                return ($diff >= 0 ? '+' : '') . round($diff, 1) . '%';
            };

            return response()->json([
                'status' => 'success',
                'stats' => [
                    [
                        'label' => 'Total Pasien', 
                        'value' => Patient::count(), 
                        'icon' => 'Users', 
                        'trend' => $getTrend(Patient::class)
                    ],
                    [
                        'label' => 'Total Scan', 
                        'value' => Examination::count(), 
                        'icon' => 'Activity', 
                        'trend' => $getTrend(Examination::class)
                    ],
                    [
                        'label' => 'Kasus Glaukoma', 
                        'value' => AnalysisResult::where('prediction', 'glaucoma')->count(), 
                        'icon' => 'AlertCircle', 
                        'trend' => $getTrend(AnalysisResult::class, [['prediction', '=', 'glaucoma']])
                    ],
                    [
                        'label' => 'Akurasi AI', 
                        'value' => '94.2%', // Akurasi biasanya dari benchmark model, bukan jumlah data
                        'icon' => 'Target', 
                        'trend' => '+0.2%' 
                    ],
                ],
                'ready_to_exam' => Appointment::with('patient.user')
                    ->whereDate('appointment_date', Carbon::today())
                    ->where('appointment_status', 'confirmed')
                    ->orderBy('appointment_time', 'asc')
                    ->get()
                    ->map(function($app) {
                        return [
                            'id' => $app->id,
                            'name' => $app->patient->user->name ?? 'Unknown',
                            'time' => Carbon::parse($app->appointment_time)->format('H:i') . ' WIB',
                            'complain' => $app->patient_complaint,
                            'status' => 'READY'
                        ];
                    }),
                'processing' => Examination::with('patient.user')
                    ->whereIn('status', ['pending', 'processing'])
                    ->latest()
                    ->limit(2)
                    ->get()
                    ->map(function($exam) {
                        return [
                            'name' => $exam->patient->user->name ?? 'Pasien',
                            'time' => $exam->created_at->diffForHumans()
                        ];
                    })
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}