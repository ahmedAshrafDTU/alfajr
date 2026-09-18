<?php

namespace App\Http\Controllers;

use App\Http\Requests\UpdateProfileRequest;
use App\Http\Requests\ChangePasswordRequest;
use App\Http\Resources\UserResource;
use App\Services\UserService;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    protected UserService $userService;

    public function __construct(UserService $userService)
    {
        $this->userService = $userService;
    }

    public function show(Request $request)
    {
        return $this->successResponse(
            new UserResource($request->user()),
            'Profile retrieved successfully'
        );
    }

    public function update(UpdateProfileRequest $request)
    {
        $user = $this->userService->updateProfile($request->user(), $request->validated());

        return $this->successResponse(
            new UserResource($user),
            'Profile updated successfully'
        );
    }

    public function changePassword(ChangePasswordRequest $request)
    {
        $this->userService->changePassword(
            $request->user(),
            $request->current_password,
            $request->new_password
        );

        return $this->successResponse(null, 'Password changed successfully');
    }

    public function storeDeviceToken(\App\Http\Requests\StoreUserDeviceRequest $request)
    {
        $user = $request->user();
        $user->userDevices()->updateOrCreate(
            ['fcm_token' => $request->fcm_token],
            [
                'device_id'   => $request->device_id,
                'device_type' => $request->device_type,
            ]
        );

        return $this->successResponse(null, 'Device token stored successfully');
    }
}
