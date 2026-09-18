<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DashboardResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'today_wird'       => new WirdResource($this['today_wird'] ?? null),
            'today_wake_up'    => new WakeUpHistoryResource($this['today_wake_up'] ?? null),
            'wake_up_streak'   => $this['wake_up_streak'] ?? 0,
            'wird_streak'      => $this['wird_streak'] ?? 0,
            'groups_count'     => $this['groups_count'] ?? 0,
        ];
    }
}
