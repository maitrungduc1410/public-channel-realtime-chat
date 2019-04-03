# Realtime chat app using Laravel, VueJS, Redis, Laravel Echo Server

# Install Instruction



## Installation:
- Clone this project

Run following command on root folder:

    - composer install
    - npm install
    - npm update
	- cp .env.example .env

Then open your `.env` file and change database connection info as installed on your PC

Turn on Xampp, Access PHPMyadmin and create a database with the name you defined in `.env`

Setup Laravel Echo Server. Run: `laravel-echo-server init`. Just `yes` and choose `redis`

Open `laravel-echo-server.json` change `authHost` to your app's address

Run following command: 

	- php artisan migrate
	- php artisan serve
	- npm run watch (open in another terminal tab)
	- laravel-echo-server start

Open browser in Chrome and another tab using incognito or other browser type (Safari, Firefox). Create an account and test your app

[Demo](https://agile-sea-38553.herokuapp.com/): Now I haven't figure out any way to run laravel-echo-server on Heroku, but if your have your own VPS it's very easy
