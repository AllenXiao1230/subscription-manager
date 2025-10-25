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

const emit = defineEmits(['close', 'membersUpdated', 'memberCreated'])

const currentMembers = ref([])
const loading = ref(false)
const newMemberName = ref('') 

// (fetchCurrentMembers 無變動)
async function fetchCurrentMembers() {
  if (!props.subscription) return;
  loading.value = true;
  try {
    const res = await fetch(`/api/subscriptions/${props.subscription.id}/members`);
    currentMembers.value = await res.json();
  } catch (error) {
    console.error("無法取得成員:", error);
  } finally {
    loading.value = false;
  }
}

// (watch 無變動)
watch(() => props.show, (newVal) => {
  if (newVal) {
    fetchCurrentMembers();
    newMemberName.value = ''; 
  }
});

// (*** (REQUEST) 修改 handleAddMember ***)
async function handleAddMember() {
  if (!newMemberName.value || newMemberName.value.trim() === '') {
    alert('請輸入新成員的名稱');
    return;
  }
  
  try {
    // 1. 建立成員
    const createRes = await fetch('/api/members', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: newMemberName.value })
    });
    if (!createRes.ok) throw new Error('建立新成員失敗');
    const newMember = await createRes.json();
    
    // 2. 將成員加入訂閱
    const addRes = await fetch(`/api/subscriptions/${props.subscription.id}/members`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ member_id: newMember.id })
    });
    if (!addRes.ok) throw new Error('將成員加入訂閱失敗');

    // 3. 重新計算均分
    await fetch(`/api/subscriptions/${props.subscription.id}/recalculate`, {
      method: 'POST'
    });

    // 4. 觸發事件
    emit('membersUpdated'); // 通知 Card
    emit('memberCreated'); // 通知 App
    newMemberName.value = ''; 

  } catch (error) {
    console.error("新增成員失敗:", error);
    alert(`新增成員失敗: ${error.message}`);
  } finally {
    // (*** (NEW) ***)
    // 無論成功或失敗，都「立即」重新整理 Modal 內的列表
    await fetchCurrentMembers(); 
  }
}

// (*** (REQUEST) 修改 handleRemoveMember ***)
async function handleRemoveMember(memberId) {
  if (!confirm('確定要移除此成員嗎？')) return;
  
  try {
    // 1. 移除成員
    await fetch(`/api/subscriptions/${props.subscription.id}/members/${memberId}`, {
      method: 'DELETE'
    });

    // 2. 重新計算均分
    await fetch(`/api/subscriptions/${props.subscription.id}/recalculate`, {
      method: 'POST'
    });

    // 3. 觸發事件
    emit('membersUpdated');

  } catch (error) {
    console.error("移除成員失敗:", error);
  } finally {
    // (*** (NEW) ***)
    // 無論成功或失敗，都「立即」重新整理 Modal 內的列表
    await fetchCurrentMembers();
  }
}
</script>

<template>
  <div v-if="show" class="modal-overlay" @click.self="emit('close')">
    <div class="modal-content">
      <h3>管理 {{ subscription.name }} 的成員</h3>
      
      <h4>現有成員</h4>
      <div v-if="loading">載入中...</div>
      <ul v-else class="member-list">
        <li v-for="member in currentMembers" :key="member.id">
          <span>{{ member.name }} (分攤 $ {{ member.share_amount }})</span>
          <button @click="handleRemoveMember(member.id)" class="remove-btn">移除</button>
        </li>
      </ul>

      <hr />

      <h4>新增成員</h4>
      <form @submit.prevent="handleAddMember" class="add-form">
        <input 
          v-model.trim="newMemberName" 
          type="text" 
          placeholder="輸入新成員名稱" 
          class="add-member-input"
        />
        <button type="submit">新增</button>
      </form>

      <div class="modal-actions">
        <button type="button" @click="emit('close')">完成</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* (Style 內容無變動) */
.add-form {
  /* (樣式由 App.vue 全域控制) */
}
.add-member-input {
  flex: 1; 
  padding: 8px !important;
}
</style>