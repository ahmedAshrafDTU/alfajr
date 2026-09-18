<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreWirdRequest;
use App\Http\Requests\UpdateWirdRequest;
use App\Http\Resources\WirdResource;
use App\Models\Wird;
use App\Services\WirdService;
use Illuminate\Http\Request;

class WirdController extends Controller
{
    protected WirdService $wirdService;

    public function __construct(WirdService $wirdService)
    {
        $this->wirdService = $wirdService;
    }

    public function index(Request $request)
    {
        $wirds = $request->user()->wirds()->orderBy('date', 'desc')->get();
        return $this->successResponse(
            WirdResource::collection($wirds),
            'Wird history retrieved successfully'
        );
    }

    public function store(StoreWirdRequest $request)
    {
        $wird = $this->wirdService->storeWird($request->user(), $request->validated());

        return $this->successResponse(
            new WirdResource($wird),
            'Wird logged successfully',
            201
        );
    }

    public function show(Request $request, Wird $wird)
    {
        if ($request->user()->cannot('view', $wird)) {
            return $this->errorResponse('Unauthorized', 403);
        }
        return $this->successResponse(
            new WirdResource($wird),
            'Wird retrieved successfully'
        );
    }

    public function update(UpdateWirdRequest $request, Wird $wird)
    {
        if ($request->user()->cannot('update', $wird)) {
            return $this->errorResponse('Unauthorized', 403);
        }
        $wird = $this->wirdService->updateWird($wird, $request->validated());

        return $this->successResponse(
            new WirdResource($wird),
            'Wird updated successfully'
        );
    }

    public function destroy(Request $request, Wird $wird)
    {
        if ($request->user()->cannot('delete', $wird)) {
            return $this->errorResponse('Unauthorized', 403);
        }
        $wird->delete();
        return $this->successResponse(null, 'Wird deleted successfully');
    }
}
