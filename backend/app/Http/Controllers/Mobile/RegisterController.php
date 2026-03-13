<?php

namespace App\Http\Controllers\Mobile;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

use App\Models\User;
use App\Models\Patient;
use App\Models\Doctor;
use Illuminate\Support\Facades\Validator;
use App\Http\Resources\UserResource;

class RegisterController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [

            'name' => 'required|string|max:100',
            'email' => 'required|email|max:150|unique:users,email',
            'password' => 'required|string|min:6',

            'phone' => 'nullable|string|max:20',

            'nik' => 'nullable|string|max:16|unique:users,nik',
            'username' => 'nullable|string|max:50|unique:users,username',

            'date_of_birth' => 'nullable|date',
            'gender' => 'nullable|in:male,female',

            'address' => 'nullable|string',
            'city' => 'nullable|string|max:80',
            'province' => 'nullable|string|max:80',

            'religion' => 'nullable|string|max:50',
            'nationality' => 'nullable|string|max:50',

            'role' => 'required|in:patient,doctor'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $validated = $validator->validated();

        try {

            DB::beginTransaction();

            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'phone' => $validated['phone'] ?? null,

                'nik' => $validated['nik'] ?? null,
                'username' => $validated['username'] ?? null,
                'date_of_birth' => $validated['date_of_birth'] ?? null,
                'gender' => $validated['gender'] ?? null,

                'address' => $validated['address'] ?? null,
                'city' => $validated['city'] ?? null,
                'province' => $validated['province'] ?? null,

                'religion' => $validated['religion'] ?? null,
                'nationality' => $validated['nationality'] ?? 'Indonesia',

                'role' => $validated['role'],
                'is_active' => true
            ]);

            if ($user->role === 'patient') {

                Patient::create([
                    'user_id' => $user->id
                ]);

            } elseif ($user->role === 'doctor') {

                Doctor::create([
                    'user_id' => $user->id,
                    'license_number' => 'TMP-' . strtoupper(uniqid())
                ]);

            }

            $token = $user->createToken('mobile_token')->plainTextToken;

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Registration successful',
                'data' => [
                    'user' => new UserResource(
                        $user->load(['patient','doctor'])
                    ),
                    'token' => $token,
                    'token_type' => 'Bearer'
                ]
            ], 201);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([
                'success' => false,
                'message' => 'Registration failed',
                'error' => $e->getMessage()
            ], 500);

        }
    }
}
