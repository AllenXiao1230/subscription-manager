<script setup>
// (Script 內容完全沒有變動，已保留您現有的)
import { ref, onMounted, computed } from 'vue' 
import SubscriptionCard from './components/SubscriptionCard.vue'
import EditSubscriptionModal from './components/EditSubscriptionModal.vue'
import ManageMembersModal from './components/ManageMembersModal.vue'
import AddSubscriptionModal from './components/AddSubscriptionModal.vue' 

const allSubscriptions = ref([])
const allMembers = ref([])
const loading = ref(true)
const errorMsg = ref(null)
const cardRefs = ref([])
const showEditModal = ref(false)
const showMembersModal = ref(false)
const showAddModal = ref(false) 
const selectedSubscription = ref(null) 

const fileInput = ref(null)

const currentYear = new Date().getFullYear() 
const selectedYear = ref(currentYear) 
const availableYears = computed(() => {
  return [currentYear - 2, currentYear - 1, currentYear, currentYear + 1]
})

onMounted(() => {
  fetchSubscriptions()
  fetchAllMembers()
})

async function fetchSubscriptions() {
  loading.value = true
  errorMsg.value = null
  try {
    const response = await fetch('/api/subscriptions', { cache: 'no-store' })
    if (!response.ok) throw new Error('無法載入訂閱列表');
    allSubscriptions.value = await response.json()
  } catch (error) {
    console.error(error);
    errorMsg.value = error.message;
  } finally {
    loading.value = false
  }
}

async function fetchAllMembers() {
  try {
    const response = await fetch('/api/members', { cache: 'no-store' })
    allMembers.value = await response.json()
  } catch (error) {
    console.error("無法載入成員列表:", error);
  }
}

function handleExportDB() {
  window.location.href = '/api/export';
}

// (*** NEW: 匯入相關函數 ***)
// 1. 觸發隱藏的檔案選擇器
function triggerImport() {
  if (!confirm('警告：匯入將會「覆蓋」目前所有的資料！您確定要繼續嗎？')) return;
  fileInput.value.click();
}

// 2. 當使用者選好檔案後執行
async function handleImportFile(event) {
  const file = event.target.files[0];
  if (!file) return;

  // 建立 FormData 來上傳檔案
  const formData = new FormData();
  formData.append('backup_file', file);

  loading.value = true; // 顯示載入中

  try {
    const response = await fetch('/api/import', {
      method: 'POST',
      body: formData, // 瀏覽器會自動設定正確的 Content-Type (multipart/form-data)
    });

    if (!response.ok) throw new Error('匯入失敗');

    alert('資料庫匯入成功！');
    // 匯入完成後，重新整理所有資料
    await fetchSubscriptions();
    await fetchAllMembers();

  } catch (error) {
    console.error(error);
    alert('匯入失敗，請檢查檔案是否正確。');
  } finally {
    loading.value = false;
    event.target.value = ''; // 清空檔案選擇器，允許重複選擇同個檔案
  }
}

function openEditModal(subscription) {
  selectedSubscription.value = subscription;
  showEditModal.value = true;
}

function openMembersModal(subscription) {
  selectedSubscription.value = subscription;
  showMembersModal.value = true;
}

function handleSubscriptionDeleted(deletedId) {
  allSubscriptions.value = allSubscriptions.value.filter(
    (sub) => sub.id !== deletedId
  );
}

function handleSubscriptionUpdated() {
  showEditModal.value = false;
  fetchSubscriptions(); 
}

function handleMembersUpdated(subId) {
  const card = cardRefs.value.find(c => c.subscription.id === subId);
  if (card) {
    card.fetchDetails();
  }
}

function handleMemberCreated() {
  fetchAllMembers();
}

function handleSubscriptionAdded() {
  showAddModal.value = false
  fetchSubscriptions() 
}
</script>

