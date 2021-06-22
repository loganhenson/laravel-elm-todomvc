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

    public function destroy($id)
    {
        auth()->user()->todos()->findOrFail($id)->delete();

        return redirect()->to('home');
    }

    public function update($id)
    {
        request()->validate([
            'completed' => 'sometimes|required|bool',
            'description' => 'sometimes|required|string|max:255',
        ]);

        auth()->user()->todos()->findOrFail($id)->update(request()->only([
            'description',
            'completed',
        ]));

        return redirect()->to('home');
    }
}
