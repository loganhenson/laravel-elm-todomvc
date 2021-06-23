# TodoMVC in Laravel Elm

Clone & run this repo to see what a (somewhat) real life Laravel Elm app looks like!

> Clone
```bash
git clone git@github.com:loganhenson/laravel-elm-todomvc.git
```

> Create your .env (Make sure to fill in your local database info!)
```bash
cp .env.example .env
```

> Generate your APP_KEY
```bash
php artisan key:generate
```

> Install composer dependencies
```bash
composer install
```

> Install npm dependencies
```bash
npm install
```

> Run the watch command
```bash
npm run watch
```

> Run the tests
```bash
vendor/bin/phpunit
```

> Run the migrations
```bash
php artisan migrate
```

> Open!
```bash
valet link
valet open
```

> Register at `/register` & `/home` houses the todo list!

## Credits
- Adapted (with modifications) from https://github.com/evancz/elm-todomvc

![Laravel Elm Todo-MVC](https://github.com/loganhenson/laravel-elm-todomvc/blob/main/laravel-elm-todomvc-image.png?raw=true)
