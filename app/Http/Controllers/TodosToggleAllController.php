<?php

namespace App\Http\Controllers;

class TodosToggleAllController extends Controller
{
    public function __invoke()
    {
        request()->validate([
            'completed' => 'required|bool',
        ]);

        auth()->user()->todos()->update(['completed' => request('completed')]);

        return redirect()->to('home');
    }
}
