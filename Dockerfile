FROM node:22-alpine3.20 as build-stage
# 作者信息
LABEL authors="user@email.com"

# 设置工作目录
WORKDIR /app

# 复制所有文件到工作目录
COPY . .

# 安装 pnpm Qcloud腾讯云加速
RUN npm install -g pnpm --registry=http://mirrors.cloud.tencent.com/npm/

# 安装依赖 Qcloud腾讯云加速
RUN pnpm install --registry=http://mirrors.cloud.tencent.com/npm/

# 构建生产环境下到Vue项目
RUN pnpm run docs:build

FROM nginx:alpine3.20-perl

# 复制nginx配置文件
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 复制打包好的dist目录
COPY --from=build-stage /app/docs/.vitepress/dist /usr/share/nginx/html

# 暴露端口
EXPOSE 8080

# 启动Nginx服务
CMD ["nginx", "-g", "daemon off;"]
