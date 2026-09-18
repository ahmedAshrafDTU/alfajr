<?php

namespace App\Policies;

use App\Models\User;
use App\Models\WakeUpHistory;
use Illuminate\Auth\Access\Response;

class WakeUpHistoryPolicy
{
    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, WakeUpHistory $wakeUpHistory): bool
    {
        return $user->id === $wakeUpHistory->user_id;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, WakeUpHistory $wakeUpHistory): bool
    {
        return $user->id === $wakeUpHistory->user_id;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, WakeUpHistory $wakeUpHistory): bool
    {
        return $user->id === $wakeUpHistory->user_id;
    }
}
