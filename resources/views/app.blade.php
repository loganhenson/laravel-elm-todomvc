<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="theme-color" content="#2196f3">
        <meta
            name="viewport"
            content="width=device-width, initial-scale=1"
        >
        <link rel="preconnect" href="https://storage.googleapis.com">
        <link
            rel="shortcut icon"
            href="/favicon.ico"
            type="image/x-icon"
        >
        <link
            rel="icon"
            href="/favicon.ico"
            type="image/x-icon"
        >
        <title>{{ config('app.name', 'Laravel') }}</title>
        <link
            href="{{ mix('/css/app.css') }}"
            rel="stylesheet"
        >
    </head>

    <body class="bg-gray-100 dark:bg-gray-900 max-w-screen-lg mx-auto">
        @elm

        <script src="{{ mix('/js/app.js') }}"></script>
    </body>
</html>
