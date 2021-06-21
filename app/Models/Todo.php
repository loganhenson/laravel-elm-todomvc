<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Todo extends Model
{
    protected $guarded = [];

    protected $casts = [
        'completed' => 'bool',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
