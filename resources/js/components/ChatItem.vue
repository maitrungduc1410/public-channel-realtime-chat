<script setup>
import { computed, onMounted, ref } from "vue";
import { Tooltip } from "bootstrap";

const props = defineProps({
    message: Object,
});

const elRef = ref(null);

onMounted(() => {
    const tooltipTriggerList = elRef.value.querySelectorAll(
        '[data-bs-toggle="tooltip"]'
    );
    [...tooltipTriggerList].map(
        (tooltipTriggerEl) => new Tooltip(tooltipTriggerEl)
    );
});

const createdAt = computed(() => {
    const offset = new Date().getTimezoneOffset();
    const date = new Date(props.message.created_at);
    date.setMinutes(date.getMinutes() - offset);
    return date.toLocaleString();
});
</script>

<template>
    <div
        ref="elRef"
        class="message"
        :class="{
            'is-current-user': $root.currentUserLogin.id === message.user.id,
        }"
    >
        <div
            class="message-item user-name"
            data-bs-toggle="tooltip"
            data-bs-placement="top"
            :data-bs-title="message.user.email"
        >
            {{ message.user.name }}
        </div>
        <div class="message-item timestamp d-flex">
            |
            <span
                data-bs-toggle="tooltip"
                data-bs-placement="top"
                :data-bs-title="createdAt"
                >{{ createdAt.split(" ")[1] }}</span
            >:
        </div>
        <div class="message-item text-message">
            {{ message.message }}
        </div>
    </div>
</template>

<style lang="scss" scoped>
.message {
    display: flex;
    color: #00b8ff;
    .message-item {
        &:not(:last-child) {
            margin-right: 5px;
        }

        &.timestamp {
            gap: 2px;
        }

        &.text-message {
            word-break: break-word;
        }
    }
}
.message:not(:last-child) {
    padding-bottom: 20px;
}
.is-current-user {
    color: #a900ff;
}
</style>
