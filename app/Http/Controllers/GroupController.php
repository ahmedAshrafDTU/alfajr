<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreGroupRequest;
use App\Http\Requests\UpdateGroupRequest;
use App\Http\Requests\AddGroupMemberRequest;
use App\Http\Resources\GroupResource;
use App\Models\Group;
use App\Services\GroupService;
use Illuminate\Http\Request;

class GroupController extends Controller
{
    protected GroupService $groupService;

    public function __construct(GroupService $groupService)
    {
        $this->groupService = $groupService;
    }

    public function index(Request $request)
    {
        $groups = $request->user()->groups()->with('members')->get();
        return $this->successResponse(
            GroupResource::collection($groups),
            'Groups retrieved successfully'
        );
    }

    public function store(StoreGroupRequest $request)
    {
        $group = $this->groupService->createGroup($request->user(), $request->validated());
        
        return $this->successResponse(
            new GroupResource($group),
            'Group created successfully',
            201
        );
    }

    public function show(Request $request, Group $group)
    {
        if ($request->user()->cannot('view', $group)) {
            return $this->errorResponse('Unauthorized', 403);
        }
        $group->load('members');
        return $this->successResponse(
            new GroupResource($group),
            'Group retrieved successfully'
        );
    }

    public function update(UpdateGroupRequest $request, Group $group)
    {
        if ($request->user()->cannot('update', $group)) {
            return $this->errorResponse('Unauthorized', 403);
        }
        $group = $this->groupService->updateGroup($group, $request->validated());
        
        return $this->successResponse(
            new GroupResource($group),
            'Group updated successfully'
        );
    }

    public function destroy(Request $request, Group $group)
    {
        if ($request->user()->cannot('delete', $group)) {
            return $this->errorResponse('Unauthorized', 403);
        }
        $this->groupService->deleteGroup($group);
        return $this->successResponse(null, 'Group deleted successfully');
    }

    public function addMember(AddGroupMemberRequest $request, Group $group)
    {
        if ($request->user()->cannot('manageMembers', $group)) {
            return $this->errorResponse('Unauthorized', 403);
        }
        $user = \App\Models\User::findOrFail($request->user_id);
        $this->groupService->addMember($group, $user);
        
        return $this->successResponse(
            new GroupResource($group->load('members')),
            'Member added successfully'
        );
    }

    public function leave(Request $request, Group $group)
    {
        $this->groupService->removeMember($group, $request->user());
        return $this->successResponse(null, 'Left group successfully');
    }
}
