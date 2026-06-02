<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ML\MachineController; 
use App\Http\Controllers\labs\{DashboardController, ExaminationController, LoginLabsController, LogoutLabsController};
use App\Http\Controllers\Desktop\{LoginAdminController, LogoutAdminController, RegisterAdminController};
use App\Http\Controllers\Mobile\{LoginController, LogoutController, RegisterController};
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Response;
use App\Http\Controllers\Mobile\patient\{DoctorController, BookingController, PaymentController, NotificationController}; 
use App\Http\Controllers\Mobile\patient\{PatientExaminationController,DashboardPatientController, ProfilePatientController, ForgotPasswordController};
use App\Http\Controllers\Mobile\doctor\{DoctorAppointmentController, DoctorExaminationController};
use App\Http\Controllers\Admin\{AdminDashboardController, ManagementUserController, ManagementDoctorController, AppointmentPageController};

/*
|--------------------------------------------------------------------------
| Public Routes (Tanpa Login)
|--------------------------------------------------------------------------
*/

// Auth Routes
Route::post('labs/login', [LoginLabsController::class, 'login']);
Route::post('desktop/login', [LoginAdminController::class, 'login']);
Route::post('desktop/register', [RegisterAdminController::class, 'register']);
Route::post('mobile/login', [LoginController::class, 'login']);
Route::post('mobile/register', [RegisterController::class, 'register']);

// ML Prediction (Untuk Testing/Direct access)
Route::prefix('ml')->group(function () {
    Route::post('/check-glaucoma', [MachineController::class, 'predict']);
});

// Proxy Image (Biarin tetap di sini sesuai request kamu)
Route::get('/proxy-image', function (Illuminate\Http\Request $request) {
    $path = str_replace('storage/', '', $request->path);
    if (!Storage::disk('public')->exists($path)) return response()->json(['error' => 'File not found'], 404);

    $file = Storage::disk('public')->get($path);
    $type = Storage::disk('public')->mimeType($path);

    return Response::make($file, 200, [
        'Content-Type' => $type,
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET',
    ]);
});

/*
|--------------------------------------------------------------------------
| Protected Routes (Wajib Login / Auth Sanctum)
|--------------------------------------------------------------------------
*/

Route::middleware(['auth:sanctum'])->group(function () {
    // Group khusus Admin
    Route::prefix('admin')->group(function () {
        Route::get('/dashboard', [AdminDashboardController::class, 'getDashboardData']);

        
    });
});

