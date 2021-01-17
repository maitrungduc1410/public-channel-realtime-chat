<template>
  <div>
    <div class="users-online">
      <button type="button" class="btn btn-primary">
        Users online: <span class="badge badge-light">{{ usersOnline }}</span>
      </button>
    </div>
    <div class="btn-logout">
      <a
        class="btn btn-danger"
        href="/logout"
        onclick="event.preventDefault();
                                document.getElementById('logout-form').submit();"
      >
        Logout
      </a>

      <form
        id="logout-form"
        action="/logout"
        method="POST"
        style="display: none"
      >
        <input type="hidden" name="_token" :value="csrfToken" />
      </form>
    </div>
    <div class="chat">
      <div class="chat-title">
        <h1>Chatroom</h1>
      </div>
      <div class="messages">
        <div class="messages-content">
          <div class="text-center py-2" v-if="isLoading">
            <svg
              version="1.1"
              id="loader-1"
              xmlns="http://www.w3.org/2000/svg"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              x="0px"
              y="0px"
              width="40px"
              height="40px"
              viewBox="0 0 50 50"
              style="enable-background: new 0 0 50 50"
              xml:space="preserve"
            >
              <path
                fill="#FF6700"
                d="M43.935,25.145c0-10.318-8.364-18.683-18.683-18.683c-10.318,0-18.683,8.365-18.683,18.683h4.068c0-8.071,6.543-14.615,14.615-14.615c8.072,0,14.615,6.543,14.615,14.615H43.935z"
                transform="rotate(18.3216 25 25)"
              >
                <animateTransform
                  attributeType="xml"
                  attributeName="transform"
                  type="rotate"
                  from="0 25 25"
                  to="360 25 25"
                  dur="0.6s"
                  repeatCount="indefinite"
                ></animateTransform>
              </path>
            </svg>
          </div>
          <ChatItem
            v-for="(message, index) in list_messages"
            :key="index"
            :message="message"
          ></ChatItem>
        </div>
      </div>
      <div class="message-box">
        <input
          maxlength="100"
          type="text"
          v-model="message"
          @keyup.enter="sendMessage"
          class="message-input"
          placeholder="Type message..."
        />
        <button type="button" class="message-submit" @click="sendMessage">
          Send
        </button>
      </div>
    </div>
    <div class="bg"></div>
    <div class="footer">
      <div>
        This demo uses Public channel, in production you probably need Private
        or Presence Channel to make your chat app secure.
      </div>
      <div>
        Check out my demo
        <a href="https://realtime-chat.jamesisme.com/" target="_blank">here</a>
      </div>
    </div>
  </div>
</template>

