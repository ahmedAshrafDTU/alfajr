<?php

namespace App\Services;

use App\Models\User;
use App\Models\Wird;
use Illuminate\Validation\ValidationException;

class WirdService
{
    /**
     * Store or update wird for a specific date.
     */
    public function storeWird(User $user, array $data): Wird
    {
        // Check if there is already a wird for this date
        $existingWird = $user->wirds()->where('date', $data['date'])->first();

        if ($existingWird) {
            $existingWird->update([
                'quran_pages'    => $data['quran_pages'] ?? $existingWird->quran_pages,
                'dhikr_morning'  => $data['dhikr_morning'] ?? $existingWird->dhikr_morning,
                'dhikr_evening'  => $data['dhikr_evening'] ?? $existingWird->dhikr_evening,
                'sunnah_prayers' => $data['sunnah_prayers'] ?? $existingWird->sunnah_prayers,
            ]);
            return $existingWird;
        }

        return $user->wirds()->create($data);
    }

    /**
     * Update an existing wird record.
     */
    public function updateWird(Wird $wird, array $data): Wird
    {
        $wird->update($data);
        return $wird;
    }
}
