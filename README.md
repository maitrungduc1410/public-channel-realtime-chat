# Realtime chat app using Laravel, VueJS, Redis, Laravel Echo Server

# Install Instruction
## Prerequisite
Please make sure you have `redis` on your PC first. Run `redis-cli` in command line to check whether you have `redis`

## Installation:
- Clone this project

Run following command on root folder:

	- composer install
	- npm install
	- npm install -g laravel-echo-server
	- cp .env.example .env
	- change LARAVEL_ECHO_SERVER_REDIS_HOST in `.env` from `redis` to `localhost`
	- php artisan key:generate

Open `resources/js/bootstrap.js` scroll to bottom and choose which host match to yours (`production` or `development`)

Then open your `.env` file and change database connection info as installed on your PC

Turn on Xampp, Access PHPMyadmin and create a database with the name you defined in `.env`

Run following command: 

	- php artisan migrate
	- php artisan serve
	- npm run watch (open in another terminal tab)
	- laravel-echo-server start (open in another terminal tab)

Open browser in Chrome and another tab using incognito or other browser type (Safari, Firefox). Create an account and test your app.

Then you're ready to go
# Demo
You can try real demo here: [Demo](https://public-chat.jamesisme.com/)

# Running with Docker
## Prerequisite
Install `docker` and `docker-compose`

## Build images
First:
- Change LARAVEL_ECHO_SERVER_REDIS_HOST in `.env` from `localhost` to `redis`
- Change REDIS_HOST in `.env` to `redis`
- Change `DB_HOST` in `.env` to `db`
- And change other db info (user pass, db name,...) in `.env` to match service `db` in `docker-compose.yml`
- Go to `resources/js/bootstrap.js` change Echo host to port `8000` instead of `6001` (Eg: `${window.location.protocol}//${window.location.hostname}:6001`)

Then we need to build our Laravel application:
```
docker build -t <your_app_image_name> .
```
Then build the laravel echo image:
```
docker build -t <your_echo_image_name> . -f echo.dockerfile
```

Then edit the `docker-compose.yml` file:
- Change image's name in service `app` to `your_app_image_name` we set above
- Change image's name in service `laravel_echo_server` to `your_echo_image_name` we set above

Now, start your app: `docker-compose up -d --build`, then wait for docker to build images and start up

Then access `localhost:8000` to see your application alive.

