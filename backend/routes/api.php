<?php

use App\Http\Controllers\AIController;
use App\Http\Controllers\MenuController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\SessionController;
use Illuminate\Support\Facades\Route;

Route::post('/session/{table_id}', [SessionController::class, 'store']);
Route::get('/session/{id}', [SessionController::class, 'show']);

Route::get('/menu', [MenuController::class, 'index']);
Route::get('/menu/category/{category}', [MenuController::class, 'category']);

Route::post('/order', [OrderController::class, 'store']);
Route::get('/order/{session_id}', [OrderController::class, 'show']);
Route::put('/order/{order_id}/status', [OrderController::class, 'updateStatus']);

Route::get('/staff/orders', [OrderController::class, 'staffOrders']);

Route::get('/recommend/{session_id}', [AIController::class, 'recommend']);
