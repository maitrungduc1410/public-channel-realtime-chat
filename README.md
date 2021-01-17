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
- update DB configuration in `.env` to match yours
- php artisan key:generate

Next, Run following command to start the project: 
	
	- php artisan serve
	- npm run watch (open in another terminal tab)
	- php artisan queue:work (open in another terminal tab)
	- laravel-echo-server start (open in another terminal tab)

Open browser in Chrome and another tab using incognito or other browser type (Safari, Firefox). Create an account and test your app.

Then you're ready to go
# Demo
You can try real demo here: [Demo](https://public-chat.jamesisme.com/)

# Note
This demo uses public channel in Laravel, which is easy to setup, but with public channel anyone can listen to event when new message saved and in real project you probably need to authenticate or authorize user before they can listen to message's event. 

To do that, we'll need `Private` and `Presence` channel. Check out my blog about [it here](https://github.com/maitrungduc1410/realtime-chatapp-laravelecho-socketio)