<template>
  <main>
    <div class="main-header">
      <h1>我的訂閱管理</h1>
      
      <div class="header-actions">
        <button @click="triggerImport" class="import-btn">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
          <span>匯入資料庫</span>
        </button>

        <button @click="handleExportDB" class="export-btn">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
          <span>匯出資料庫</span>
        </button>

        <button @click="showAddModal = true" class="add-main-btn">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
          <span>新增訂閱</span>
        </button>
      </div>
    </div>

    <hr />

    <div class="subscriptions-header">
      <h2>目前訂閱</h2>
      <div class="year-selector">
        <label for="year-select">選擇年份：</label>
        <select id="year-select" v-model.number="selectedYear">
          <option v-for="year in availableYears" :key="year" :value="year">
            {{ year }}
          </option>
        </select>
      </div>
    </div>

    <div v-if="loading">載入中...</div>
    <div v-if="errorMsg" class="error">{{ errorMsg }}</div>

    <div v-if="!loading && !errorMsg">
      <div v-if="allSubscriptions.length === 0">尚未有任何訂閱項目。</div>
      <SubscriptionCard
        v-for="sub in allSubscriptions"
        :key="sub.id"
        :subscription="sub"
        :selected-year="selectedYear" 
        ref="cardRefs"
        @edit-sub="openEditModal"
        @edit-members="openMembersModal"
        @subscription-deleted="handleSubscriptionDeleted"
      />
    </div>
    <input
      type="file"
      ref="fileInput"
      accept=".sql"
      style="display: none"
      @change="handleImportFile"
    />

    <AddSubscriptionModal
      :show="showAddModal"
      :all-members="allMembers"
      @close="showAddModal = false"
      @subscription-added="handleSubscriptionAdded"
    />
    <EditSubscriptionModal
      :show="showEditModal"
      :subscription="selectedSubscription"
      :all-members="allMembers"
      @close="showEditModal = false"
      @subscription-updated="handleSubscriptionUpdated"
    />
    <ManageMembersModal
      :show="showMembersModal"
      :subscription="selectedSubscription"
      :all-members="allMembers"
      @close="showMembersModal = false"
      @members-updated="handleMembersUpdated(selectedSubscription.id)"
      @member-created="handleMemberCreated" 
    />
  </main>
</template>

<style>
/* --- 全新的「專業深色」CSS --- */

/* 1. 全域與字體設定 */
:root {
  --color-bg: #18181B;
  --color-card: #27272A;
  --color-border: #3F3F46;
  --color-text-primary: #E4E4E7;
  --color-text-secondary: #A1A1AA;
  --color-accent: #14B8A6;
  --color-accent-hover: #0D9488;
  --color-danger-bg: #450A0A;
  --color-danger-text: #F87171;
  --color-danger-border: #7F1D1D;
}

body {
  background-color: var(--color-bg);
  color: var(--color-text-primary);
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  line-height: 1.6;
}

#app {
  max-width: none;
  margin: 0;
  padding: 0;
}

main {
  width: 100%;
  padding: 1rem; 
  box-sizing: border-box; 
  background: var(--color-bg);
}

/* 2. 容器 (卡片/Modal) */
.subscription-card,
.modal-content {
  background: var(--color-card) !important;
  border: 1px solid var(--color-border) !important;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

/* 3. 文字 */
h1, h2, h3, h4, label {
  color: var(--color-text-primary) !important;
  font-weight: 600;
}
.subscription-info ul,
.subscription-info li {
  color: var(--color-text-secondary) !important;
}

/* 4. 表單 (Input/Select) */
input, select {
  background-color: #3F3F46;
  color: var(--color-text-primary);
  border: 1px solid #52525B;
  border-radius: 8px;
  padding: 12px;
  width: 100%;
  box-sizing: border-box;
  transition: border-color 0.2s, box-shadow 0.2s;
}
input:focus, select:focus {
  outline: none;
  border-color: var(--color-accent);
  box-shadow: 0 0 0 3px rgba(20, 184, 166, 0.3);
}
input::placeholder { color: var(--color-text-secondary); }
input[type="date"]::-webkit-calendar-picker-indicator { filter: invert(0.8); }

/* 5. 按鈕 (通用) */
button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 10px 16px;
  background-color: var(--color-accent);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: background-color 0.2s;
}
button:hover {
  background-color: var(--color-accent-hover);
}
button.submit-btn {
  padding: 12px 16px;
}

/* 6. 表格 (斑馬紋) */
.payment-grid th { 
  background-color: #3F3F46 !important;
  font-weight: 600;
  padding: 0.75rem;
}
.payment-grid td { 
  border-color: var(--color-border) !important;
}
.payment-grid tbody tr:nth-child(odd) td {
  background-color: var(--color-card);
}
.payment-grid tbody tr:nth-child(even) td {
  background-color: #313134;
}
.status-cell:hover { 
  background-color: #404040 !important;
}

