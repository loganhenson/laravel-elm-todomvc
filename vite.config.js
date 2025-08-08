import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import laravelElm from 'laravel-elm';

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/todomvc.css',
                'resources/js/app.js',
                'resources/js/elm.js',
            ],
            refresh: true,
        }),
        laravelElm({
            debug: true,
        }),
    ],
});
