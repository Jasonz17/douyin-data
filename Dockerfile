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

# 创建非root用户
RUN useradd -m -u 1000 appuser

# --- 关键修改：在这里创建并设置 drission_user_data 目录的权限 ---
# 确保目录被创建，并将其所有权赋给 appuser
# 这个目录只存在于容器内部文件系统
RUN mkdir -p /app/drission_user_data \
    && chown -R appuser:appuser /app/drission_user_data \
    && chmod -R 777 /app/drission_user_data # 给予 appuser 完全的读写执行权限

USER appuser

# 启动命令
CMD ["python", "app.py"]
