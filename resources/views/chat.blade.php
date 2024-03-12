<!DOCTYPE html>
<html>
<head>
	<title>Chat App</title>
	<meta name="csrf-token" content="{{ csrf_token() }}">
	<link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet">
	<style type="text/css">
		*,
		*::before,
		*::after {
		  box-sizing: border-box;
		}
		html,
		body {
		  height: 100%;
		}
		body {
		  background: linear-gradient(135deg, #044f48, #2a7561);
		  background-size: cover;
		  font-family: 'Open Sans', sans-serif;
		  font-size: 14px;
		  line-height: 1.3;
		  overflow: hidden;
		}
	</style>
	@vite(['resources/sass/app.scss', 'resources/js/app.js'])
</head>
<body>
	<div id="app">
		<chat-layout></chat-layout>
	</div>
	<script src="{{ request()->getScheme() }}://{{ request()->getHost() }}:{{ env('VITE_LARAVEL_ECHO_SERVER_PORT') }}/socket.io/socket.io.js"></script>
</body>
</html>
