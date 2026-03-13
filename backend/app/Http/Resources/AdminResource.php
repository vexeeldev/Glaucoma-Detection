<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use App\Http\Resources\ActivityLogResource;

class AdminResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            // Basic Info
            'id' => $this->id,
            'user_id' => $this->user_id,
            'admin_level' => $this->admin_level,
            
            // Timestamps
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $this->updated_at?->format('Y-m-d H:i:s'),
            
            // Relasi User
            $this->mergeWhen($this->relationLoaded('user'), [
                'user' => new UserResource($this->user),
            ]),
            
            // Activity Log (hanya untuk admin level super)
            $this->mergeWhen(
                $request->user()?->isAdmin() && $this->admin_level === 'super_admin',
                [
                    // 'recent_activities' => $this->when(
                    //     $this->relationLoaded('user') && $this->user->relationLoaded('activityLogs'),
                    //     // ActivityLogResource::collection($this->user->activityLogs->take(5))
                    // ),
                ]
            ),
            
            // Field khusus (hanya untuk super admin)
            $this->mergeWhen(
                $request->user()?->admin?->admin_level === 'super_admin' && $request->user()?->admin_level === 'super_admin',
                [
                    // 'permissions' => $this->getAllPermissions(), // Jika pakai Spatie Permission
                    'deleted_at' => $this->deleted_at?->format('Y-m-d H:i:s'),
                ]
            ),
        ];
    }

    /**
     * Get additional data that should be returned with the resource array.
     */
    public function with($request)
    {
        return [
            'meta' => [
                'role' => 'admin',
                'level' => $this->admin_level,
            ],
        ];
    }
}