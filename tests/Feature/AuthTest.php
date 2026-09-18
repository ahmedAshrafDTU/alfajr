<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register()
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'access_token',
                    'token_type',
                    'user' => ['id', 'name', 'email', 'created_at', 'updated_at']
                ]
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'test@example.com',
        ]);
    }

    public function test_user_can_login()
    {
        $user = User::factory()->create([
            'password' => bcrypt('password123'),
        ]);

        $response = $this->postJson('/api/auth/login', [
            'email' => $user->email,
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'access_token',
                    'token_type',
                    'user' => ['id', 'name', 'email']
                ]
            ]);
    }

    public function test_user_can_logout()
    {
        $user = User::factory()->create();
        \Laravel\Sanctum\Sanctum::actingAs($user, ['*']);

        $response = $this->postJson('/api/auth/logout');

        $response->assertStatus(200)
            ->assertJsonFragment([
                'success' => true,
                'message' => 'Logged out successfully',
            ]);
    }
}
