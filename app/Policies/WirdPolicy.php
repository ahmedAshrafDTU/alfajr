<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Wird;
use Illuminate\Auth\Access\Response;

class WirdPolicy
{
    /**
     * Determine whether the user can view the model.
     */
    public function view(User $user, Wird $wird): bool
    {
        return $user->id === $wird->user_id;
    }

    /**
     * Determine whether the user can update the model.
     */
    public function update(User $user, Wird $wird): bool
    {
        return $user->id === $wird->user_id;
    }

    /**
     * Determine whether the user can delete the model.
     */
    public function delete(User $user, Wird $wird): bool
    {
        return $user->id === $wird->user_id;
    }
}
