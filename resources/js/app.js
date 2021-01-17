/**
 * First we will load all of this project's JavaScript dependencies which
 * includes Vue and other libraries. It is a great starting point when
 * building robust, powerful web applications using Vue and Laravel.
 */
import laravelEchoServer from '../../laravel-echo-server.json'

require('./bootstrap');

window.Vue = require('vue').default;

Vue.component('chat-layout', require('./components/ChatLayout.vue').default)

const app = new Vue({
  el: '#app',
  data: {
    currentUserLogin: {},
    echoCredentials: {
      appId: laravelEchoServer.clients[0].appId, //  appId in laravel-echo-server.json
      key: laravelEchoServer.clients[0].key // key in laravel-echo-server.json
    }
  },
  created() {
    this.getCurrentUserLogin()
  },
  methods: {
    async getCurrentUserLogin() {
      try {
        const response = await axios.get('/getUserLogin')
        this.currentUserLogin = response.data
      } catch (error) {
        console.log(error)
      }
    }
  }
})
