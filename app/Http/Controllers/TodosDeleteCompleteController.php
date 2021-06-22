<?php

namespace App\Http\Controllers;

class TodosDeleteCompleteController extends Controller
{
    public function __invoke()
    {
        auth()->user()->todos()->where('completed', true)->delete();

        return redirect()->to('home');
    }
}
