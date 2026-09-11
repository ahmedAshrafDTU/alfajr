<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Group;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class GroupApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_create_group()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/groups', [
            'name' => 'Fajr Knights',
            'description' => 'Group for waking up for fajr',
        ]);

        $response->assertStatus(201);
        $response->assertJsonStructure(['id', 'name', 'description', 'admin_id']);
        
        $this->assertDatabaseHas('groups', [
            'name' => 'Fajr Knights',
            'admin_id' => $user->id,
        ]);
        
        $this->assertDatabaseHas('group_members', [
            'user_id' => $user->id,
            'role' => 'admin',
        ]);
    }
}
