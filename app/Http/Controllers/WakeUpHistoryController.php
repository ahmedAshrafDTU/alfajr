<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreWakeUpHistoryRequest;
use App\Http\Requests\UpdateWakeUpHistoryRequest;
use App\Http\Resources\WakeUpHistoryResource;
use App\Models\WakeUpHistory;
use App\Services\WakeUpService;
use Illuminate\Http\Request;

class WakeUpHistoryController extends Controller
{
    protected WakeUpService $wakeUpService;

    public function __construct(WakeUpService $wakeUpService)
    {
        $this->wakeUpService = $wakeUpService;
    }

    public function index(Request $request)
    {
        $histories = $request->user()->wakeUpHistories()->orderBy('date', 'desc')->get();
        return $this->successResponse(
            WakeUpHistoryResource::collection($histories),
            'Wake-up history retrieved successfully'
        );
    }

    public function store(StoreWakeUpHistoryRequest $request)
    {
        $history = $this->wakeUpService->storeWakeUpHistory($request->user(), $request->validated());

        return $this->successResponse(
            new WakeUpHistoryResource($history),
            'Wake-up history logged successfully',
            201
        );
    }

    public function show(Request $request, WakeUpHistory $wakeUpHistory)
    {
        if ($request->user()->cannot('view', $wakeUpHistory)) {
            return $this->errorResponse('Unauthorized', 403);
        }
        return $this->successResponse(
            new WakeUpHistoryResource($wakeUpHistory),
            'Wake-up history retrieved successfully'
        );
    }

    public function update(UpdateWakeUpHistoryRequest $request, WakeUpHistory $wakeUpHistory)
    {
        if ($request->user()->cannot('update', $wakeUpHistory)) {
            return $this->errorResponse('Unauthorized', 403);
        }
        $history = $this->wakeUpService->updateWakeUpHistory($wakeUpHistory, $request->validated());

        return $this->successResponse(
            new WakeUpHistoryResource($history),
            'Wake-up history updated successfully'
        );
    }

    public function destroy(Request $request, WakeUpHistory $wakeUpHistory)
    {
        if ($request->user()->cannot('delete', $wakeUpHistory)) {
            return $this->errorResponse('Unauthorized', 403);
        }
        $wakeUpHistory->delete();
        return $this->successResponse(null, 'Wake-up history deleted successfully');
    }
}
