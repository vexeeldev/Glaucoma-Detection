<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;

class ManagementUserController extends Controller
{
    public function index(Request $request)
    {
        $search = $request->search;
        $role = $request->role;
        $status = $request->status;
        $perPage = $request->per_page ?? 10;

        $users = User::query()
            ->when($search, function ($query) use ($search) {
                $query->where(function ($q) use ($search) {

                    $q->where('name', 'LIKE', "%{$search}%")
                      ->orWhere('email', 'LIKE', "%{$search}%")
                      ->orWhere('phone', 'LIKE', "%{$search}%");

                });
            })

            ->when($role, function ($query) use ($role) {
                $query->where('role', $role);

            })

            ->when($status, function ($query) use ($status) {
              if ($status === 'active') {
                $query->where('is_active', true);
                }
                
                if ($status === 'nonactive') {
                  $query->where('is_active', false);
                  }
                  })

            ->latest()
            ->paginate($perPage);
        $formattedUsers = $users->through(function ($user) {

            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'role' => ucfirst($user->role),
                'status' => $user->is_active
                    ? 'active'
                    : 'nonactive',
                'created_at' => $user->created_at
                    ? $user->created_at->format('Y-m-d H:i:s')
                    : null,
            ];
        });

        return response()->json([

            'status' => 'success',
            'data' => $formattedUsers->items(),
            'pagination' => [
                'current_page' => $users->currentPage(),
                'last_page' => $users->lastPage(),
                'per_page' => $users->perPage(),
                'total' => $users->total(),
                'from' => $users->firstItem(),
                'to' => $users->lastItem(),
            ]

        ]);
    }

    public function show($id)
    {
        $user = User::find($id);

        if (!$user) {

            return response()->json([
                'status' => 'error',
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        return response()->json([

            'status' => 'success',

            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'role' => $user->role,
                'is_active' => $user->is_active,
                'created_at' => $user->created_at,
                'updated_at' => $user->updated_at,
            ]

        ]);
    }

    public function updateStatus($id)
    {
        $user = User::find($id);

        if (!$user) {

            return response()->json([

                'status' => 'error',
                'message' => 'User tidak ditemukan'

            ], 404);
        }

        $user->is_active = !$user->is_active;

        $user->save();

        return response()->json([

            'status' => 'success',

            'message' => $user->is_active
                ? 'User berhasil diaktifkan'
                : 'User berhasil dinonaktifkan',

            'data' => [
                'id' => $user->id,
                'is_active' => $user->is_active
            ]

        ]);
    }

    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {

            return response()->json([
                'status' => 'error',
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        $user->delete();

        return response()->json([

            'status' => 'success',
            'message' => 'User berhasil dihapus'

        ]);
    }
}