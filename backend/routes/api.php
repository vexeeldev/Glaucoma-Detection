<?php

use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ML\MachineController; //model ml
use App\Http\Controllers\labs\DashboardController;
use App\Http\Controllers\labs\ExaminationController;

Route::prefix('ml')->group(function () {
    Route::post('/check-glaucoma', [MachineController::class, 'predict']);
});
Route::prefix('labs')->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/history', [ExaminationController::class, 'history']);
    Route::get('/examination-detail/{id}', [ExaminationController::class, 'getDetail']);
    Route::post('/examination-complete/{id}', [ExaminationController::class, 'updateStatus']);

    // URL: /api/labs/check-glaucoma (Proses Upload & AI)
    // Kamu bisa tambah route lain di sini nanti, contoh:
    // Route::get('/history', [LabHistoryController::class, 'index']);
});










Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/profile', [AuthController::class, 'updateProfile']);
});