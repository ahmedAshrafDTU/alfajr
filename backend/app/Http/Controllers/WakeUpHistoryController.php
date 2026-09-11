<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreWakeUpHistoryRequest;
use App\Models\WakeUpHistory;
use Illuminate\Http\Request;

class WakeUpHistoryController extends Controller
{
    public function index(Request $request)
    {
        return response()->json(
            $request->user()->wakeUpHistories()->orderBy('date', 'desc')->get()
        );
    }

    public function store(StoreWakeUpHistoryRequest $request)
    {
        $history = $request->user()->wakeUpHistories()->updateOrCreate(
            ['date' => $request->date],
            $request->validated()
        );

        return response()->json($history, 201);
    }

    public function show(Request $request, WakeUpHistory $wakeUpHistory)
    {
        if ($wakeUpHistory->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        return response()->json($wakeUpHistory);
    }
}
