<script setup>
import { ref, onMounted, computed, watch } from 'vue'

const props = defineProps({
  subscription: {
    type: Object,
    required: true
  },
  selectedYear: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['editSub', 'editMembers', 'subscriptionDeleted'])

const members = ref([])
const payments = ref([])
const loading = ref(true)
// (*** 1. 新增編輯模式狀態 ***)
const isEditingPayments = ref(false)

const timeColumns = computed(() => {
  const months = [];
  if (!props.selectedYear) return []; 
  for (let i = 0; i < 12; i++) {
    const date = new Date(props.selectedYear, i, 1);
    const monthId = date.toISOString().substring(0, 7); 
    const monthLabel = date.toLocaleString('zh-TW', { month: 'short' }); 
    months.push({ id: monthId, label: monthLabel });
  }
  return months;
});

const paymentLookup = computed(() => {
  const lookup = new Set();
  for (const payment of payments.value) {
    const key = `${payment.member_id}-${payment.billing_period}`;
    lookup.add(key);
  }
  return lookup;
});

function getPaymentStatus(memberId, monthId) {
  const key = `${memberId}-${monthId}`;
  return paymentLookup.value.has(key) ? '✅' : '❌';
}

async function fetchDetails() {
  loading.value = true;
  try {
    const [membersRes, paymentsRes] = await Promise.all([
      fetch(`/api/subscriptions/${props.subscription.id}/members`),
      fetch(`/api/subscriptions/${props.subscription.id}/payments`)
    ]);
    members.value = await membersRes.json();
    payments.value = await paymentsRes.json();
  } catch (error) {
    console.error("無法載入訂閱詳情:", error);
  } finally {
    loading.value = false;
  }
}

watch(() => props.subscription, () => {
}, { deep: true });

async function togglePayment(member, monthId) {
  // (*** 2. 如果沒有在編輯模式，直接結束函數 ***)
  if (!isEditingPayments.value) return;

  const key = `${member.id}-${monthId}`;
  const isPaid = paymentLookup.value.has(key);
  
  try {
    if (isPaid) {
      await fetch('/api/payments', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          subscription_id: props.subscription.id,
          member_id: member.id,
          billing_period: monthId
        })
      });
    } else {
      await fetch('/api/payments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          subscription_id: props.subscription.id,
          member_id: member.id,
          amount_paid: member.share_amount, 
          billing_period: monthId
        })
      });
    }
    await fetchDetails();
  } catch (error) {
    console.error("更新付款狀態失敗:", error);
    alert('操作失敗');
  }
}

async function deleteSubscription() {
  if (!confirm(`確定要刪除「${props.subscription.name}」嗎？所有付款紀錄將一併刪除。`)) {
    return;
  }
  try {
    await fetch(`/api/subscriptions/${props.subscription.id}`, {
      method: 'DELETE'
    });
    emit('subscriptionDeleted', props.subscription.id);
  } catch (error) {
    console.error("刪除失敗:", error);
    alert('刪除失敗');
  }
}

onMounted(() => {
  fetchDetails();
});

defineExpose({
  fetchDetails
});
</script>

