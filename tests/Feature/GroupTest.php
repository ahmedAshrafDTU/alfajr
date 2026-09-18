<?php

namespace Tests\Feature;

use App\Models\Group;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class GroupTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_group()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/groups', [
            'name' => 'Fajr Knights',
            'description' => 'A group for fajr',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.name', 'Fajr Knights');

        $this->assertDatabaseHas('groups', [
            'name' => 'Fajr Knights',
            'admin_id' => $user->id,
        ]);
    }

    public function test_admin_can_update_group()
    {
        $user = User::factory()->create();
        $group = Group::create([
            'name' => 'Old Name',
            'admin_id' => $user->id,
        ]);
        $group->members()->attach($user->id);

        $response = $this->actingAs($user, 'sanctum')->putJson("/api/groups/{$group->id}", [
            'name' => 'New Name',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('data.name', 'New Name');
    }

    public function test_non_admin_cannot_update_group()
    {
        $admin = User::factory()->create();
        $user = User::factory()->create();
        $group = Group::create([
            'name' => 'Old Name',
            'admin_id' => $admin->id,
        ]);
        $group->members()->attach($admin->id);
        $group->members()->attach($user->id);

        $response = $this->actingAs($user, 'sanctum')->putJson("/api/groups/{$group->id}", [
            'name' => 'New Name',
        ]);

        $response->assertStatus(403);
    }
}
