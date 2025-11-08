<script setup>
// App.vue 現在非常乾淨，只負責路由
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <header class="navbar">
    <nav>
      <RouterLink to="/" class="nav-link">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
        <span>儀表板</span>
      </RouterLink>
      <RouterLink to="/subscriptions" class="nav-link">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>
        <span>訂閱列表</span>
      </RouterLink>
    </nav>
  </header>

  <main>
    <RouterView />
  </main>
</template>

<style>
/* === 全域樣式 (您提供的專業深色主題) === */

/* 1. 全域變數與基本設定 */
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
  min-height: 100vh; /* 確保佔滿全螢幕高度 */
  display: flex;
  flex-direction: column;
}

/* --- (NEW) 導航列樣式 --- */
.navbar {
  background-color: var(--color-card);
  border-bottom: 1px solid var(--color-border);
  padding: 0 1.5rem; /* 左右留一點空間 */
  position: sticky; /* 讓導航列固定在頂部 */
  top: 0;
  z-index: 100; /* 確保在最上層 */
}

nav {
  display: flex;
  gap: 2rem; /* 按鈕之間的間距 */
  max-width: 1600px; /* 讓導航內容也對齊主內容寬度 */
  margin: 0 auto; /* 置中 */
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 1.25rem 0; /* 增加點擊區域 */
  color: var(--color-text-secondary);
  text-decoration: none;
  font-weight: 500;
  font-size: 1.05rem;
  border-bottom: 3px solid transparent; /* 預留底線位置 */
  transition: all 0.2s ease;
}

.nav-link:hover {
  color: var(--color-text-primary);
}

/* Vue Router 自動加上的 class，表示當前頁面 */
.nav-link.router-link-active {
  color: var(--color-accent);
  border-bottom-color: var(--color-accent);
}

/* 2. 主內容區 (RWD) */
main {
  flex: 1; /* 讓 main 填滿剩餘空間 */
  width: 100%;
  max-width: 1600px; /* 限制最大寬度，避免在大螢幕太寬 */
  margin: 0 auto;    /* 置中 */
  padding: 2rem 1.5rem; /* 增加上下呼吸空間 */
  box-sizing: border-box;
}

/* === 以下為共用元件樣式 (Modal, Card, Form...) === */
/* 這些樣式必須保留在 App.vue，因為它們被多個 View 共用 */

/* 容器 */
.subscription-card,
.modal-content,
.summary-card { /* (NEW) 新增摘要卡片 */
  background: var(--color-card) !important;
  border: 1px solid var(--color-border) !important;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

/* 文字 */
h1, h2, h3, h4, label {
  color: var(--color-text-primary) !important;
  font-weight: 600;
}
.subscription-info ul,
.subscription-info li {
  color: var(--color-text-secondary) !important;
}

/* 表單 */
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

/* 按鈕 */
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

/* 表格 */
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
.status-cell.is-editable:hover {
   background-color: #404040 !important;
}

/* 其他通用 */
hr { margin: 2rem 0; border: 0; border-top: 1px solid var(--color-border); }
.error { color: var(--color-danger-text); }

/* Modal 全域樣式 */
.modal-overlay {
  background: rgba(0, 0, 0, 0.75);
  backdrop-filter: blur(5px);
  position: fixed; top: 0; left: 0; width: 100%; height: 100%;
  display: flex; justify-content: center; align-items: center; z-index: 1000;
}
.modal-content {
  padding: 2rem; min-width: 450px; max-width: 90%;
}
.modal-content div { margin-bottom: 1rem; }
.modal-actions {
  display: flex; justify-content: flex-end; gap: 1rem;
  margin-top: 2rem; margin-bottom: 0;
}
.modal-actions button[type="button"] {
  background-color: transparent;
  border: 1px solid var(--color-border);
  color: var(--color-text-primary);
}
.modal-actions button[type="button"]:hover {
  background-color: var(--color-border);
}
.member-list { list-style: none; padding: 0; }
.member-list li {
  display: flex; justify-content: space-between; align-items: center;
  padding: 0.75rem 0.5rem; border-bottom: 1px solid var(--color-border);
}
.remove-btn, .remove-btn:hover {
  background: var(--color-danger-bg);
  color: var(--color-danger-text);
  border: 1px solid var(--color-danger-border);
  padding: 6px 10px;
  font-size: 0.85rem;
}
.add-form { display: flex; gap: 10px; align-items: center; }
.add-form select, .add-form input { flex: 1; }

/* RWD */
@media (min-width: 768px) {
  main { padding: 2.5rem; }
  .modal-content form {
    display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;
  }
}
</style>