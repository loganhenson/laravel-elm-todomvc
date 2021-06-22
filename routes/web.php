<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return Elm::render('Welcome', ['name' => 'Logan']);
})->name('welcome');

Elm::authRoutes();

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');

    Route::prefix('todos')->group(function () {
        Route::post('', [App\Http\Controllers\TodosController::class, 'store'])->name('todos.store');
        Route::delete('{id}', [App\Http\Controllers\TodosController::class, 'destroy'])->name('todos.destroy');
        Route::patch('{id}', [App\Http\Controllers\TodosController::class, 'update'])->name('todos.update');
    });
});
