import "./bootstrap";
import { createApp } from "vue";
import ChatLayout from "./components/ChatLayout.vue";

const app = createApp({
    data: () => {
        return {
            currentUserLogin: {},
        };
    },
    created() {
        this.getCurrentUserLogin();
    },
    methods: {
        async getCurrentUserLogin() {
            try {
                const response = await axios.get("/getUserLogin");
                this.currentUserLogin = response.data;
            } catch (error) {
                console.log(error);
            }
        },
    },
});
app.component("chat-layout", ChatLayout);
app.mount("#app");
