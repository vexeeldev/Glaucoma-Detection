<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use Illuminate\Http\Request;

class AppointmentPageController extends Controller
{
    // LIST APPOINTMENTS

    public function index(Request $request)
    {
        $search = $request->search;
        $status = $request->status;
        $date = $request->date;

        $appointments = Appointment::query()

            ->with([
                'patient.user:id,name',
                'doctor.user:id,name',
                'payment:id,appointment_id,payment_status'
            ])

            ->when($search, function ($query) use ($search) {

                $query->where(function ($q) use ($search) {

                    $q->whereHas('patient.user', function ($patient) use ($search) {

                        $patient->where(
                            'name',
                            'like',
                            "%{$search}%"
                        );

                    })

                    ->orWhereHas('doctor.user', function ($doctor) use ($search) {

                        $doctor->where(
                            'name',
                            'like',
                            "%{$search}%"
                        );

                    });

                });

            })

            ->when($status, function ($query) use ($status) {

                $query->where(
                    'appointment_status',
                    $status
                );

            })

            ->when($date, function ($query) use ($date) {

                $query->whereDate(
                    'appointment_date',
                    $date
                );

            })

            ->latest()

            ->paginate(10);

        $data = $appointments->through(function ($appointment) {

            return [

                'id' => $appointment->id,

                'patient' =>
                    $appointment->patient?->user?->name,

                'doctor' =>
                    $appointment->doctor?->user?->name,

                'date' =>
                    $appointment->appointment_date,

                'time' =>
                    $appointment->appointment_time,

                'status' =>
                    $appointment->appointment_status,

                'payment' =>
                    $appointment->payment?->payment_status,
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Appointments fetched successfully',
            'data' => $data,
            'pagination' => [
                'current_page' =>
                    $appointments->currentPage(),

                'last_page' =>
                    $appointments->lastPage(),

                'per_page' =>
                    $appointments->perPage(),

                'total' =>
                    $appointments->total(),
            ]
        ]);
    }

    // DETAIL APPOINTMENT

    public function show($id)
    {
        $appointment = Appointment::with([

            'patient.user',
            'doctor.user',
            'payment',
            'examination.fundusImages',
            'examination.analysisResults'

        ])->findOrFail($id);

        return response()->json([

            'success' => true,
            'message' => 'Appointment detail fetched successfully',
            'data' => [
                'id' => $appointment->id,
                // PATIENT

                'patient' => [
                    'name' =>
                        $appointment->patient?->user?->name,

                    'email' =>
                        $appointment->patient?->user?->email,

                    'phone' =>
                        $appointment->patient?->user?->phone,

                    'medical_history' =>
                        $appointment->patient?->medical_history,
                ],

                // DOCTOR

                'doctor' => [

                    'name' =>
                        $appointment->doctor?->user?->name,

                    'email' =>
                        $appointment->doctor?->user?->email,

                    'phone' =>
                        $appointment->doctor?->user?->phone,

                    'license_number' =>
                        $appointment->doctor?->license_number,
                ],

                // APPOINTMENT

                'appointment' => [

                    'date' =>
                        $appointment->appointment_date,

                    'time' =>
                        $appointment->appointment_time,

                    'status' =>
                        $appointment->appointment_status,

                    'patient_complaint' =>
                        $appointment->patient_complaint,

                    'doctor_notes' =>
                        $appointment->doctor_notes,

                    'rejection_reason' =>
                        $appointment->rejection_reason,
                ],

                // PAYMENT

                'payment' => [

                    'invoice_number' =>
                        $appointment->payment?->invoice_number,

                    'amount' =>
                        $appointment->payment?->amount,

                    'payment_status' =>
                        $appointment->payment?->payment_status,

                    'payment_method' =>
                        $appointment->payment?->payment_method,

                    'paid_at' =>
                        $appointment->payment?->paid_at,
                ],

                // EXAMINATION

                'examination' => [

                    'id' =>
                        $appointment->examination?->id,

                    'status' =>
                        $appointment->examination?->status,

                    'clinical_notes' =>
                        $appointment->examination?->clinical_notes,

                    'doctor_diagnosis' =>
                        $appointment->examination?->doctor_diagnosis,

                    'recommendation' =>
                        $appointment->examination?->recommendation,
                ],

                //  FUNDUS IMAGES

                'fundus_images' =>

                    $appointment->examination?->fundusImages
                    ?->map(function ($image) {

                        return [
                            'id' => $image->id,
                            'eye_side' => $image->eye_side,
                            'image_url' => $image->file_url,
                        ];
                    }),

                // ANALYSIS RESULTS

                'analysis_results' =>

                    $appointment->examination?->analysisResults
                    ?->map(function ($analysis) {

                        return [

                            'prediction' =>
                                $analysis->prediction,

                            'confidence_score' =>
                                $analysis->confidence_score,

                            'glaucoma_probability' =>
                                $analysis->glaucoma_probability,

                            'normal_probability' =>
                                $analysis->normal_probability,
                        ];
                    }),
            ]
        ]);
    }
}