<?php

namespace App\Http\Controllers\Mobile\doctor;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Patient;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    // Tes Lihat Profil: GET http://localhost:8000/api/test/patient/1
    public function show($id)
    {
        $patient = User::with('patient')->find($id);
        
        if (!$patient) {
            return response()->json(['message' => 'User tidak ditemukan'], 404);
        }
        
        return response()->json($patient);
    }

    // Tes Update Profil: POST http://localhost:8000/api/test/patient/1
    // Pakai Method POST dan tambahkan _method = PUT di body atau langsung PUT
    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);
        
        // Cari data patient yang nyambung ke user_id tersebut
        $patient = Patient::where('user_id', $id)->first();

        if (!$patient) {
            return response()->json(['message' => 'Data detail pasien tidak ditemukan'], 404);
        }

        // Update data esensial medis sesuai tabel kamu
        $user->update(['name' => $request->name]);
        
        $patient->update($request->only([
            'date_of_birth', 
            'gender', 
            'blood_type', 
            'address', 
            'emergency_contact_phone',
            'medical_history', 
            'current_medication', 
            'allergies'
        ]));

        return response()->json([
            'message' => 'Test Update Berhasil (Tanpa Middleware)',
            'data' => $user->load('patient')
        ]);
    }
}