<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Table extends Model
{
    protected $fillable = ['table_number', 'qr_code'];

    public function sessions()
    {
        return $this->hasMany(Session::class);
    }
}
