<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Builder;

class Todo extends Model
{
    use HasFactory;
    protected $fillable = [
        'text',
        'completed',
        'user_id',
    ];

    protected $casts = [
        'completed' => 'boolean',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function resolveRouteBinding($value, $field = null)
    {
        return $this->where('user_id', auth()->id())->where($field ?? $this->getRouteKeyName(), $value)->firstOrFail();
    }
}
