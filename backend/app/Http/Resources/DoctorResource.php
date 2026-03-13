<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DoctorResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'specialization_id' => $this->specialization_id,
            
            'license_number' => $this->license_number,
            'practice_location' => $this->practice_location,
            'experience_years' => $this->experience_years,
            'bio' => $this->bio,
            'profile_photo' => $this->profile_photo,
            'consultation_fee' => (float) $this->consultation_fee,
            'is_available' => $this->is_available,
            
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
            
            $this->mergeWhen($this->relationLoaded('user'), [
                'user' => new UserResource($this->user),
            ]),
            
            $this->mergeWhen($this->relationLoaded('specialization'), [
                'specialization' => new SpecializationResource($this->specialization),
            ]),
            
            $this->mergeWhen($this->relationLoaded('schedules'), [
                'schedules' => DoctorScheduleResource::collection($this->schedules),
                'schedules_count' => $this->schedules->count(),
            ]),
            
            $this->mergeWhen($this->relationLoaded('appointments'), [
                'appointments_count' => $this->appointments->count(),
                'today_appointments' => $this->when(
                    $this->relationLoaded('appointments'),
                    $this->appointments->where('appointment_date', now()->toDateString())->count()
                ),
            ]),
            
            $this->mergeWhen($request->user()?->isAdmin(), [
                'deleted_at' => $this->deleted_at?->format('Y-m-d H:i:s'),
            ]),
        ];
    }
}