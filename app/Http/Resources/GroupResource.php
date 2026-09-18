<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GroupResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'          => $this->id,
            'name'        => $this->name,
            'description' => $this->description,
            'admin_id'    => $this->admin_id,
            'members'     => UserResource::collection($this->whenLoaded('members')),
            'created_at'  => $this->created_at?->toIso8601String(),
        ];
    }
}
