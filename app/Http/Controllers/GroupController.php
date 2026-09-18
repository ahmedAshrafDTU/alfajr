<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreGroupRequest;
use App\Models\Group;
use App\Models\GroupMember;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class GroupController extends Controller
{
    public function index(Request $request)
    {
        // Get groups where user is a member or admin
        $groups = Group::whereHas('members', function($q) use ($request) {
            $q->where('user_id', $request->user()->id);
        })->orWhere('admin_id', $request->user()->id)->with('admin')->get();

        return response()->json($groups);
    }

    public function store(StoreGroupRequest $request)
    {
        DB::beginTransaction();
        try {
            $group = Group::create([
                'name' => $request->name,
                'description' => $request->description,
                'admin_id' => $request->user()->id,
            ]);

            // Add creator as admin member
            GroupMember::create([
                'group_id' => $group->id,
                'user_id' => $request->user()->id,
                'role' => 'admin',
                'status' => 'active',
            ]);

            DB::commit();
            return response()->json($group->load('members.user'), 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['error' => 'Failed to create group.'], 500);
        }
    }

    public function show(Request $request, Group $group)
    {
        // Check if user is member
        $isMember = $group->members()->where('user_id', $request->user()->id)->exists();
        if ($group->admin_id !== $request->user()->id && !$isMember) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        return response()->json($group->load(['members.user', 'admin']));
    }
}
