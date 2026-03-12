<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ML\MachineController; //model ml
use App\Http\Controllers\labs\DashboardController;
use App\Http\Controllers\labs\ExaminationController;

// use Illuminate\Auth\Events\Logout;
use App\Http\Controllers\Desktop\{LoginAdminController, LogoutAdminController, RegisterAdminController};
use App\Http\Controllers\Mobile\{LoginController, LogoutController, RegisterController};

Route::prefix('ml')->group(function () {
    Route::post('/check-glaucoma', [MachineController::class, 'predict']);
});
Route::prefix('labs')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/examination-detail/{id}', [ExaminationController::class, 'getDetail']);
    Route::post('/examination-complete/{id}', [ExaminationController::class, 'updateStatus']);

    // URL: /api/labs/check-glaucoma (Proses Upload & AI)
    // Kamu bisa tambah route lain di sini nanti, contoh:
    // Route::get('/history', [LabHistoryController::class, 'index']);
});


Route::prefix('desktop')->group(function () {
    Route::post('/register', [RegisterAdminController::class, 'register']);
    Route::post('/login', [LoginAdminController::class, 'login']);
    
    Route::middleware('auth:sanctum')->group(function(){
        Route::post('/logout', [LogoutAdminController::class, 'logout']);
        });
});

Route::prefix('mobile')->group(function () {
    Route::post('/register', [RegisterController::class, 'register']);
    Route::post('/login', [LoginController::class, 'login']);
    
    Route::middleware('auth:sanctum')->group(function(){
        Route::post('/logout', [LogoutController::class, 'logout']);
        });
});

