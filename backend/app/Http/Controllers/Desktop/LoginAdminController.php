<?php

namespace App\Http\Controllers\Desktop;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use App\Http\Resources\UserResource;

class LoginAdminController extends Controller
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

            if ($user->role !== 'admin') {
                Auth::logout();

                return response()->json([
                    'success' => false,
                    'message' => 'Access denied. Admin only.'
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
            $token = $user->createToken('desktop_admin_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Admin login successful',
                'data' => [
                    'user' => new UserResource(
                        $user->load(['admin'])
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
