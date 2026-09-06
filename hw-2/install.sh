#!/bin/bash

set -e #Для прерывания при ненулевом коде операций без проверок

REPO_URL="https://github.com/Sfairath/shvirtd-example-python/archive/refs/heads/main.zip"
TARGET_DIR="/opt/shvirtd-example-python"
ZIP_FILE="/tmp/shvirtd-example-python.zip"

# Проверка наличия необходимых утилит
if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    echo "Установите curl или wget для скачивания архива."
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "Установите unzip: sudo apt install unzip (Ubuntu/Debian) или sudo yum install unzip (CentOS/RHEL)."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "docker не установлен. Установите docker и попробуйте снова."
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "docker compose не установлен. Установите docker compose и попробуйте снова."
    exit 1
fi

# Удаляем старую директорию, если она существует
if [ -d "$TARGET_DIR" ]; then
    echo "Директория $TARGET_DIR уже существует. Удаляем..."
    sudo rm -rf "$TARGET_DIR"
fi

# Скачиваем архив
echo "Скачиваем архив из $REPO_URL..."
if command -v curl &> /dev/null; then
    sudo curl -L -o "$ZIP_FILE" "$REPO_URL"
else
    sudo wget -O "$ZIP_FILE" "$REPO_URL"
fi

if [ $? -ne 0 ] || [ ! -s "$ZIP_FILE" ]; then
    echo "Ошибка скачивания архива!"
    exit 1
fi

# Распаковываем архив
echo "Распаковываем архив..."
sudo unzip -q "$ZIP_FILE" -d /opt/
sudo rm -f "$ZIP_FILE"

# Переименовываем директорию (убираем суффикс -main)
sudo mv "/opt/shvirtd-example-python-main" "$TARGET_DIR"

# Переходим в директорию проекта
cd "$TARGET_DIR" || exit

# Запускаем проект через docker compose
echo "Запускаем проект через docker compose..."
docker compose up -d