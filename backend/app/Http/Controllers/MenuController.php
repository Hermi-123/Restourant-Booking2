<?php

namespace App\Http\Controllers;

use App\Models\MenuItem;
use Illuminate\Http\Request;

class MenuController extends Controller
{
    public function index()
    {
        return response()->json(MenuItem::where('is_available', true)->get());
    }

    public function category($category)
    {
        return response()->json(MenuItem::where('category', $category)->where('is_available', true)->get());
    }
}
