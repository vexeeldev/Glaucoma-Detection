<?php

use App\Http\Controllers\AuthController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/profile', [AuthController::class, 'updateProfile']);
    // Route::get('/dashboard/stats', [\App\Http\Controllers\DashboardController::class, 'getStats']);

    // Route::get('/ticket', [\App\Http\Controllers\TicketController::class, 'index']);
    // Route::get('/ticket/{code}', [\App\Http\Controllers\TicketController::class, 'show']);
    // Route::post('/ticket', [\App\Http\Controllers\TicketController::class, 'store']);
    // Route::post('/ticket-reply/{code}', [\App\Http\Controllers\TicketController::class, 'storeReply']);
});