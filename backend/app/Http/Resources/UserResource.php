<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
// use App\Http\Resources\AdminResource;
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
        $data = [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone' => $this->phone,
            'role' => $this->role,
            'is_active' => $this->is_active,
            'email_verified_at' => $this->email_verified_at?->format('Y-m-d H:i:s'),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
            'deleted_at' => $this->deleted_at?->format('Y-m-d H:i:s'),
        ];

        // Relation based role
        if ($this->relationLoaded('patient') && $this->patient) {
            $data['patient'] = new PatientResource($this->patient);
        }
        
        if ($this->relationLoaded('doctor') && $this->doctor) {
            $data['doctor'] = new DoctorResource($this->doctor);
        }
        
        if ($this->relationLoaded('admin') && $this->admin) {
            $data['admin'] = new AdminResource($this->admin);
        }

        // extra for Admin
        if ($request->user()?->isAdmin()) {
            $data['remember_token'] = $this->remember_token;
            $data['last_login_at'] = $this->last_login_at;
            $data['last_login_ip'] = $this->last_login_ip;
        }

        return $data;
    }

    /**
     * Customize the response for the resource.
     */
    public function with($request)
    {
        return [
            'status' => 'success',
            'timestamp' => now()->toIso8601String(),
        ];
    }
}