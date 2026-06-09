<?php

namespace App\Http\Controllers\Mobile\doctor;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Patient;
use Illuminate\Http\Request;

class ProfileController extends Controller
{

    public function show($id)
    {
        $patient = User::with('patient')->find($id);
        
        if (!$patient) {
            return response()->json(['message' => 'User tidak ditemukan'], 404);
        }
        
        return response()->json($patient);
    }

    public function update(Request $request, $id)
    {
        $user = User::findOrFail($id);
        
        $patient = Patient::where('user_id', $id)->first();

        if (!$patient) {
            return response()->json(['message' => 'Data detail pasien tidak ditemukan'], 404);
        }

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