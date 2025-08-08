<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Todo;
use Illuminate\Http\Request;
use Tightenco\Elm\Elm;

class TodosController extends Controller
{
    public function index()
    {
        $todos = auth()->user()->todos()->orderBy('created_at')->get();

        return Elm::render('Todos', [
            'todos' => $todos->map(function ($todo) {
                return [
                    'id' => $todo->id,
                    'text' => $todo->text,
                    'completed' => $todo->completed,
                ];
            })->toArray(),
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'text' => 'required|string|max:255',
        ]);

        auth()->user()->todos()->create([
            'text' => $request->text,
            'completed' => false,
        ]);

        return redirect()->route('todos');
    }

    public function update(Todo $todo, Request $request)
    {
        $data = [];
        
        if ($request->has('text')) {
            $request->validate(['text' => 'string|max:255']);
            $data['text'] = $request->input('text');
        }
        
        if ($request->has('completed')) {
            $data['completed'] = $request->boolean('completed');
        }

        $todo->update($data);

        return redirect()->route('todos');
    }

    public function destroy(Todo $todo)
    {
        $todo->delete();

        return redirect()->route('todos');
    }

    public function toggleAll(Request $request)
    {
        $completed = $request->boolean('completed');

        auth()->user()->todos()->update(['completed' => $completed]);

        return redirect()->route('todos');
    }

    public function clearCompleted()
    {
        auth()->user()->todos()->where('completed', true)->delete();

        return redirect()->route('todos');
    }
}
