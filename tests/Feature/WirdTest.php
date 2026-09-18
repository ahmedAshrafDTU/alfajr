<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Wird;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WirdTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_log_wird()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/wirds', [
            'date' => now()->toDateString(),
            'quran_pages' => 10,
            'dhikr_morning' => true,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.quran_pages', 10);

        $this->assertDatabaseHas('wirds', [
            'user_id' => $user->id,
            'quran_pages' => 10,
        ]);
    }

    public function test_user_cannot_view_others_wird()
    {
        $user1 = User::factory()->create();
        $user2 = User::factory()->create();
        $wird = Wird::create([
            'user_id' => $user1->id,
            'date' => now()->toDateString(),
            'quran_pages' => 5,
        ]);

        $response = $this->actingAs($user2, 'sanctum')->getJson("/api/wirds/{$wird->id}");

        $response->assertStatus(403);
    }
}
