# ./frontend/Dockerfile

# --- 階段 1: 建置 (Build) ---
# 使用 lts-alpine (Node 20+) 來滿足 Vite 的要求
FROM node:lts-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# --- 階段 2: 服務 (Serve) ---
FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
# 從 "build" 階段複製建置好的 'dist' 資料夾內容
COPY --from=build /app/dist .
# 複製 Nginx 設定檔
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]