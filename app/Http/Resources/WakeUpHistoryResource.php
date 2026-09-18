<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WakeUpHistoryResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'                 => $this->id,
            'date'               => $this->date,
            'wake_up_time'       => $this->wake_up_time,
            'status'             => $this->status,
            'fajr_prayer_status' => $this->fajr_prayer_status,
            'notes'              => $this->notes,
            'created_at'         => $this->created_at?->toIso8601String(),
        ];
    }
}
