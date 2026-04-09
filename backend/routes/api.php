<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ML\MachineController; 
use App\Http\Controllers\labs\DashboardController;
use App\Http\Controllers\labs\ExaminationController;
use App\Http\Controllers\labs\LoginLabsController;
use App\Http\Controllers\labs\LogoutLabsController;
use App\Http\Controllers\Desktop\{LoginAdminController, LogoutAdminController, RegisterAdminController};
use App\Http\Controllers\Mobile\{LoginController, LogoutController, RegisterController};
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Response;
use App\Http\Controllers\Mobile\patient\DoctorController;
use App\Http\Controllers\Mobile\patient\BookingController;
use App\Http\Controllers\Mobile\patient\PaymentController;
use App\Http\Controllers\Mobile\patient\NotificationController;
use App\Http\Controllers\Mobile\patient\DashboardPatientController;
use App\Http\Controllers\Mobile\patient\ProfilePatientController;
use App\Http\Controllers\Mobile\patient\ForgotPasswordController;

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

Route::middleware('auth:sanctum')->group(function () {

    // --- ROLE: PATIENT (Mobile) ---
    Route::prefix('mobile/patient')->group(function () {
        
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

        // 5. Modul Medical Records (Hasil Diagnosa AI untuk Pasien)
        Route::get('/medical-records', [ExaminationController::class, 'patientHistory']);
        Route::get('/medical-records/{id}', [ExaminationController::class, 'patientHistoryDetail']);
    });

    Route::get('mobile/patient/booking', [BookingController::class, 'index']);
    Route::get('mobile/doctor/booking', [BookingController::class, 'index']);

    // ---- ROLE: DOCTOR (Mobile) ---
    Route::prefix('mobile/doctor')->group(function () {
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
        Route::post('/examination-complete/{id}', [ExaminationController::class, 'updateStatus']);
        Route::post('/logout', [LogoutLabsController::class, 'logout']);
    });

    // --- COMMON LOGOUT ---
    Route::post('desktop/logout', [LogoutAdminController::class, 'logout']);
    Route::post('mobile/logout', [LogoutController::class, 'logout']);
});