<?php

namespace App\Http\Controllers\Mobile\doctor;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ProfileController extends Controller
{
    public function show()
    {
        return response()->json(Auth::user()->load('patient'));
    }

    public function update(Request $request)
    {
        $user = Auth::user();
        
        $request->validate([
            'name' => 'required|string|max:255',
            'date_of_birth' => 'required|date',
            'gender' => 'required|string',
            'blood_type' => 'nullable|string|max:5',
            'address' => 'nullable|string',
            'emergency_contact_phone' => 'nullable|string|max:20',
            'medical_history' => 'nullable|string', // Penting: Riwayat Diabetes/Hipertensi
            'current_medication' => 'nullable|string', // Penting: Obat yang sedang diminum
            'allergies' => 'nullable|string',
        ]);

        // 1. Update Tabel Users
        $user->update(['name' => $request->name]);

        // 2. Update Tabel Patients (Hanya yang penting buat medis)
        $user->patient->update($request->only([
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
            'message' => 'Profil medis berhasil diperbarui',
            'data' => $user->load('patient')
        ]);
    }
}