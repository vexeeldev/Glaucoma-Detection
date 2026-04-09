<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Mobile\patient\PaymentSimulationController;

//(Diakses via Scan QRIS)
Route::get('/pay/{invoice}', [PaymentSimulationController::class, 'process']);

Route::get('/', function () {
    return view('welcome');
});