#!/bin/bash

# Запуск первой команды
fasm os.asm os.bin
# Проверка статуса выполнения предыдущей команды
if [ $? -ne 0 ]; then
    echo "Ошибка при выполнении fasm os.asm s"
    exit 1
fi

# Запуск второй команды
python3 os_image_loader.py os.bin os.asm program1.bin program2.bin pr1 pr2 pr3 pr4
# Проверка статуса выполнения предыдущей команды
if [ $? -ne 0 ]; then
    echo "Ошибка при выполнении python3 os_image_loader.py s os.asm"
    exit 1
fi

# Запуск третьей команды
qemu-system-x86_64 -fda image
# Проверка статуса выполнения предыдущей команды
if [ $? -ne 0 ]; then
    echo "Ошибка при выполнении qemu-system-x86_64 -fda image"
    exit 1
fi
