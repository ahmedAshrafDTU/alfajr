<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Wird>
 */
class WirdFactory extends Factory
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
            'quran_pages' => fake()->numberBetween(0, 20),
            'dhikr_morning' => fake()->boolean(),
            'dhikr_evening' => fake()->boolean(),
            'sunnah_prayers' => fake()->numberBetween(0, 12),
        ];
    }
}
