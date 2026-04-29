<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Order extends Model
{
    use HasUuids;

    protected $fillable = ['session_id', 'order_number', 'status', 'total_price'];

    public function session()
    {
        return $this->belongsTo(Session::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }
}
