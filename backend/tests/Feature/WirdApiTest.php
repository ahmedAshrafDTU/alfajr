<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WirdApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_log_wird()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/wirds', [
            'date' => '2026-09-11',
            'quran_pages' => 10,
            'dhikr_morning' => true,
            'dhikr_evening' => false,
            'sunnah_prayers' => 12,
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('wirds', [
            'user_id' => $user->id,
            'date' => '2026-09-11 00:00:00',
            'quran_pages' => 10,
        ]);
    }
}
