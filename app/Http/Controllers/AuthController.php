<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use App\Services\AuthService;

class AuthController extends Controller
{
    protected AuthService $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    public function register(RegisterRequest $request)
    {
        $result = $this->authService->register($request->validated());

        return $this->successResponse([
            'access_token' => $result['token'],
            'token_type'   => 'Bearer',
            'user'         => new \App\Http\Resources\UserResource($result['user']),
        ], 'User registered successfully', 201);
    }

    public function login(LoginRequest $request)
    {
        $result = $this->authService->login($request->validated());

        return $this->successResponse([
            'access_token' => $result['token'],
            'token_type'   => 'Bearer',
            'user'         => new \App\Http\Resources\UserResource($result['user']),
        ], 'Logged in successfully');
    }

    public function logout(Request $request)
    {
        $this->authService->logout($request->user());

        return $this->successResponse(null, 'Logged out successfully');
    }

    public function me(Request $request)
    {
        return $this->successResponse(
            new \App\Http\Resources\UserResource($request->user()),
            'User profile retrieved successfully'
        );
    }
}
