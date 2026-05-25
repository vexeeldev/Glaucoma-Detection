<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ExaminationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'appointment_id' => $this->appointment_id,
            'result' => $this->result, // Misalnya: Glaukoma/Normal
            'confidence_score' => $this->confidence_score,
            'image_path' => $this->image_path,
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
        ];
    }
}