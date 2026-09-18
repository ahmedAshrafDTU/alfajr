<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $users = User::factory(10)->create();

        $testUser = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);
        
        $allUsers = $users->push($testUser);

        // Seed some groups
        \App\Models\Group::factory(5)->create()->each(function ($group) use ($allUsers) {
            // Attach 3 random members to each group
            $members = $allUsers->random(3);
            foreach ($members as $member) {
                \App\Models\GroupMember::create([
                    'group_id' => $group->id,
                    'user_id' => $member->id,
                ]);
            }
        });

        // Seed Wirds and WakeUpHistories for each user
        foreach ($allUsers as $user) {
            \App\Models\Wird::factory(3)->sequence(
                fn ($sequence) => ['date' => now()->subDays($sequence->index)->format('Y-m-d')]
            )->create(['user_id' => $user->id]);
            
            \App\Models\WakeUpHistory::factory(3)->sequence(
                fn ($sequence) => ['date' => now()->subDays($sequence->index)->format('Y-m-d')]
            )->create(['user_id' => $user->id]);
        }
    }
}
