<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

use App\Models\User;
use App\Models\Doctor;
use App\Models\Schedule;

class ManagementDoctorController extends Controller
{
    public function index(Request $request)
    {
        $search = $request->search;
        $perPage = $request->per_page ?? 10;
        $doctors = Doctor::with([
            'user',
            'specialization'
        ])

        ->when($search, function ($query) use ($search) {
            $query->whereHas('user', function ($q) use ($search) {
                $q->where('name', 'LIKE', "%{$search}%")
                  ->orWhere('email', 'LIKE', "%{$search}%");
            });

        })

        ->latest()
        ->paginate($perPage);

        $formattedDoctors = $doctors->through(function ($doctor) {

            return [
                'id' => $doctor->id,
                'name' => $doctor->user?->name,
                'email' => $doctor->user?->email,
                'phone' => $doctor->user?->phone,
                'specialization' => $doctor->specialization?->name,
                'specialization_id' => $doctor->specialization_id,
                'license' => $doctor->license_number,
                'exp' => $doctor->experience_years . ' Tahun',
                'experience_years' => $doctor->experience_years,
                'fee' => 'Rp ' . number_format($doctor->consultation_fee, 0, ',', '.'),
                'consultation_fee' => $doctor->consultation_fee,
                'bio' => $doctor->bio,
                'is_available' => $doctor->is_available,
                'status' => $doctor->is_available
                    ? 'active'
                    : 'nonactive',

                'created_at' => $doctor->created_at
                    ? $doctor->created_at->format('Y-m-d H:i:s')
                    : null,

            ];

        });

        return response()->json([

            'status' => 'success',
            'data' => $formattedDoctors->items(),

            'pagination' => [
                'current_page' => $doctors->currentPage(),
                'last_page' => $doctors->lastPage(),
                'per_page' => $doctors->perPage(),
                'total' => $doctors->total(),
            ]

        ]);
    }

    public function show($id)
    {
        $doctor = Doctor::with([
            'user',
            'specialization'
        ])->find($id);

        if (!$doctor) {

            return response()->json([

                'status' => 'error',
                'message' => 'Dokter tidak ditemukan'

            ], 404);
        }

        return response()->json([

            'status' => 'success',
            'data' => [

                'id' => $doctor->id,
                'name' => $doctor->user?->name,
                'email' => $doctor->user?->email,
                'phone' => $doctor->user?->phone,
                'specialization' => $doctor->specialization?->name,
                'specialization_id' => $doctor->specialization_id,
                'license_number' => $doctor->license_number,
                'experience_years' => $doctor->experience_years,
                'consultation_fee' => $doctor->consultation_fee,
                'bio' => $doctor->bio,
                'is_available' => $doctor->is_available,

            ]

        ]);
    }

