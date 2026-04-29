<?php

namespace App\Http\Controllers;

use App\Models\Session;
use App\Models\Table;
use Illuminate\Http\Request;

class SessionController extends Controller
{
    public function store($table_id)
    {
        $table = Table::find($table_id);
        if (!$table) {
            return response()->json(['error' => 'Table not found'], 404);
        }

        $session = Session::create([
            'table_id' => $table->id,
            'active' => true
        ]);

        return response()->json([
            'session_token' => $session->id,
            'table_number' => $table->table_number
        ]);
    }

    public function show($id)
    {
        $session = Session::with('table')->find($id);
        if (!$session) {
            return response()->json(['error' => 'Session not found'], 404);
        }
        return response()->json($session);
    }
}
