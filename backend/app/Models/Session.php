<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Session extends Model
{
    use HasUuids;

    protected $table = 'table_sessions';

    protected $fillable = ['table_id', 'active'];

    public function table()
    {
        return $this->belongsTo(Table::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}
