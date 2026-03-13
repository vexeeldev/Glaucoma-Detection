<?php

namespace App\Http\Controllers\Desktop;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

use App\Models\{User, Admin};
use App\Http\Resources\UserResource;

class RegisterAdminController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([

            'name' => 'required|string|max:100',
            'email' => 'required|email|max:150|unique:users,email',
            'password' => 'required|string|min:6',

            'phone' => 'nullable|string|max:20',
            'username' => 'nullable|string|max:50|unique:users,username',

            'gender' => 'nullable|in:male,female',
            'city' => 'nullable|string|max:80',
            'province' => 'nullable|string|max:80',
            'admin_level' => 'nullable|string|max:50'
        ]);

        try {

            DB::beginTransaction();

            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),

                'phone' => $validated['phone'] ?? null,
                'username' => $validated['username'] ?? null,

                'gender' => $validated['gender'] ?? null,
                'city' => $validated['city'] ?? null,
                'province' => $validated['province'] ?? null,

                'role' => 'admin',
                'is_active' => true
            ]);

            Admin::create([
                'user_id' => $user->id,
                'admin_level' => $validated['admin_level'] ?? 'staff'
            ]);

            $token = $user->createToken('desktop_admin_token')->plainTextToken;

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Admin registration successful',
                'data' => [
                    'user' => new UserResource(
                        $user->load('admin')
                    ),
                    'token' => $token,
                    'token_type' => 'Bearer'
                ]
            ], 201);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Admin registration failed',
                'error' => $e->getMessage()
            ], 500);

        }
    }
}
