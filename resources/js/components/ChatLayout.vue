<script setup>
import { ref, onBeforeMount, onMounted, nextTick } from "vue";
import ChatItem from "./ChatItem.vue";
import laravelEchoServer from "../../../laravel-echo-server.json";
import $ from "jquery";

const message = ref("");
const maxMessageLength = parseInt(
    import.meta.env.VITE_CHAT_MAX_MESSAGE_LENGTH || "1000"
);

const list_messages = ref([]);

const { appId, key } = laravelEchoServer.clients[0]; // thêm mới
const csrfToken = ref(""); // thêm mới
const usersOnline = ref(0); // thêm mới

const isLoading = ref(0);
let currentPage = 1;
let lastPage = 1;
let perPage = parseInt(import.meta.env.VITE_CHAT_MESSAGE_PER_PAGE || "50"); // not related to rendering no need to be reactive

onBeforeMount(() => {
    loadMessage(currentPage);
    Echo.channel("laravel_database_chatroom").listen(
        "MessagePosted",
        (data) => {
            const message = data.message;
            message.user = data.user;
            list_messages.value.push(message);
        }
    );
});

onMounted(() => {
    // lấy giá trị csrfToken
    csrfToken.value = document.head.querySelector(
        'meta[name="csrf-token"]'
    ).content;

    setInterval(() => {
        getUsersOnline(); // lấy số users online mỗi 3 giây (tuỳ chỉnh theo ý muốn)
    }, 3000);

    $(".messages").on("scroll", async () => {
        if (isLoading.value) {
            return;
        }
        var scroll = $(".messages").scrollTop();
        if (scroll < 1 && currentPage < lastPage) {
            console.log(currentPage + 1)
            await loadMessage(currentPage + 1, true);
        }
    });
});

async function loadMessage(page = 1, preserveScroll = false) {
    try {
        isLoading.value = true;

        const $messagesContainer = $(".messages");
        const scrollOffset = preserveScroll ? $messagesContainer[0].scrollHeight - $messagesContainer.scrollTop() : null;

        const response = await axios.get(`/messages?page=${page}&per_page=${perPage}`);
        const { data, current_page, last_page } = response.data;
        
        // Update messages
        list_messages.value = [...data.reverse(), ...list_messages.value];
        currentPage = current_page;
        lastPage = last_page;

        await nextTick(); // Wait for Vue to render

        // Calculate new height after adding new messages (after Vue re-renders = after nextTick)
        const newHeight = preserveScroll ? $messagesContainer[0].scrollHeight : 0;

        if (preserveScroll && scrollOffset !== null) {
            // Adjust scroll position to maintain relative position
            $messagesContainer.scrollTop(newHeight - scrollOffset);
        } else if (page === 1) {
            scrollToBottom(false);
        }
    } catch (error) {
        console.log(error);
    } finally {
        isLoading.value = false;
    }
}

function scrollToBottom(animate = true) {
    const container = document.querySelector(".messages");
    if (container) {
        if (animate) {
            $(container).animate(
                { scrollTop: container.scrollHeight },
                { duration: "medium", easing: "swing" }
            );
        } else {
            $(container).scrollTop(container.scrollHeight)
        }
    }
}

async function sendMessage() {
    try {
        const response = await axios.post("/messages", {
            message: message.value,
        });
        list_messages.value.push(response.data.message);
        message.value = "";

        nextTick(() => {
            scrollToBottom();
        });
    } catch (error) {
        console.log(error);
    }
}

async function getUsersOnline() {
    try {
        const response = await axios.get(
            `${window.location.protocol}//${window.location.hostname}:6001/apps/${appId}/channels/laravel_database_chatroom?auth_key=${key}`
        );
        usersOnline.value = response.data.subscription_count;
    } catch (error) {
        console.log(error);
    }
}
</script>

<template>
    <div>
        <div class="users-online">
            <button type="button" class="btn btn-primary">
                Users online:
                <span class="badge badge-light">{{ usersOnline }}</span>
            </button>
        </div>
        <div class="btn-logout">
            <a
                class="btn btn-danger"
                href="/logout"
                onclick="event.preventDefault();document.getElementById('logout-form').submit();"
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
                        :key="message.id"
                        :message="message"
                    ></ChatItem>
                </div>
            </div>
            <div class="message-box">
                <input
                    type="text"
                    v-model="message"
                    @keyup.enter="sendMessage"
                    class="message-input"
                    placeholder="Type message..."
                    :maxlength="maxMessageLength"
                />
                <small class="text-white">
                    {{ message.length }} / {{ maxMessageLength }}
                </small>
                <button
                    type="button"
                    class="message-submit"
                    @click="sendMessage"
                >
                    Send
                </button>
            </div>
        </div>
        <div class="bg"></div>
    </div>
</template>

<style lang="scss" scoped>
.messages {
    height: 80%;
    overflow-y: scroll;
    padding: 0 20px;
}
/*--------------------
Body
--------------------*/
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
        width: 100%;

        &::-webkit-scrollbar {
            display: none;
        }
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

.users-online {
    position: absolute;
    top: 20px;
    left: 50px;
    z-index: 3;
}
.btn-logout {
    position: absolute;
    top: 20px;
    right: 50px;
    z-index: 3;
}
</style>
