<?php

namespace App\Http\Controllers\Mobile\patient;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    // 1. LIST BOOKING (Filter by Role manual untuk test)
    // GET: /api/patient/booking?role=patient&user_id=1
    public function index(Request $request)
    {
        $query = DB::table('appointments')
            ->join('doctors', 'appointments.doctor_id', '=', 'doctors.id')
            ->join('users as doctor_user', 'doctors.user_id', '=', 'doctor_user.id')
            ->join('patients', 'appointments.patient_id', '=', 'patients.id')
            ->join('users as patient_user', 'patients.user_id', '=', 'patient_user.id')
            ->select(
                'appointments.*', 
                'doctor_user.name as doctor_name', 
                'patient_user.name as patient_name'
            );

        // Simulasi filter role
        if ($request->role == 'patient') {
            $query->where('appointments.patient_id', $request->patient_id);
        } elseif ($request->role == 'doctor') {
            $query->where('appointments.doctor_id', $request->doctor_id);
        }

        if ($request->status) $query->where('appointment_status', $request->status);
        if ($request->date) $query->where('appointment_date', $request->date);

        return response()->json($query->paginate($request->limit ?? 10));
    }

    // 2. DETAIL BOOKING
    public function show($id)
    {
        $booking = DB::table('appointments')->where('id', $id)->first();
        if (!$booking) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        // Ambil data pendukung (Payment & Examination)
        $payment = DB::table('payments')->where('appointment_id', $id)->first();
        $examination = DB::table('examinations')->where('appointment_id', $id)->first();

        return response()->json([
            'booking' => $booking,
            'payment' => $payment,
            'examination' => $examination
        ]);
    }

    // 3. STORE (Buat Booking + Payment)
    public function store(Request $request)
    {
        return DB::transaction(function () use ($request) {
            // Lock Schedule untuk Race Condition
            $slot = DB::table('doctor_schedules')
                ->where('doctor_id', $request->doctor_id)
                ->where('start_time', $request->appointment_time)
                ->lockForUpdate()->first();

            // Insert Appointment
            $bookingId = DB::table('appointments')->insertGetId([
                'patient_id' => $request->patient_id,
                'doctor_id' => $request->doctor_id,
                'appointment_date' => $request->appointment_date,
                'appointment_time' => $request->appointment_time,
                'patient_complaint' => $request->patient_complaint,
                'appointment_status' => 'pending_payment',
                'created_at' => now()
            ]);

            // OTOMATIS: Buat Record Payment (Unpaid)
            $invoice = 'INV-' . strtoupper(Str::random(10));
            DB::table('payments')->insert([
                'appointment_id' => $bookingId,
                'invoice_number' => $invoice,
                'amount' => 150000, // Misal flat dulu
                'payment_status' => 'unpaid',
                'created_at' => now()
            ]);

            return response()->json(['message' => 'Booking & Invoice dibuat', 'id' => $bookingId, 'invoice' => $invoice], 201);
        });
    }

    // 4. CANCEL (Oleh Pasien)
    public function destroy($id)
    {
        $booking = DB::table('appointments')->where('id', $id)->first();
        if (in_array($booking->appointment_status, ['pending_payment', 'pending_confirmation'])) {
            DB::table('appointments')->where('id', $id)->update(['appointment_status' => 'cancelled']);
            return response()->json(['message' => 'Booking dibatalkan']);
        }
        return response()->json(['message' => 'Gagal: Status sudah diproses'], 422);
    }

    // 5. CONFIRM (Oleh Dokter)
    public function confirm($id)
    {
        DB::table('appointments')->where('id', $id)->update(['appointment_status' => 'confirmed']);
        return response()->json(['message' => 'Booking dikonfirmasi dokter']);
    }

    // 6. REJECT (Oleh Dokter)
    public function reject(Request $request, $id)
    {
        DB::table('appointments')->where('id', $id)->update([
            'appointment_status' => 'rejected',
            'rejection_reason' => $request->rejection_reason
        ]);
        return response()->json(['message' => 'Booking ditolak dokter']);
    }

    // 7. COMPLETE (Selesai + Auto Examination)
    public function complete($id)
    {
        return DB::transaction(function () use ($id) {
            // 1. Ambil data appointment-nya dulu buat dapet patient_id dan doctor_id
            $appointment = DB::table('appointments')->where('id', $id)->first();

            if (!$appointment) {
                return response()->json(['message' => 'Appointment tidak ditemukan'], 404);
            }

            // 2. Update status appointment
            DB::table('appointments')->where('id', $id)->update([
                'appointment_status' => 'completed'
            ]);
            
            // 3. Insert ke examinations dengan membawa patient_id (dan doctor_id kalau perlu)
            // Sesuaikan dengan semua kolom NOT NULL di tabel examinations kamu
            $examId = DB::table('examinations')->insertGetId([
                'appointment_id' => $id,
                'patient_id'     => $appointment->patient_id, // INI YANG TADI KURANG
                'doctor_id'      => $appointment->doctor_id,  // Biasanya doctor_id juga NOT NULL
                'status'         => 'pending',                // Sesuaikan default status di tabelmu
                'created_at'     => now(),
                'updated_at'     => now()
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Pemeriksaan selesai, record medis dibuat', 
                'exam_id' => $examId
            ]);
        });
    }
}