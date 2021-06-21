<?php

namespace App\Http\Controllers;

use App\Models\Todo;

class TodosController extends Controller
{
    public function store()
    {
        request()->validate([
            'description' => 'required|string|max:255',
        ]);

        auth()->user()->todos()->save(new Todo([
            'description' => request('description'),
        ]));

        return redirect()->to('home');
    }
}
