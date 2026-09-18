<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WirdResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'date'           => $this->date,
            'quran_pages'    => $this->quran_pages,
            'dhikr_morning'  => (bool) $this->dhikr_morning,
            'dhikr_evening'  => (bool) $this->dhikr_evening,
            'sunnah_prayers' => $this->sunnah_prayers,
            'created_at'     => $this->created_at?->toIso8601String(),
        ];
    }
}
