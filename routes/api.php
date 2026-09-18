<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\GroupController;
use App\Http\Controllers\WakeUpHistoryController;
use App\Http\Controllers\WirdController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'me']);

    Route::apiResource('groups', GroupController::class);
    Route::apiResource('wake-up-histories', WakeUpHistoryController::class);
    Route::apiResource('wirds', WirdController::class);
});