    public function store(Request $request)
    {
        $request->validate([

            'name' => 'required|string|max:100',
            'email' => 'required|email|unique:users,email',
            'phone' => 'nullable|string|max:20',
            'password' => 'required|min:6',
            'specialization_id' => 'required|exists:specializations,id',
            'license_number' => 'required|unique:doctors,license_number',
            'experience_years' => 'required|integer|min:0',
            'consultation_fee' => 'required|numeric|min:0',
            'bio' => 'nullable|string',

        ]);

        DB::beginTransaction();

        try {

            $user = User::create([

                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'role' => 'doctor',
                'is_active' => true,

            ]);

            $doctor = Doctor::create([

                'user_id' => $user->id,
                'specialization_id' => $request->specialization_id,
                'license_number' => $request->license_number,
                'experience_years' => $request->experience_years,
                'consultation_fee' => $request->consultation_fee,
                'bio' => $request->bio,
                'is_available' => true,

            ]);

            DB::commit();

            return response()->json([

                'status' => 'success',
                'message' => 'Dokter berhasil ditambahkan',
                'data' => [
                    'id' => $doctor->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ]

            ], 201);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([

                'status' => 'error',
                'message' => $e->getMessage()

            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        $doctor = Doctor::with('user')->find($id);

        if (!$doctor) {

            return response()->json([

                'status' => 'error',
                'message' => 'Dokter tidak ditemukan'
            ], 404);
        }

        $request->validate([

            'name' => 'required|string|max:100',
            'email' => 'required|email|unique:users,email,' . $doctor->user_id,
            'phone' => 'nullable|string|max:20',
            'specialization_id' => 'required|exists:specializations,id',
            'license_number' => 'required|unique:doctors,license_number,' . $doctor->id,
            'experience_years' => 'required|integer|min:0',
            'consultation_fee' => 'required|numeric|min:0',
            'bio' => 'nullable|string',

        ]);

        DB::beginTransaction();

        try {

            $doctor->user->update([

                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,

            ]);

            $doctor->update([

                'specialization_id' => $request->specialization_id,
                'license_number' => $request->license_number,
                'experience_years' => $request->experience_years,
                'consultation_fee' => $request->consultation_fee,
                'bio' => $request->bio,

            ]);

            DB::commit();

            return response()->json([

                'status' => 'success',
                'message' => 'Dokter berhasil diupdate'

            ]);

        } catch (\Exception $e) {

            DB::rollBack();

            return response()->json([

                'status' => 'error',
                'message' => $e->getMessage()

            ], 500);
        }
    }

    public function destroy($id)
    {
        $doctor = Doctor::find($id);

        if (!$doctor) {

            return response()->json([

                'status' => 'error',
                'message' => 'Dokter tidak ditemukan'

            ], 404);
        }

        $doctor->delete();

        return response()->json([

            'status' => 'success',
            'message' => 'Dokter berhasil dihapus'

        ]);
    }

    public function schedules($doctorId)
    {
        $schedules = Schedule::where('doctor_id', $doctorId)
            ->orderByRaw("
                CASE day_of_week
                    WHEN 'monday' THEN 1
                    WHEN 'tuesday' THEN 2
                    WHEN 'wednesday' THEN 3
                    WHEN 'thursday' THEN 4
                    WHEN 'friday' THEN 5
                    WHEN 'saturday' THEN 6
                    WHEN 'sunday' THEN 7
                END
            ")
            ->get();

        return response()->json([

            'status' => 'success',
            'data' => $schedules

        ]);
    }

    public function storeSchedule(Request $request, $doctorId)
    {
        $request->validate([

            'day_of_week' => 'required',
            'start_time' => 'required',
            'end_time' => 'required',
            'max_patients' => 'required|integer|min:1',

        ]);

        $schedule = Schedule::create([

            'doctor_id' => $doctorId,
            'day_of_week' => $request->day_of_week,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
            'max_patients' => $request->max_patients,
            'is_available' => true,

        ]);

        return response()->json([

            'status' => 'success',
            'message' => 'Jadwal berhasil ditambahkan',
            'data' => $schedule

        ], 201);
    }

    public function updateSchedule(Request $request, $scheduleId)
    {
        $schedule = Schedule::find($scheduleId);

        if (!$schedule) {

            return response()->json([

                'status' => 'error',
                'message' => 'Jadwal tidak ditemukan'

            ], 404);
        }

        $schedule->update([

            'day_of_week' => $request->day_of_week,
            'start_time' => $request->start_time,
            'end_time' => $request->end_time,
            'max_patients' => $request->max_patients,
            'is_available' => $request->is_available,

        ]);

        return response()->json([

            'status' => 'success',
            'message' => 'Jadwal berhasil diupdate',
            'data' => $schedule

        ]);
    }

    public function destroySchedule($scheduleId)
    {
        $schedule = Schedule::find($scheduleId);

        if (!$schedule) {

            return response()->json([

                'status' => 'error',
                'message' => 'Jadwal tidak ditemukan'

            ], 404);
        }

        $schedule->delete();

        return response()->json([

            'status' => 'success',
            'message' => 'Jadwal berhasil dihapus'

        ]);
    }
}