<script>
import ChatItem from "./ChatItem.vue";
export default {
  components: {
    ChatItem,
  },
  data() {
    return {
      message: "",
      list_messages: [],
      currentPage: 1,
      newMessageArrived: 0, // number of new messages we just got (use for scroll)
      lastPage: 1,
      csrfToken: "",
      usersOnline: 0,
      isLoading: false,
    };
  },
  created() {
    this.loadMessage(this.currentPage);
    Echo.channel("laravel_database_chatroom").listen(
      "MessagePosted",
      (data) => {
        let message = data.message;
        message.user = data.user;
        this.list_messages.push(message);
        this.scrollToBottom();
      }
    );
  },
  mounted() {
    this.csrfToken = document.head.querySelector(
      'meta[name="csrf-token"]'
    ).content;
    setInterval(() => {
      this.getUsersOnline();
    }, 3000);

    $(".messages").on("scroll", async () => {
      var scroll = $(".messages").scrollTop();
      if (scroll < 1 && this.currentPage < this.lastPage) {
        await this.loadMessage(this.currentPage + 1);
        const lastFirstMessage = $(
          `.message:nth-child(${this.newMessageArrived - 1})`
        );
        $(".messages").scrollTop(lastFirstMessage.position().top);
      }
    });
  },
  methods: {
    async loadMessage(page) {
      try {
        this.isLoading = true;
        const response = await axios.get(`/messages?page=${page}`);

        this.list_messages = [
          ...response.data.data.reverse(),
          ...this.list_messages,
        ];
        this.currentPage = response.data.current_page;
        this.lastPage = response.data.last_page;
        this.newMessageArrived = response.data.data.length;
        this.$nextTick(() => {
          if (page === 1) {
            this.scrollToBottom();
          }
          $(() => {
            $('[data-toggle="tooltip"]').tooltip();
          });
        });
      } catch (error) {
        console.log(error);
      } finally {
        this.isLoading = false;
      }
    },
    scrollToBottom() {
      const container = document.querySelector(".messages");
      if (container) {
        $(container).animate(
          { scrollTop: container.scrollHeight },
          { duration: "medium", easing: "swing" }
        );
      }
    },
    async sendMessage() {
      try {
        const response = await axios.post("/messages", {
          message: this.message,
        });
        this.list_messages.push(response.data.message);
        this.message = "";
        this.$nextTick(() => {
          this.scrollToBottom();
          $(() => {
            $('[data-toggle="tooltip"]').tooltip();
          });
        });
      } catch (error) {
        console.log(error);
      }
    },
    async getUsersOnline() {
      try {
        const host = `${window.location.protocol}//${window.location.hostname}:${process.env.MIX_FRONTEND_PORT}`
        const response = await axios.get(
          `${host}/apps/${this.$root.echoCredentials.appId}/channels/laravel_database_chatroom?auth_key=${this.$root.echoCredentials.key}`
        );

        this.usersOnline = response.data.subscription_count;
      } catch (error) {
        console.log(error);
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.messages {
  height: 80%;
  overflow-y: scroll;
  padding: 0 20px;
}
.bg {
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  z-index: 1;
  background: url("https://images.unsplash.com/photo-1451186859696-371d9477be93?crop=entropy&fit=crop&fm=jpg&h=975&ixjsv=2.1.0&ixlib=rb-0.3.5&q=80&w=1925")
    no-repeat 0 0;
  filter: blur(80px);
  transform: scale(1.2);
}
/*--------------------
Chat
--------------------*/
.chat {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 500px;
  height: 80vh;
  max-height: 700px;
  z-index: 2;
  overflow: hidden;
  box-shadow: 0 5px 30px rgba(0, 0, 0, 0.2);
  background: rgba(0, 0, 0, 0.5);
  border-radius: 20px;
  display: flex;
  justify-content: space-between;
  flex-direction: column;
}
/*--------------------
Chat Title
--------------------*/
.chat-title {
  flex: 0 1 45px;
  position: relative;
  z-index: 2;
  background: rgba(0, 0, 0, 0.2);
  color: #fff;
  text-transform: uppercase;
  text-align: left;
  padding: 10px 10px 10px 50px;

  h1,
  h2 {
    font-weight: normal;
    font-size: 16px;
    margin: 0;
    padding: 0;
  }
  h2 {
    color: rgba(255, 255, 255, 0.5);
    font-size: 8px;
    letter-spacing: 1px;
  }

  .avatar {
    position: absolute;
    z-index: 1;
    top: 8px;
    left: 9px;
    border-radius: 30px;
    width: 30px;
    height: 30px;
    overflow: hidden;
    margin: 0;
    padding: 0;
    border: 2px solid rgba(255, 255, 255, 0.24);
    img {
      width: 100%;
      height: auto;
    }
  }
}
/*--------------------
Message Box
--------------------*/
.message-box {
  flex: 0 1 40px;
  width: 100%;
  background: rgba(0, 0, 0, 0.3);
  padding: 10px;
  position: relative;

  & .message-input {
    background: none;
    border: none;
    outline: none !important;
    resize: none;
    color: rgba(255, 255, 255, 0.7);
    font-size: 11px;
    height: 17px;
    margin: 0;
    padding-right: 20px;
    width: 90%;
  }
  textarea:focus:-webkit-placeholder {
    color: transparent;
  }

  & .message-submit {
    position: absolute;
    z-index: 1;
    top: 9px;
    right: 10px;
    color: #fff;
    border: none;
    background: #248a52;
    font-size: 10px;
    text-transform: uppercase;
    line-height: 1;
    padding: 6px 10px;
    border-radius: 10px;
    outline: none !important;
    transition: background 0.2s ease;
    &:hover {
      background: #1d7745;
    }
  }
}
.btn-logout {
  position: absolute;
  top: 20px;
  right: 50px;
  z-index: 3;
}
.users-online {
  position: absolute;
  top: 20px;
  left: 50px;
  z-index: 3;
}
.footer {
  position: absolute;
  bottom: 10px;
  width: 100%;
  color: white;
  text-align: center;
  z-index: 1;
}
</style>