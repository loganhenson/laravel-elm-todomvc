<?php

use App\Http\Controllers\TodosController;
use Illuminate\Support\Facades\Route;
use Tightenco\Elm\Elm;

Route::redirect('/', '/todos');

Elm::authRoutes();

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
    
    Route::get('todos', [TodosController::class, 'index'])->name('todos');
    Route::post('todos', [TodosController::class, 'store'])->name('todos.store');
    Route::post('todos/toggle-all', [TodosController::class, 'toggleAll'])->name('todos.toggle-all');
    Route::delete('todos/clear-completed', [TodosController::class, 'clearCompleted'])->name('todos.clear-completed');
    Route::patch('todos/{todo}', [TodosController::class, 'update'])->name('todos.update');
    Route::delete('todos/{todo}', [TodosController::class, 'destroy'])->name('todos.destroy');
});
