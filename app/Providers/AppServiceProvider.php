<?php

namespace App\Providers;

use Illuminate\Support\Facades\Route;
use Illuminate\Support\ServiceProvider;
use Tightenco\Elm\Elm;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Elm::share('user', function () {
            return auth()->user() ? [
                'id' => auth()->user()->id,
                'name' => auth()->user()->name,
            ] : null;
        });

        Elm::share('route', function () {
            return Route::currentRouteName();
        });
    }
}
