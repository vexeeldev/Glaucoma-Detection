<?php

namespace App\Http\Controllers\Mobile\patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class ForgotPasswordController extends Controller
{
    public function reset(Request $request)
    {
        // 1. Validasi Input
        $validator = Validator::make($request->all(), [
            'email'    => 'required|email|exists:users,email',
            'nik'      => 'required|string|size:16',
            'phone'    => 'required|string',
            'password' => 'required|string|min:6|confirmed', // Harus ada password_confirmation
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // 2. Cari User yang Email, NIK, dan HP-nya cocok sekaligus
        $user = User::where('email', $request->email)
                    ->where('nik', $request->nik)
                    ->where('phone', $request->phone)
                    ->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Data identitas (Email/NIK/HP) tidak cocok dengan record kami.'
            ], 404);
        }

        // 3. Update Password
        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil direset. Silakan login kembali.'
        ]);
    }
}