<?php

namespace App\Http\Controllers\Mobile\patient;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        $user = auth()->user();

        // 1. Ambil Janji Temu Terdekat (Upcoming)
        $nextAppointment = Appointment::with('doctor')
            ->whereHas('patient', function($q) use ($user) {
                $q->where('user_id', $user->id);
            })
            ->whereIn('appointment_status', ['confirmed', 'pending_confirmation'])
            ->where('appointment_date', '>=', now()->toDateString())
            ->orderBy('appointment_date', 'asc')
            ->first();

        // 2. Hitung jumlah notif belum dibaca
        $unreadNotifications = DB::table('notifications')
            ->where('user_id', $user->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'status' => 'success',
            'data' => [
                'user_name' => $user->name,
                'unread_notifications' => $unreadNotifications,
                'upcoming_appointment' => $nextAppointment ? [
                    'id' => $nextAppointment->id,
                    'doctor' => $nextAppointment->doctor->name,
                    'date' => \Carbon\Carbon::parse($nextAppointment->appointment_date)->translatedFormat('d F Y'),
                    'time' => date('H:i', strtotime($nextAppointment->appointment_time)),
                ] : null,
            ]
        ]);
    }
}