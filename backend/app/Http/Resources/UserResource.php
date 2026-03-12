<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
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
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'username' => $this->username,
            'role' => $this->role,
            'is_active' => $this->is_active,
            
            'email_verified_at' => $this->email_verified_at?->format('Y-m-d H:i:s'),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
            
            $this->mergeWhen($this->relationLoaded('patient') && $this->patient, [
                'patient' => new PatientResource($this->patient),
            ]),
            
            $this->mergeWhen($this->relationLoaded('doctor') && $this->doctor, [
                'doctor' => new DoctorResource($this->doctor),
            ]),
            
            $this->mergeWhen($this->relationLoaded('admin') && $this->admin, [
                'admin' => new AdminResource($this->admin),
            ]),
            
            $this->mergeWhen($request->user()?->isAdmin(), [
                'remember_token' => $this->remember_token,
                'deleted_at' => $this->deleted_at?->format('Y-m-d H:i:s'),
            ]),
        ];
    }

    public function with($request)
    {
        return [
            'status' => 'success',
            'timestamp' => now()->toIso8601String(),
        ];
    }
}