<template>
  <div class="subscription-card">
    <div class="card-header">
      <div class="subscription-info">
        <h2>{{ subscription.name }}</h2>
        <ul>
          <li><strong>總金額：</strong> $ {{ subscription.total_price }} / {{ subscription.billing_cycle }}</li>
          <li><strong>主要付款人：</strong> {{ subscription.owner_name || 'N/A' }}</li>
          <li><strong>下次付款日：</strong> {{ subscription.next_payment_date || 'N/A' }}</li>
        </ul>
      </div>
      
      <div class="edit-buttons">
        <button 
          @click="isEditingPayments = !isEditingPayments" 
          :class="['btn-toggle-edit', { 'is-active': isEditingPayments }]"
        >
           <svg v-if="!isEditingPayments" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
           <svg v-else xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 9.9-1"></path></svg>
          <span>{{ isEditingPayments ? '完成繳款' : '編輯繳款' }}</span>
        </button>
        
        <button @click="emit('editSub', subscription)" class="btn-edit">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
          </button>
        <button @click="emit('editMembers', subscription)" class="btn-members">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
        </button>
        <button @click="deleteSubscription" class="btn-delete">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>
        </button>
      </div>
    </div>

    <div class="payment-grid-container">
      <div v-if="loading">載入付款明細中...</div>
      <table v-else class="payment-grid">
        <thead>
          <tr>
            <th>成員 (Y 軸)</th>
            <th v-for="month in timeColumns" :key="month.id">
              {{ month.label }}
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="member in members" :key="member.id">
            <td>{{ member.name }} ($ {{ member.share_amount }})</td>
            
            <td 
              v-for="month in timeColumns" 
              :key="month.id" 
              :class="['status-cell', { 'is-editable': isEditingPayments }]"
              @click="togglePayment(member, month.id)"
            >
              <span :style="{ opacity: isEditingPayments ? 1 : 0.5 }">
                {{ getPaymentStatus(member.id, month.id) }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped>
.subscription-card {
  margin-bottom: 2rem;
  overflow: hidden;
}
.card-header {
  display: flex;
  flex-wrap: wrap; 
  justify-content: space-between;
  align-items: flex-start;
  padding: 1.5rem 2rem; 
  border-bottom: 1px solid var(--color-border);
}

.subscription-info {
  flex: 1;
  min-width: 250px;
  margin-right: 1rem;
}
.subscription-info h2 {
  margin: 0 0 0.75rem 0;
  font-size: 1.75rem;
}
.subscription-info ul {
  margin: 0;
  padding: 0;
  list-style: none;
}
.subscription-info li {
  margin-bottom: 0.25rem;
  font-size: 0.95rem;
}
.subscription-info li strong {
  color: var(--color-text-secondary);
  font-weight: 500;
}

.edit-buttons {
  display: flex;
  flex-direction: row; 
  gap: 0.5rem; /* 稍微縮小間距以容納更多按鈕 */
  flex-shrink: 0; 
  align-items: center;
}

.edit-buttons button {
  background-color: #3F3F46; 
  color: var(--color-text-primary);
  border: 1px solid #52525B;
  padding: 8px 12px;
  font-size: 0.9rem;
  font-weight: 500;
}
.edit-buttons button:hover {
  background-color: #52525B;
  border-color: #71717A;
}

/* (*** 6. 編輯繳款按鈕的特殊樣式 ***) */
.btn-toggle-edit.is-active {
  background-color: var(--color-accent) !important; /* 激活時變色 */
  border-color: var(--color-accent) !important;
  color: white !important;
}

.btn-delete, .btn-delete:hover {
  background: var(--color-danger-bg);
  color: var(--color-danger-text);
  border-color: var(--color-danger-border);
}

.payment-grid-container { 
  padding: 0 2rem 1.5rem 2rem; 
  overflow-x: auto; 
}
.payment-grid { 
  width: 100%; 
  border-collapse: collapse; 
  text-align: center; 
}

.payment-grid th,
.payment-grid td {
  padding: 1rem 0.5rem; 
}
.payment-grid th:first-child,
.payment-grid td:first-child {
  width: 200px; 
  min-width: 200px; 
  text-align: left;
  white-space: nowrap; 
  padding-left: 1rem; 
}
.payment-grid th:not(:first-child),
.payment-grid td:not(:first-child) {
  width: 65px; 
  text-align: center;
}

/* (*** 7. 狀態儲存格樣式修改 ***) */
.status-cell {
  font-size: 1.2rem;
  cursor: default; /* 預設不可點擊 */
  user-select: none;
  border-radius: 4px;
  transition: background-color 0.2s;
}
/* 只有在編輯模式下，才顯示為可點擊，並有 hover 效果 */
.status-cell.is-editable {
  cursor: pointer;
}
.status-cell.is-editable:hover {
   background-color: #404040 !important; /* 只有編輯時才有 hover 背景 */
}
</style>
