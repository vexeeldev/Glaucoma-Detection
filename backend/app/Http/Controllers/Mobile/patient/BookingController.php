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
        $user = auth()->user(); // Ambil user yang login
        
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

        // Filter OTOMATIS berdasarkan Role yang login
        if ($user->role == 'patient') {
            // Cari ID patient yang terhubung dengan User ini
            $patientId = DB::table('patients')->where('user_id', $user->id)->value('id');
            $query->where('appointments.patient_id', $patientId);

        } elseif ($user->role == 'doctor') {
            // Cari ID doctor yang terhubung dengan User ini
            $doctorId = DB::table('doctors')->where('user_id', $user->id)->value('id');
            $query->where('appointments.doctor_id', $doctorId);
        }

        // Filter tambahan (Status & Tanggal) tetep bisa dipake
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
        // 1. Validasi input tambahan untuk 'package_type'
        $request->validate([
            'patient_id'        => 'required|exists:patients,id',
            'doctor_id'         => 'required|exists:doctors,id',
            'appointment_date'  => 'required|date|after_or_equal:today',
            'appointment_time'  => 'required',
            'package_type'      => 'required|in:basic,screening,complete', // basic, screening, atau complete
        ]);

        try {
            return DB::transaction(function () use ($request) {
                // 2. Lock Schedule untuk mencegah Race Condition (Double Booking)
                $slot = DB::table('doctor_schedules')
                    ->where('doctor_id', $request->doctor_id)
                    ->where('start_time', $request->appointment_time)
                    ->where('day_of_week', strtolower(date('l', strtotime($request->appointment_date))))
                    ->lockForUpdate()
                    ->first();

                if (!$slot || !$slot->is_available) {
                    return response()->json(['message' => 'Jadwal dokter tidak ditemukan atau tidak tersedia'], 422);
                }

                // 3. Tentukan Biaya Paket (Berdasarkan data JEC 2026 yang kamu temukan)
                $packagePrices = [
                    'basic'     => 150000, // Konsultasi + Tonometri
                    'screening' => 500000, // Dasar + GlaucoScan AI Skrining
                    'complete'  => 1200000 // Full OCT + Perimetri
                ];

                $selectedPrice = $packagePrices[$request->package_type];

                // 4. Ambil Jasa Dokter (Consultation Fee) dari tabel doctors
                $doctor = DB::table('doctors')->where('id', $request->doctor_id)->first();
                
                // Total = Harga Paket + Biaya Dokter (Opsional, tergantung kebijakan RS kamu)
                $totalAmount = $selectedPrice + ($doctor->consultation_fee ?? 0);

                // 5. Insert Appointment
                $bookingId = DB::table('appointments')->insertGetId([
                    'patient_id'         => $request->patient_id,
                    'doctor_id'          => $request->doctor_id,
                    'appointment_date'   => $request->appointment_date,
                    'appointment_time'   => $request->appointment_time,
                    'patient_complaint'  => $request->patient_complaint,
                    'appointment_status' => 'pending_payment', // Menunggu pembayaran
                    'created_at'         => now(),
                    'updated_at'         => now()
                ]);

                // 6. OTOMATIS: Buat Record Payment (Invoice)
                $invoiceNumber = 'INV-' . strtoupper(Str::random(10));
                DB::table('payments')->insert([
                    'appointment_id' => $bookingId,
                    'invoice_number' => $invoiceNumber,
                    'amount'         => $totalAmount, // Nilai dinamis hasil hitungan di atas
                    'payment_status' => 'unpaid',
                    'created_at'     => now(),
                    'updated_at'     => now()
                ]);

                return response()->json([
                    'status'  => 'success',
                    'message' => 'Booking berhasil! Invoice telah dibuat.',
                    'data'    => [
                        'booking_id'   => $bookingId,
                        'invoice'      => $invoiceNumber,
                        'package'      => $request->package_type,
                        'total_amount' => $totalAmount
                    ]
                ], 201);
            });

        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Gagal membuat booking: ' . $e->getMessage()
            ], 500);
        }
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

    public function getQueueStatus($appointment_id)
    {
        try {
            // 1. Ambil data janji temu pasien saat ini
            $currentAppointment = DB::table('appointments')
                ->where('id', $appointment_id)
                ->first();

            if (!$currentAppointment) {
                return response()->json(['message' => 'Janji temu tidak ditemukan'], 404);
            }

            // Jika statusnya belum bayar, belum punya nomor antrean
            if ($currentAppointment->appointment_status === 'pending_payment') {
                return response()->json([
                    'status' => 'success',
                    'message' => 'Silakan selesaikan pembayaran untuk mendapatkan nomor antrean.'
                ]);
            }

            $date = $currentAppointment->appointment_date;
            $doctorId = $currentAppointment->doctor_id;

            // 2. HITUNG NOMOR ANTREAN USER
            // Menghitung berapa banyak janji temu yang sah (confirmed/completed/glaukoma/normal) 
            // pada hari itu sebelum atau sama dengan waktu booking milik pasien ini
            $userQueueNumber = DB::table('appointments')
                ->where('doctor_id', $doctorId)
                ->where('appointment_date', $date)
                ->whereNotIn('appointment_status', ['pending_payment', 'cancelled', 'rejected'])
                ->where('created_at', '<=', $currentAppointment->created_at)
                ->count();

            // 3. HITUNG ANTREAN YANG SEDANG DIPERIKSA (NOW SERVING)
            // Kita cari pasien yang berstatus 'confirmed' (sedang menunggu/diperiksa di lab) yang paling pertama/paling awal pada hari itu
            $currentServingAppointment = DB::table('appointments')
                ->where('doctor_id', $doctorId)
                ->where('appointment_date', $date)
                ->where('appointment_status', 'confirmed')
                ->orderBy('created_at', 'asc')
                ->first();

            // Jika tidak ada yang 'confirmed' lagi pada hari itu, artinya antrean hari itu sudah selesai semua atau belum mulai
            if ($currentServingAppointment) {
                // Hitung nomor antrean untuk pasien yang sedang dilayani tersebut
                $nowServingNumber = DB::table('appointments')
                    ->where('doctor_id', $doctorId)
                    ->where('appointment_date', $date)
                    ->whereNotIn('appointment_status', ['pending_payment', 'cancelled', 'rejected'])
                    ->where('created_at', '<=', $currentServingAppointment->created_at)
                    ->count();
            } else {
                // Jika tidak ada status 'confirmed', bisa jadi sedang kosong atau semua sudah 'completed'
                $nowServingNumber = DB::table('appointments')
                    ->where('doctor_id', $doctorId)
                    ->where('appointment_date', $date)
                    ->whereIn('appointment_status', ['glaukoma', 'normal', 'completed'])
                    ->count();
            }

            // 4. HITUNG SISA ANTREAN (Berapa orang lagi sebelum giliran user)
            $remainingQueue = $userQueueNumber - $nowServingNumber;
            if ($remainingQueue < 0) $remainingQueue = 0; // Proteksi jika user sudah selesai diperiksa

            return response()->json([
                'status' => 'success',
                'data' => [
                    'appointment_id'     => $currentAppointment->id,
                    'user_queue_number'  => $userQueueNumber,  // Nomor Antrean Saya
                    'current_serving'    => $nowServingNumber,   // Antrean yang Sekarang Diperiksa
                    'remaining_queue'    => $remainingQueue,    // Sisa Antrean Sebelum Saya
                    'status_pasien'      => $currentAppointment->appointment_status
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 500);
        }
    }
}