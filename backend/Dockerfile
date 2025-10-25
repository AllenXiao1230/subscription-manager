# ./backend/Dockerfile

# 使用 Node.js 18 的輕量級映像檔
FROM node:18-alpine

# 在容器中建立工作目錄
WORKDIR /app

# 複製 package.json 和 package-lock.json
COPY package*.json ./

# 安裝依賴
RUN npm install

# 複製所有後端程式碼
COPY ./src ./src

# 容器啟動時執行的命令
CMD [ "node", "src/server.js" ]