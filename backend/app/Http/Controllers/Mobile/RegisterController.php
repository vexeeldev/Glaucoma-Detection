<?php

namespace App\Http\Controllers\Mobile;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

use App\Models\User;
use App\Models\Patient;
use App\Models\Doctor;
use App\Http\Resources\UserResource;

class RegisterController extends Controller
{
    public function register(Request $request): JsonResponse
    {

        $validator = Validator::make($request->all(), [

            // USER
            'name' => 'required|string|max:100',
            'email' => 'required|email|max:150|unique:users,email',
            'password' => 'required|string|min:6',
            'phone' => 'required|string|max:20',
            'username' => 'required|string|max:50|unique:users,username',

            'role' => 'required|in:patient,doctor',

            // PATIENT
            'nik' => 'required_if:role,patient|string|size:16|unique:users,nik',
            'date_of_birth' => 'required_if:role,patient|date',
            'gender' => 'required_if:role,patient|in:male,female',
            'address' => 'required_if:role,patient|string',
            'city' => 'required_if:role,patient|string|max:80',
            'province' => 'required_if:role,patient|string|max:80',

            'postal_code' => 'nullable|string|max:10',

            'emergency_contact_name' => 'nullable|string|max:100',
            'emergency_contact_phone' => 'nullable|string|max:20',
            'emergency_contact_relation' => 'nullable|string|max:50',

            'blood_type' => 'nullable|in:A,B,AB,O',
            'medical_history' => 'nullable|string',
            'current_medications' => 'nullable|string',
            'allergies' => 'nullable|string',

            'insurance_provider' => 'nullable|string|max:100',
            'insurance_number' => 'nullable|string|max:50',

            'religion' => 'nullable|string|max:50',
            'nationality' => 'nullable|string|max:50'

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

            // dd($validated);

            // CREATE USER
            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'phone' => $validated['phone'],
                'username' => $validated['username'],
                'nik' => $validated['nik'],
                'date_of_birth' => $validated['date_of_birth'],
                'gender' => $validated['gender'],
                'address' => $validated['address'],
                'city' => $validated['city'],
                'province' => $validated['province'],
                'religion' => $validated['religion'] ?? null,
                'nationality' => $validated['nationality'] ?? 'Indonesia',
                'role' => $validated['role'],
                'is_active' => true
            ]);

            // CREATE PATIENT
            if ($user->role === 'patient') {

                Patient::create([
                    'name' => $validated['name'],
                    'user_id' => $user->id,
                    'date_of_birth' => $validated['date_of_birth'],
                    'gender' => $validated['gender'],
                    'address' => $validated['address'],
                    'city' => $validated['city'],
                    'province' => $validated['province'],
                    'postal_code' => $validated['postal_code'] ?? null,
                    'phone' => $validated['phone'],

                    'emergency_contact_name' => $validated['emergency_contact_name'] ?? null,
                    'emergency_contact_phone' => $validated['emergency_contact_phone'] ?? null,
                    'emergency_contact_relation' => $validated['emergency_contact_relation'] ?? null,

                    'blood_type' => $validated['blood_type'] ?? null,
                    'medical_history' => $validated['medical_history'] ?? null,
                    'current_medications' => $validated['current_medications'] ?? null,
                    'allergies' => $validated['allergies'] ?? null,

                    'insurance_provider' => $validated['insurance_provider'] ?? null,
                    'insurance_number' => $validated['insurance_number'] ?? null,
                
                ]);

            }

            // CREATE DOCTOR
            if ($user->role === 'doctor') {

                Doctor::create([
                    'user_id' => $user->id,
                    'license_number' => 'TMP-' . strtoupper(uniqid())
                ]);

            }

            // TOKEN
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