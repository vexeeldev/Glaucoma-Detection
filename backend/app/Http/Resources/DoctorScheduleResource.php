<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DoctorScheduleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'day' => $this->day, // Senin, Selasa, dll
            'start_time' => $this->start_time,
            'end_time' => $this->end_time,
            'status' => $this->status ?? 'active',
        ];
    }
}