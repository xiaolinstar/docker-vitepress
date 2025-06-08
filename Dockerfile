FROM node:22-alpine3.20 AS build-stage
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

# 安装Git，lastUpdated=true需要
# 更新 apk 索引并安装软件包
# 指定腾讯云的 Alpine 镜像源
RUN echo "https://mirrors.cloud.tencent.com/alpine/v3.14/main" > /etc/apk/repositories \
    && echo "https://mirrors.cloud.tencent.com/alpine/v3.14/community" >> /etc/apk/repositories \
    && apk update \
    && apk upgrade \
    && apk add --no-cache bash git openssh

# 构建生产环境下到Vue项目
RUN pnpm run docs:build

FROM nginx:alpine3.20-perl

# 复制nginx配置文件
COPY volumes/website/nginx.conf /etc/nginx/nginx.conf
COPY volumes/website/default.conf /etc/nginx/conf.d/default.conf
COPY volumes/website/nginx-stub-status.conf /etc/nginx/conf.d/nginx-stub-status.conf

# 复制打包好的dist目录
COPY --from=build-stage /app/docs/.vitepress/dist /usr/share/nginx/html

# 启动Nginx服务
CMD ["nginx", "-g", "daemon off;"]
