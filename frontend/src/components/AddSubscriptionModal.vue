<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  allMembers: {
    type: Array,
    default: () => []
  },
  show: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close', 'subscriptionAdded'])

// 表單的初始狀態
const getInitialForm = () => ({
  name: '',
  total_price: null,
  billing_cycle: 'monthly',
  next_payment_date: null,
  payment_owner_id: null
})

// 表單資料
const newSubForm = ref(getInitialForm())

// 當 Modal 顯示時 (props.show 變為 true)，重置表單
watch(() => props.show, (newVal) => {
  if (newVal) {
    newSubForm.value = getInitialForm()
  }
})

// (NEW) 提交新訂閱
async function handleAddSubscription() {
  if (!newSubForm.value.name || !newSubForm.value.total_price) {
    alert('請輸入名稱和價格')
    return
  }
  
  try {
    const response = await fetch('/api/subscriptions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newSubForm.value),
    })

    if (!response.ok) {
      const errData = await response.json()
      throw new Error(errData.error || '新增失敗')
    }

    // 通知 App.vue 新增成功
    emit('subscriptionAdded') 
    // 關閉 Modal
    emit('close')

  } catch (error) {
    console.error('新增訂閱失敗:', error)
    alert(`新增失敗: ${error.message}`)
  }
}

</script>

<template>
  <div v-if="show" class="modal-overlay" @click.self="emit('close')">
    <div class="modal-content">
      <h3>新增訂閱項目</h3>
      
      <form @submit.prevent="handleAddSubscription">
        <div>
          <label>名稱：</label>
          <input v-model.trim="newSubForm.name" type="text" />
        </div>
        <div>
          <label>總價格：</label>
          <input v-model.number="newSubForm.total_price" type="number" />
        </div>
        <div>
          <label>週期：</label>
          <select v-model="newSubForm.billing_cycle">
            <option value="monthly">每月</option>
            <option value="yearly">每年</option>
            <option value="once">一次性</option>
          </select>
        </div>
        <div>
          <label>下次付款日：</label>
          <input v-model="newSubForm.next_payment_date" type="date" />
        </div>
        <div>
          <label>主要付款人：</label>
          <select v-model.number="newSubForm.payment_owner_id">
            <option :value="null">-- 無 --</option>
            <option v-for="member in allMembers" :key="member.id" :value="member.id">
              {{ member.name }}
            </option>
          </select>
        </div>
        
        <div class="modal-actions">
          <button type="button" @click="emit('close')">取消</button>
          <button type="submit">新增</button>
        </div>
      </form>
    </div>
  </div>
</template>