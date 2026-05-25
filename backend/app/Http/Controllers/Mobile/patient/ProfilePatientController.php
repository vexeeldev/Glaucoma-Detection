<?php

namespace App\Http\Controllers\Mobile\patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\DB;

class ProfilePatientController extends Controller
{
    public function show()
    {
        // Ambil data user beserta data detail pasiennya
        $user = User::with('patient')->find(auth()->id());

        return response()->json([
            'status' => 'success',
            'data' => $user
        ]);
    }

    public function update(Request $request)
    {
        $user = auth()->user();
        // Karena user ini punya role patient, kita ambil data patient-nya
        $patient = \App\Models\Patient::where('user_id', $user->id)->first();

        $request->validate([
            // Data User (Tabel Users)
            'name'  => 'required|string|max:100',
            'phone' => 'required|string|max:20',
            'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',

            // Data Pasien (Tabel Patients) - Field yang wajar diubah
            'address'                 => 'required|string',
            'city'                    => 'required|string|max:80',
            'province'                => 'required|string|max:80',
            'postal_code'             => 'nullable|string|max:10',
            'emergency_contact_name'  => 'nullable|string|max:100',
            'emergency_contact_phone' => 'nullable|string|max:20',
            'emergency_contact_relation' => 'nullable|string|max:50',
            'current_medications'     => 'nullable|string',
            'allergies'               => 'nullable|string',
            'insurance_provider'      => 'nullable|string|max:100',
            'insurance_number'        => 'nullable|string|max:50',
        ]);

        try {
            DB::beginTransaction();

            // 1. Update Tabel Users
            $user->name = $request->name;
            $user->phone = $request->phone;

            if ($request->hasFile('image')) {
                if ($user->profile_photo_path && Storage::disk('public')->exists($user->profile_photo_path)) {
                    Storage::disk('public')->delete($user->profile_photo_path);
                }
                $user->profile_photo_path = $request->file('image')->store('profile-photos', 'public');
            }
            $user->save();

            // 2. Update Tabel Patients
            if ($patient) {
                $patient->update([
                    'name'                    => $request->name, // Sinkronkan jika nama berubah
                    'phone'                   => $request->phone,
                    'address'                 => $request->address,
                    'city'                    => $request->city,
                    'province'                => $request->province,
                    'postal_code'             => $request->postal_code,
                    'emergency_contact_name'  => $request->emergency_contact_name,
                    'emergency_contact_phone' => $request->emergency_contact_phone,
                    'emergency_contact_relation' => $request->emergency_contact_relation,
                    'current_medications'     => $request->current_medications,
                    'allergies'               => $request->allergies,
                    'insurance_provider'      => $request->insurance_provider,
                    'insurance_number'        => $request->insurance_number,
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully',
                'data' => $user->load('patient')
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }

    
}