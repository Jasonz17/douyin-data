# Dockerfile
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# 安装系统依赖和Chromium
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    chromium \
    chromium-driver \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libxss1 \
    libnss3 \
    # 清理apt缓存以减小镜像大小
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 复制requirements文件
COPY requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用文件
COPY . .

# 暴露端口
EXPOSE 8000

# 创建非root用户（可选，增加安全性）
RUN useradd -m -u 1000 appuser

# 在切换用户之前，创建并设置持久化数据目录的所有权和权限
# 这个目录与 app.py 中 user_data_dir = '/app/drission_user_data' 对应
RUN mkdir -p /app/drission_user_data \
    && chown -R appuser:appuser /app/drission_user_data \
    && chmod 755 /app/drission_user_data # 赋予 appuser 读写执行权限，其他用户只读执行

USER appuser

# 启动命令
CMD ["python", "app.py"]