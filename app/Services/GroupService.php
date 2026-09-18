<?php

namespace App\Services;

use App\Models\Group;
use App\Models\User;

class GroupService
{
    /**
     * Create a new group.
     */
    public function createGroup(User $user, array $data): Group
    {
        $group = Group::create([
            'name'        => $data['name'],
            'description' => $data['description'] ?? null,
            'admin_id'    => $user->id,
        ]);

        // Add admin as a member automatically
        $group->members()->attach($user->id);

        return $group->load('members');
    }

    /**
     * Update an existing group.
     */
    public function updateGroup(Group $group, array $data): Group
    {
        $group->update($data);
        return $group->load('members');
    }

    /**
     * Delete a group.
     */
    public function deleteGroup(Group $group): void
    {
        $group->delete();
    }

    /**
     * Add a member to the group.
     */
    public function addMember(Group $group, User $user): void
    {
        if (!$group->members()->where('user_id', $user->id)->exists()) {
            $group->members()->attach($user->id);
        }
    }

    /**
     * Remove a member from the group.
     */
    public function removeMember(Group $group, User $user): void
    {
        $group->members()->detach($user->id);
    }
}
