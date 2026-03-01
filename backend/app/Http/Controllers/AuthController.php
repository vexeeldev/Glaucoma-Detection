<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Patient;
use App\Models\Doctor;
use App\Models\Admin;
use App\Http\Requests\StoreUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Http\Resources\UserResource;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Password;
use Illuminate\Auth\Events\Registered;

class AuthController extends Controller
{
    /**
     * 📝 Register new user
     */
    public function register(StoreUserRequest $request): JsonResponse
    {
        $validated = $request->validated();

        try {
            DB::beginTransaction();

            // Create user
            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'phone' => $validated['phone'] ?? null,
                'role' => $validated['role'] ?? 'patient',
                'is_active' => true,
            ]);

            // Create profile based on role
            switch ($user->role) {
                case 'patient':
                    Patient::create(['user_id' => $user->id]);
                    break;
                case 'doctor':
                    Doctor::create([
                        'user_id' => $user->id,
                        'license_number' => 'TMP-' . strtoupper(uniqid()),
                    ]);
                    break;
                case 'admin':
                    Admin::create([
                        'user_id' => $user->id,
                        'admin_level' => 'staff'
                    ]);
                    break;
            }

            // Trigger email verification event
            event(new Registered($user));

            // Create token
            $token = $user->createToken('auth_token')->plainTextToken;

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Registration successful',
                'data' => [
                    'user' => new UserResource($user->load(['patient', 'doctor', 'admin'])),
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

    /**
     * 🔐 Login user
     */
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

            if (!$user->is_active) {
                Auth::logout();
                return response()->json([
                    'success' => false,
                    'message' => 'Your account is inactive'
                ], 403);
            }

            $user->tokens()->delete();

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'data' => [
                    'user' => new UserResource($user->load(['patient', 'doctor', 'admin'])),
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

    /**
     * 👤 Get current user
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load(['patient', 'doctor', 'admin']);
        
        return response()->json([
            'success' => true,
            'message' => 'User profile retrieved',
            'data' => new UserResource($user)
        ], 200);
    }

    /**
     * 🚪 Logout user
     */
    public function logout(Request $request): JsonResponse
    {
        try {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Logout successful'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Logout failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * 🔄 Update profile
     */
    public function updateProfile(UpdateUserRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $user = $request->user();

        try {
            DB::beginTransaction();

            // Update basic info
            if (isset($validated['name'])) {
                $user->name = $validated['name'];
            }
            if (isset($validated['phone'])) {
                $user->phone = $validated['phone'];
            }

            // Update password if provided
            if (isset($validated['new_password'])) {
                if (!Hash::check($validated['current_password'], $user->password)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Current password is incorrect'
                    ], 400);
                }
                $user->password = Hash::make($validated['new_password']);
            }

            // Admin updates
            if ($user->isAdmin() && isset($validated['role'])) {
                $user->role = $validated['role'];
            }
            if ($user->isAdmin() && isset($validated['is_active'])) {
                $user->is_active = $validated['is_active'];
            }

            $user->save();
            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully',
                'data' => new UserResource($user->fresh(['patient', 'doctor', 'admin']))
            ], 200);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Profile update failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * 📧 Send password reset link
     */
    public function forgotPassword(Request $request): JsonResponse
    {
        $request->validate(['email' => 'required|email']);

        $status = Password::sendResetLink(
            $request->only('email')
        );

        return $status === Password::RESET_LINK_SENT
            ? response()->json(['success' => true, 'message' => __($status)], 200)
            : response()->json(['success' => false, 'message' => __($status)], 400);
    }

    /**
     * 🔑 Reset password
     */
    public function resetPassword(Request $request): JsonResponse
    {
        $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => 'required|confirmed|min:8',
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function ($user, $password) {
                $user->password = Hash::make($password);
                $user->save();
            }
        );

        return $status === Password::PASSWORD_RESET
            ? response()->json(['success' => true, 'message' => __($status)], 200)
            : response()->json(['success' => false, 'message' => __($status)], 400);
    }
}