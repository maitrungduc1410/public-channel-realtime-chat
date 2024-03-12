<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Auth::routes();

Route::get('/', function() {
    return view('chat');
})->middleware('auth');

Route::get('/getUserLogin', function() {
	return Auth::user();
})->middleware('auth');

Route::get('/messages', function() {
    return App\Models\Message::with('user')->latest()->paginate((int) request()->query('per_page', '50'));
})->middleware('auth');

Route::post('/messages', function() {
    $user = Auth::user();

    $message = new App\Models\Message();
    $message->message = substr(request()->get('message', ''), 0, (int) env('VITE_CHAT_MAX_MESSAGE_LENGTH', '500'));
    $message->user_id = $user->id;
    $message->save();

    broadcast(new App\Events\MessagePosted($message, $user))->toOthers();
    return ['message' => $message->load('user')];
})->middleware('auth');

