<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SpecializationResource extends JsonResource
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
            // Jika ada kolom deskripsi atau slug, bisa ditambah di sini
            'description' => $this->description ?? null,
            'slug' => $this->slug ?? null,
        ];
    }
}