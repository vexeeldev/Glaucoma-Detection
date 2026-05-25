<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AppointmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'appointment_date' => $this->appointment_date,
            'status' => $this->appointment_status,
            'complaint' => $this->complaint ?? 'Tidak ada keluhan tertulis',
            'result_label' => $this->getLabelResult($this->appointment_status),
            
            // Data Pasien Lebih Lengkap
            'patient' => [
                'id' => $this->patient_id,
                'name' => $this->patient?->user?->name,
                'age' => $this->patient?->age ?? 'Data umur tidak tersedia',
                'gender' => $this->patient?->gender,
            ],

            // DATA BARU: Hasil Pemeriksaan AI (Muncul jika sudah diproses di Web Lab)
            'examination_result' => $this->whenLoaded('examination', function() {
                return [
                    'diagnosis' => $this->examination->result, // Glaukoma / Normal
                    'confidence' => $this->examination->confidence_score . '%',
                    'image_url' => $this->examination->image_path ? asset('storage/' . $this->examination->image_path) : null,
                    'analyzed_at' => $this->examination->created_at->format('d M Y H:i'),
                ];
            }),

            // DATA BARU: Riwayat Medis Singkat
            'medical_history' => $this->patient->appointments->map(function($history) {
                return [
                    'date' => $history->appointment_date,
                    'result' => $history->appointment_status,
                ];
            }),

            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
        ];
    }

    private function getLabelResult($status)
    {
        $status = strtolower($status ?? '');
        return match ($status) {
            'glaukoma' => 'Glaukoma',
            'normal'   => 'Normal',
            'completed' => 'Selesai',
            'confirmed' => 'Siap Analisis',
            default     => 'Proses',
        };
    }
} // Pastikan tidak ada koma di sini