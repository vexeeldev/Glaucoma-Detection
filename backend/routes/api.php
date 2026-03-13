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
/*
|--------------------------------------------------------------------------
| PUBLIC ROUTES (Bisa diakses tanpa token)
|--------------------------------------------------------------------------
*/
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
Route::prefix('ml')->group(function () {
    Route::post('/check-glaucoma', [MachineController::class, 'predict']);
});

// Login harus di luar middleware supaya user bisa masuk
Route::post('labs/login', [LoginLabsController::class, 'login']);
Route::post('desktop/login', [LoginAdminController::class, 'login']);
Route::post('desktop/register', [RegisterAdminController::class, 'register']);
Route::post('mobile/login', [LoginController::class, 'login']);
Route::post('mobile/register', [RegisterController::class, 'register']);

/*
|--------------------------------------------------------------------------
| PROTECTED ROUTES (Wajib bawa Token / auth:sanctum)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    // --- Portal Labs ---
    Route::prefix('labs')->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'index']);
        Route::get('/history', [ExaminationController::class, 'history']);
        Route::post('/logout', [LogoutLabsController::class, 'logout']); // Sekarang pasti kenal User-nya
        Route::get('/examination-detail/{id}', [ExaminationController::class, 'getDetail']);
        Route::post('/examination-complete/{id}', [ExaminationController::class, 'updateStatus']);
    });

    // --- Portal Desktop ---
    Route::prefix('desktop')->group(function () {
        Route::post('/logout', [LogoutAdminController::class, 'logout']);
    });

    // --- App Mobile ---
    Route::prefix('mobile')->group(function () {
        Route::post('/logout', [LogoutController::class, 'logout']);
    });

});