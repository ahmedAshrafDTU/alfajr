<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WakeUpHistoryApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_log_wake_up_history()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/wake-up-histories', [
            'date' => '2026-09-11',
            'wake_up_time' => '04:30:00',
            'status' => 'on_time',
            'fajr_prayer_status' => 'jamaah',
            'notes' => 'Alhamdulillah',
        ]);

        $response->assertStatus(201);
        $this->assertDatabaseHas('wake_up_histories', [
            'user_id' => $user->id,
            'date' => '2026-09-11 00:00:00',
            'status' => 'on_time',
        ]);
    }
}
