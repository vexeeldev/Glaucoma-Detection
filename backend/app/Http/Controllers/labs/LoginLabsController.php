<?php

namespace App\Http\Controllers\labs;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use App\Http\Resources\UserResource;
use App\Http\Resources\ActivityLogResource;
use App\Models\User;

class LoginLabsController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        try {

            if (!Auth::attempt($validated)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid email or password'
                ], 401);
            }

            $user = Auth::user();
            $user->load('admin');

            if (!$user->admin || !in_array($user->admin->admin_level , ['adminops', 'superadmin'])) {
                Auth::logout();

                return response()->json([
                    'success' => false,
                    'message' => 'Access denied. Akun Anda tidak memiliki otoritas portal ini.'
                ], 403);
            }

            if (!$user->is_active) {
                Auth::logout();

                return response()->json([
                    'success' => false,
                    'message' => 'Your account is inactive'
                ], 403);
            }

            $user->tokens()->delete();
            $token = $user->createToken('lab_admin_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Staff login successful',
                'data' => [
                    'user' => new UserResource(
                        $user->load('admin')
                    ),
                    'token' => $token,
                    'token_type' => 'Bearer'
                ]
            ], 200);

        } catch (\Exception $e) {

            return response()->json([
                'success' => false,
                'message' => 'Login failed',
                'error' => $e->getMessage()
            ], 500);

        }
    }
}
