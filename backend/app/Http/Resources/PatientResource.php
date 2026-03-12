<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PatientResource extends JsonResource
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
            
            'date_of_birth' => $this->date_of_birth?->format('Y-m-d'),
            'gender' => $this->gender,
            'address' => $this->address,
            'city' => $this->city,
            'province' => $this->province,
            'postal_code' => $this->postal_code,
            
            'emergency_contact_name' => $this->emergency_contact_name,
            'emergency_contact_phone' => $this->emergency_contact_phone,
            'emergency_contact_relation' => $this->emergency_contact_relation,
            
            'blood_type' => $this->blood_type,
            'medical_history' => $this->medical_history,
            'current_medications' => $this->current_medications,
            'allergies' => $this->allergies,
            
            'insurance_provider' => $this->insurance_provider,
            'insurance_number' => $this->insurance_number,
            
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
            
            $this->mergeWhen($this->relationLoaded('user'), [
                'user' => new UserResource($this->user),
            ]),
            
            $this->mergeWhen($this->relationLoaded('appointments'), [
                'appointments_count' => $this->appointments->count(),
                'appointments' => AppointmentResource::collection($this->appointments),
            ]),
            
            $this->mergeWhen($this->relationLoaded('examinations'), [
                'examinations_count' => $this->examinations->count(),
                'examinations' => ExaminationResource::collection($this->examinations),
            ]),
            
            $this->mergeWhen($request->user()?->isAdmin(), [
                'deleted_at' => $this->deleted_at?->format('Y-m-d H:i:s'),
            ]),
        ];
    }
}