/* 7. 其他 */
hr { margin: 2rem 0; border: 0; border-top: 1px solid var(--color-border); }
.error { color: #F87171; }

/* 8. Modal 樣式 (全域) */
.modal-overlay {
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(4px);
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  display: flex;
  justify-content: center; align-items: center; z-index: 1000;
}
.modal-content {
  padding: 2rem;
  min-width: 450px;
}
.modal-content div { margin-bottom: 1rem; }
.modal-actions {
  display: flex; justify-content: flex-end; gap: 1rem;
  margin-top: 1.5rem; margin-bottom: 0;
}
.modal-actions button[type="button"] {
  background-color: #52525B;
}
.modal-actions button[type="button"]:hover {
  background-color: #71717A;
}
.member-list { list-style: none; padding: 0; }
.member-list li {
  display: flex; justify-content: space-between; align-items: center;
  padding: 0.75rem 0.25rem; 
  border-bottom: 1px solid var(--color-border);
}
.remove-btn, .remove-btn:hover {
  background: var(--color-danger-bg);
  color: var(--color-danger-text);
  border: 1px solid var(--color-danger-border);
  padding: 4px 8px;
}
.add-form {
  display: flex; gap: 10px; align-items: center;
}
.add-form select, .add-form input { 
  flex: 1; 
  padding: 12px;
}

/* 9. 響應式表單 (Modal) */
.modal-content form {
  margin-top: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

/* 10. 年份選擇器 */
.subscriptions-header {
  margin-bottom: 1rem; 
}
.year-selector {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-top: 1rem; 
}
.year-selector label {
  color: var(--color-text-secondary);
  font-weight: 500;
}
.year-selector select {
  width: 120px;
  padding: 10px 8px;
}

/* 11. 主標題列 (Header) */
.main-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem; 
}
.main-header h1 {
  margin: 0;
  font-size: 2rem;
}

/* --- (NEW) 標題區按鈕群組 --- */
.header-actions {
  display: flex;
  gap: 0.75rem;
}

/* 按鈕通用設定 (包含動畫基礎) */
.header-actions button {
  display: flex;
  align-items: center;
  padding: 10px 14px; /* 維持舒適的點擊範圍 */
  height: 42px;       /* 固定高度，避免動畫時高度跳動 */
  font-weight: 500;
  border-radius: 8px; /* 確保有圓角 */
  cursor: pointer;
  transition: all 0.3s ease; /* 讓按鈕本身的背景色/邊框變化也有動畫 */
}

/* (關鍵) 文字標籤的動畫設定 */
.header-actions button span {
  max-width: 0;                /* 預設寬度為 0 (隱藏) */
  opacity: 0;                  /* 預設透明 */
  white-space: nowrap;         /* 防止文字換行 */
  overflow: hidden;            /* 隱藏超出的文字 */
  transition: all 0.3s ease;   /* 動畫設定：0.3秒平滑切換 */
}

/* (關鍵) 懸停時顯示文字 */
.header-actions button:hover span {
  max-width: 100px;    /* 給予足夠的寬度讓文字顯示 */
  opacity: 1;          /* 變為不透明 */
  margin-left: 8px;    /* 文字與圖示之間的間距 (只在顯示時才加) */
}


/* --- 個別按鈕顏色設定 (維持上一版的統一性設計) --- */

/* 匯入按鈕 */
.import-btn {
  background-color: var(--color-card);
  border: 1px solid var(--color-border);
  color: var(--color-text-secondary);
}
.import-btn:hover {
  background-color: #313134;
  border-color: #52525B;
  color: var(--color-text-primary);
}

/* 匯出按鈕 */
.export-btn {
  background-color: transparent;
  border: 1px solid var(--color-accent);
  color: var(--color-accent);
}
.export-btn:hover {
  background-color: var(--color-accent);
  color: white;
}




/* 響應式：平板與桌面 (大於 768px) */
@media (min-width: 768px) {
  main {
    padding: 2.5rem;
  }

  .modal-content form {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem 1.5rem;
  }
}
</style>
