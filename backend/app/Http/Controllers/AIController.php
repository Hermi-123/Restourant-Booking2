<?php

namespace App\Http\Controllers;

use App\Models\MenuItem;
use App\Models\UserPreference;
use Illuminate\Http\Request;

class AIController extends Controller
{
    public function recommend($session_id)
    {
        // Simple collaborative filtering based on session preferences
        $preferences = UserPreference::where('session_id', $session_id)
            ->orderBy('count', 'desc')
            ->pluck('menu_item_id');

        if ($preferences->isEmpty()) {
            // Fallback: Recommend top 3 popular items or random items
            $recommendations = MenuItem::where('is_available', true)->inRandomOrder()->take(3)->get();
        } else {
            // Recommend based on most ordered items in this session
            // In a real AI system, we would use a more complex model.
            $recommendations = MenuItem::whereIn('id', $preferences)
                ->where('is_available', true)
                ->take(3)
                ->get();
            
            // If less than 3, fill with randoms
            if ($recommendations->count() < 3) {
                $ids = $recommendations->pluck('id');
                $extra = MenuItem::whereNotIn('id', $ids)->where('is_available', true)->inRandomOrder()->take(3 - $recommendations->count())->get();
                $recommendations = $recommendations->concat($extra);
            }
        }

        return response()->json([
            'recommendations' => $recommendations
        ]);
    }
}