Route::middleware('auth:sanctum')->group(function () {

    // --- ROLE: PATIENT (Mobile) ---
    Route::prefix('mobile/patient')->group(function () {

        Route::get('/examination/queue-status', [PatientExaminationController::class, 'getPatientQueueStatus']); // API BARU untuk cek status antrean pasien di aplikasi mobile
        
        //buat dashboard dan profile patient di aplikasi mobile
        Route::get('/dashboard', [DashboardPatientController::class, 'index']);
        Route::get('/profile', [ProfilePatientController::class, 'show']);
        Route::put('/profile', [ProfilePatientController::class, 'update']);

        Route::get('/mobile/forgot-password', [ForgotPasswordController::class, 'reset']);

        // 1. Modul Dokter & Jadwal
        Route::get('/specializations', [DoctorController::class, 'specializations']);
        Route::get('/doctors', [DoctorController::class, 'index']);
        Route::get('/doctors/{id}', [DoctorController::class, 'show']);
        Route::get('/doctors/{id}/schedules', [DoctorController::class, 'schedules']);

        // 2. Modul Booking (Janji Temu)
        Route::prefix('booking')->group(function () {
            Route::post('/', [BookingController::class, 'store']);
            Route::get('/{id}', [BookingController::class, 'show']);
            Route::delete('/{id}', [BookingController::class, 'destroy']);
        });
        // 3. Modul Payment

        // 3. Modul Payment (Sisi API Flutter)
        Route::prefix('payment')->group(function (){
            Route::get('/{appointment_id}', [PaymentController::class, 'show']);
            Route::post('/', [PaymentController::class, 'store']); 
        });

        // 4. Modul Notifications (Lonceng)
        Route::prefix('notifications')->group(function () {
            Route::get('/', [NotificationController::class, 'index']);
            Route::get('/unread-count', [NotificationController::class, 'unreadCount']);
            Route::put('/mark-all-read', [NotificationController::class, 'markAllAsRead']);
            Route::put('/{id}/read', [NotificationController::class, 'markAsRead']);
            Route::delete('/clear', [NotificationController::class, 'clearAll']);
            Route::delete('/{id}', [NotificationController::class, 'destroy']);
        });
        //API BARU
        Route::get('/booking/{id}/queue', [BookingController::class, 'getQueueStatus']); 


        //API BARU
        // 5. Modul Medical Records (Hasil Diagnosa AI untuk Pasien)
        Route::get('/medical-records', [ExaminationController::class, 'patientHistory']);
        Route::get('/medical-records/{id}', [ExaminationController::class, 'patientHistoryDetail']);
        
    });

    // Endpoint untuk Dashboard Dokter (Detail Lengkap)
    Route::get('labs/examination/{appointment_id}/result', [ExaminationController::class, 'getLabResultForDoctor']);

    // Endpoint untuk Aplikasi Flutter Pasien (Simpel & Informatif)
    Route::get('patient/examination/{appointment_id}/result', [ExaminationController::class, 'getLabResultForPatient']);

    Route::get('mobile/patient/booking', [BookingController::class, 'index']);
    Route::get('mobile/doctor/booking', [BookingController::class, 'index']);

    // ---- ROLE: DOCTOR (Mobile) ---
    Route::prefix('mobile/doctor')->group(function () {
        Route::get('/dashboard', [DoctorExaminationController::class, 'getMobileDoctorDashboard']);
        Route::get('/history', [DoctorExaminationController::class, 'getMobileDoctorHistory']);
        Route::get('/appointments', [DoctorAppointmentController::class, 'index']);
        Route::get('/appointments/{id}', [DoctorAppointmentController::class, 'show']);
        Route::prefix('booking')->group(function () {
            Route::put('/{id}/confirm', [BookingController::class, 'confirm']);
            Route::put('/{id}/reject', [BookingController::class, 'reject']);
            Route::put('/{id}/complete', [BookingController::class, 'complete']);
        });
    });


    // --- ROLE: LABS / DOKTER ---
    Route::prefix('labs')->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'index']);
        Route::get('/history', [ExaminationController::class, 'history']);
        Route::get('/examination-detail/{id}', [ExaminationController::class, 'getDetail']);
        Route::post('/examination/{id}/result', [ExaminationController::class, 'storeLabResult']); // BARU
        Route::post('/examination-complete/{id}', [ExaminationController::class, 'updateStatus']);
        Route::post('/logout', [LogoutLabsController::class, 'logout']);

        Route::prefix('appointments')->group(function () {
        Route::get('/', [AppointmentPageController::class, 'index']);
        Route::get('/{id}', [AppointmentPageController::class, 'show']);
        });

        Route::prefix('management')->group(function () {

            Route::prefix('users')->group(function () {
                Route::get('/', [ManagementUserController::class, 'index']);
                Route::get('/{id}', [ManagementUserController::class, 'show']);
                Route::patch('/{id}/status', [ManagementUserController::class, 'updateStatus']);
                Route::delete('/{id}', [ManagementUserController::class, 'destroy']);
            });

            Route::prefix('doctors')->group(function () {
                Route::get('/', [ManagementDoctorController::class, 'index']);
                Route::post('/', [ManagementDoctorController::class, 'store']);
                Route::get('/{id}', [ManagementDoctorController::class, 'show']);
                Route::put('/{id}', [ManagementDoctorController::class, 'update']);
                Route::patch('/{id}/status', [ManagementDoctorController::class, 'updateStatus']);
                Route::delete('/{id}', [ManagementDoctorController::class, 'destroy']);
                Route::get('/{doctorId}/schedules', [ManagementDoctorController::class, 'schedules']);
                Route::post('/{doctorId}/schedules', [ManagementDoctorController::class, 'storeSchedule']);
                Route::patch('/schedules/{scheduleId}', [ManagementDoctorController::class, 'updateSchedule']);
                Route::delete('/schedules/{scheduleId}', [ManagementDoctorController::class, 'destroySchedule']);
            });

        });
        
    });

    // --- COMMON LOGOUT ---
    Route::post('desktop/logout', [LogoutAdminController::class, 'logout']);
    Route::post('mobile/logout', [LogoutController::class, 'logout']);
});