<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreWirdRequest;
use App\Models\Wird;
use Illuminate\Http\Request;

class WirdController extends Controller
{
    public function index(Request $request)
    {
        return response()->json(
            $request->user()->wirds()->orderBy('date', 'desc')->get()
        );
    }

    public function store(StoreWirdRequest $request)
    {
        $wird = $request->user()->wirds()->updateOrCreate(
            ['date' => $request->date],
            $request->validated()
        );

        return response()->json($wird, 201);
    }

    public function show(Request $request, Wird $wird)
    {
        if ($wird->user_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        return response()->json($wird);
    }
}
