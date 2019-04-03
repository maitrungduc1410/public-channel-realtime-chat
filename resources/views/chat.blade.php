<!DOCTYPE html>
<html>
<head>
	<title>Public Chat App</title>
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
  <link rel="stylesheet" href="/css/app.css">
</head>
<body>
	<div id="app">
		<chat-layout></chat-layout>
	</div>
	<script src="/js/app.js"></script>
</body>
</html>