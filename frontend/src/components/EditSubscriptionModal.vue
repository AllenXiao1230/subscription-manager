<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  subscription: {
    type: Object,
    default: null
  },
  allMembers: {
    type: Array,
    default: () => []
  },
  show: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'subscriptionUpdated'])

const formData = ref({})

// (Script 內容無變動)
watch(() => props.subscription, (newSub) => {
  if (newSub) {
    formData.value = { ...newSub };
  }
}, { immediate: true })

async function handleSubmit() {
  try {
    const res = await fetch(`/api/subscriptions/${props.subscription.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData.value)
    });
    if (!res.ok) throw new Error('更新失敗');
    
    emit('subscriptionUpdated'); 
    emit('close'); 
  } catch (error) {
    console.error("更新失敗:", error);
    alert('更新失敗');
  }
}
</script>

<template>
  <div v-if="show" class="modal-overlay" @click.self="emit('close')">
    <div class="modal-content">
      <h3>編輯 {{ subscription.name }}</h3>
      <form @submit.prevent="handleSubmit">
        <div>
          <label>名稱：</label>
          <input v-model="formData.name" type="text" />
        </div>
        <div>
          <label>總價格：</label>
          <input v-model.number="formData.total_price" type="number" />
        </div>
        <div>
          <label>週期：</label>
          <select v-model="formData.billing_cycle">
            <option value="monthly">每月</option>
            <option value="yearly">每年</option>
            <option value="once">一次性</option>
          </select>
        </div>
        <div>
          <label>下次付款日：</label>
          <input v-model="formData.next_payment_date" type="date" />
        </div>
        <div>
          <label>主要付款人：</label>
          <select v-model.number="formData.payment_owner_id">
            <option :value="null">-- 無 --</option>
            <option v-for="member in allMembers" :key="member.id" :value="member.id">
              {{ member.name }}
            </option>
          </select>
        </div>
        <div class="modal-actions">
          <button type="button" @click="emit('close')">取消</button>
          <button type="submit">儲存變更</button>
        </div>
      </form>
    </div>
  </div>
</template>

