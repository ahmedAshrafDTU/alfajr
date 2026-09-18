<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\WakeUpHistory>
 */
class WakeUpHistoryFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'date' => fake()->unique()->dateTimeBetween('-1 month', 'now')->format('Y-m-d'),
            'wake_up_time' => fake()->time(),
            'status' => fake()->randomElement(['on_time', 'late', 'missed']),
            'fajr_prayer_status' => fake()->randomElement(['jamaah', 'home', 'missed']),
            'notes' => fake()->optional()->sentence(),
        ];
    }
}
