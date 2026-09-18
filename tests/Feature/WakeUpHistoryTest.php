<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\WakeUpHistory;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class WakeUpHistoryTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_log_wake_up()
    {
        $user = User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/wake-up-histories', [
            'date' => now()->toDateString(),
            'wake_up_time' => '04:30',
            'status' => 'on_time',
            'fajr_prayer_status' => 'jamaah',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status', 'on_time');

        $this->assertDatabaseHas('wake_up_histories', [
            'user_id' => $user->id,
            'status' => 'on_time',
        ]);
    }
}
