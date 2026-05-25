<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DoctorResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'specialization_id' => $this->specialization_id,
            
            // Relasi User (Nama, Email, dll)
            'user' => new UserResource($this->whenLoaded('user')),
            
            // Relasi Spesialisasi (Mata, dll)
            'specialization' => new SpecializationResource($this->whenLoaded('specialization')),
            
            // Relasi Jadwal dengan pengamanan count()
            'schedules' => DoctorScheduleResource::collection($this->whenLoaded('schedules')),
            'schedules_count' => $this->relationLoaded('schedules') ? ($this->schedules ? $this->schedules->count() : 0) : 0,
            
            // Relasi Janji Temu dengan pengamanan count()
            'appointments_count' => $this->relationLoaded('appointments') ? ($this->appointments ? $this->appointments->count() : 0) : 0,
            'today_appointments_count' => $this->when($this->relationLoaded('appointments'), function() {
                return $this->appointments ? $this->appointments->where('appointment_date', now()->toDateString())->count() : 0;
            }),

            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
        ];
    }
}