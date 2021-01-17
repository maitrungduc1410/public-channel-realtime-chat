# Realtime chat app with Laravel, Redis, Socket.IO, Laravel Echo
This is demo of Laravel chat app that uses `Public Channel` to perform realtime chat. In production you probably need Private or Presence channel to make your chat app secure, check my chat app that uses Private and Presence channel [here](https://github.com/maitrungduc1410/realtime-chatapp-laravelecho-socketio)
# Run in local
## Prerequisites
- Make sure you have `redis` install on your computer. Try run `redis-cli` in terminal to see.
- Make sure you have `php` (at least 7.3), `composer` and `nodejs` (with npm) installed
- Check if you have `laravel-echo-server` installed, otherwise install it by running:
```
npm install -g laravel-echo-server
```
## Setup
Installation steps:
- First clone the project
- Create `.env` by running: `cp .env.example .env`
- Update database configuration in `.env` to match yours
- Generate project key: `php artisan key:generate`
- Install dependencies:
```
composer install
npm install
```
- Migrate database: `php artisan migrate`

Finally start the project, note that each following command needs to run in separate terminal:
```
php artisan serve
npm run watch
laravel-echo-server start
php artisan queue:work
```
Open browser at `http://localhost:8000` and test :)

# Run with Docker
This project is dockerized to run with non-root user in container (for best security). So first you have to check what is User ID and Group ID of your host user by running the following command:
```
id -u
id -g
```
If both of them show `1000`, then simply comment `LOCAL` section in `.docker/laravel-echo-server/Dockerfil` and `Dockerfile` (in root level project), and uncomment `PRODUCTION` section

Otherwise based on your host User ID and Group ID you need to update those Dockerfiles to match your system UID:GID

After that open `docker-compose.yml` and with service `db` and `redis`, you have to update `user` with the same UID:GID equal to your host OS

Before start the project, open `.env`, and update the following:
- `DB_HOST` change to `db` (name of `db` service in docker-compose.yml)
- `REDIS_HOST` change to `redis` (name of `redis` service in docker-compose.yml)
- `LARAVEL_ECHO_SERVER_REDIS_HOST=redis`
- `APP_PORT=4000`
- `MIX_FRONTEND_PORT=4000`
- `LARAVEL_ECHO_CLIENT=http://localhost:4000/socket.io/socket.io.js`

Start the project:
```
docker-compose up -d --build
docker run --rm -v $(pwd):/app -w /app composer install
docker run --rm -v $(pwd):/app -w /app node:14-alpine npm install
docker run --rm -v $(pwd):/app -w /app node:14-alpine npm run watch
```

Finally open browser at `http://localhost:4000` and try :)