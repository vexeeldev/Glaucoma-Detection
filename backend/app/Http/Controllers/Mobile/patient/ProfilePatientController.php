<?php

namespace App\Http\Controllers\Mobile\patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
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

        $request->validate([
            'name' => 'string|max:255',
            'phone' => 'string|max:15',
            'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        // Update Nama & Phone
        $user->update($request->only('name', 'phone'));

        // Logic Update Foto (Jika ada)
        if ($request->hasFile('image')) {
            // Hapus foto lama jika bukan default
            if ($user->profile_photo_path && $user->profile_photo_path !== 'default.png') {
                Storage::disk('public')->delete($user->profile_photo_path);
            }

            $path = $request->file('image')->store('profile-photos', 'public');
            $user->update(['profile_photo_path' => $path]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Profil berhasil diperbarui',
            'data' => $user
        ]);
    }
}