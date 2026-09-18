<?php

namespace App\Services;

use App\Models\User;
use App\Models\WakeUpHistory;

class WakeUpService
{
    /**
     * Store or update wake up history for a specific date.
     */
    public function storeWakeUpHistory(User $user, array $data): WakeUpHistory
    {
        $existingRecord = $user->wakeUpHistories()->where('date', $data['date'])->first();

        if ($existingRecord) {
            $existingRecord->update([
                'wake_up_time'       => $data['wake_up_time'] ?? $existingRecord->wake_up_time,
                'status'             => $data['status'] ?? $existingRecord->status,
                'fajr_prayer_status' => $data['fajr_prayer_status'] ?? $existingRecord->fajr_prayer_status,
                'notes'              => $data['notes'] ?? $existingRecord->notes,
            ]);
            return $existingRecord;
        }

        return $user->wakeUpHistories()->create($data);
    }

    /**
     * Update an existing wake up history record.
     */
    public function updateWakeUpHistory(WakeUpHistory $history, array $data): WakeUpHistory
    {
        $history->update($data);
        return $history;
    }
}
