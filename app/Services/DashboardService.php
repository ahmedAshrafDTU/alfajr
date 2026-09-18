<?php

namespace App\Services;

use App\Models\User;
use Carbon\Carbon;

class DashboardService
{
    /**
     * Get user dashboard data.
     */
    public function getDashboardData(User $user): array
    {
        $today = Carbon::today()->toDateString();
        
        $todayWird = $user->wirds()->where('date', $today)->first();
        $todayWakeUp = $user->wakeUpHistories()->where('date', $today)->first();
        $groupsCount = $user->groups()->count();

        // Calculate streaks (simplified for performance)
        $wirdStreak = $this->calculateWirdStreak($user);
        $wakeUpStreak = $this->calculateWakeUpStreak($user);

        return [
            'today_wird'     => $todayWird,
            'today_wake_up'  => $todayWakeUp,
            'wird_streak'    => $wirdStreak,
            'wake_up_streak' => $wakeUpStreak,
            'groups_count'   => $groupsCount,
        ];
    }

    private function calculateWirdStreak(User $user): int
    {
        $wirds = $user->wirds()->orderBy('date', 'desc')->get();
        $streak = 0;
        $date = Carbon::today();

        foreach ($wirds as $wird) {
            if ($wird->date === $date->toDateString()) {
                $streak++;
                $date->subDay();
            } elseif ($wird->date === Carbon::yesterday()->toDateString() && $streak === 0) {
                // Allows a streak to continue if they haven't logged today yet but logged yesterday
                $streak++;
                $date->subDays(2);
            } else {
                break;
            }
        }
        return $streak;
    }

    private function calculateWakeUpStreak(User $user): int
    {
        $histories = $user->wakeUpHistories()->orderBy('date', 'desc')->get();
        $streak = 0;
        $date = Carbon::today();

        foreach ($histories as $history) {
            if ($history->status === 'on_time') {
                if ($history->date === $date->toDateString()) {
                    $streak++;
                    $date->subDay();
                } elseif ($history->date === Carbon::yesterday()->toDateString() && $streak === 0) {
                    $streak++;
                    $date->subDays(2);
                } else {
                    break;
                }
            } else {
                break;
            }
        }
        return $streak;
    }
}
