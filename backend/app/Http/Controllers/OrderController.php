<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\MenuItem;
use App\Models\Session;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'session_id' => 'required|uuid',
            'items' => 'required|array',
            'items.*.menu_item_id' => 'required|exists:menu_items,id',
            'items.*.quantity' => 'required|integer|min:1',
        ]);

        $totalPrice = 0;
        $orderItems = [];

        foreach ($validated['items'] as $item) {
            $menuItem = MenuItem::find($item['menu_item_id']);
            $price = $menuItem->price * $item['quantity'];
            $totalPrice += $price;

            $orderItems[] = [
                'menu_item_id' => $item['menu_item_id'],
                'quantity' => $item['quantity'],
                'price' => $menuItem->price
            ];
        }

        $order = Order::create([
            'session_id' => $validated['session_id'],
            'order_number' => 'ORD-' . strtoupper(Str::random(6)),
            'status' => 'received',
            'total_price' => $totalPrice
        ]);

        foreach ($orderItems as $orderItem) {
            $order->items()->create($orderItem);
        }

        return response()->json($order->load('items.menuItem'));
    }

    public function show($session_id)
    {
        return response()->json(Order::where('session_id', $session_id)->with('items.menuItem')->get());
    }

    public function updateStatus(Request $request, $order_id)
    {
        $validated = $request->validate([
            'status' => 'required|in:received,cooking,ready,delivered'
        ]);

        $order = Order::find($order_id);
        if (!$order) {
            return response()->json(['error' => 'Order not found'], 404);
        }

        $order->status = $validated['status'];
        $order->save();

        return response()->json($order);
    }

    public function staffOrders()
    {
        return response()->json(Order::with(['session.table', 'items.menuItem'])->orderBy('created_at', 'desc')->get());
    }

    public function stats()
    {
        $totalRevenue = Order::where('status', 'delivered')->sum('total_price');
        $activeSessions = Session::where('active', true)->count();
        $completedOrders = Order::where('status', 'delivered')->count();
        
        $popularItems = OrderItem::select('menu_item_id', \DB::raw('count(*) as count'))
            ->groupBy('menu_item_id')
            ->orderBy('count', 'desc')
            ->with('menuItem')
            ->take(5)
            ->get();

        return response()->json([
            'total_revenue' => $totalRevenue,
            'active_sessions' => $activeSessions,
            'completed_orders' => $completedOrders,
            'popular_items' => $popularItems
        ]);
    }
}
