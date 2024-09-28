#!/bin/bash

# 检查是否以 root 权限运行脚本
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本."
  exit 1
fi

# 定义文件路径
AFTER_RULES_FILE="/etc/ufw/after.rules"
BACKUP_FILE="/etc/ufw/after.rules.bak"
UFW_DEFAULT_FILE="/etc/default/ufw"
TEMP_POLICY_BACKUP="/tmp/ufw_default_policy_backup"

# 恢复 /etc/ufw/after.rules
if [ -f "$BACKUP_FILE" ]; then
  # 检查当前的 /etc/ufw/after.rules 是否已经被恢复过
  if ! grep -q "BEGIN UFW AND DOCKER FIX" "$AFTER_RULES_FILE"; then
    echo "恢复 $AFTER_RULES_FILE 文件自备份 $BACKUP_FILE"
    cp "$BACKUP_FILE" "$AFTER_RULES_FILE"
    echo "恢复完成。"
  else
    echo "$AFTER_RULES_FILE 文件已经恢复，无需重复操作。"
  fi
else
  echo "未找到 $BACKUP_FILE，跳过恢复 after.rules。"
fi

# 检查并恢复 /etc/default/ufw 中的 DEFAULT_FORWARD_POLICY
if [ -f "$TEMP_POLICY_BACKUP" ]; then
  echo "恢复 /etc/default/ufw 中的 DEFAULT_FORWARD_POLICY."
  # 移除当前的 DEFAULT_FORWARD_POLICY
  sed -i '/^DEFAULT_FORWARD_POLICY=/d' "$UFW_DEFAULT_FILE"
  # 恢复备份的 DEFAULT_FORWARD_POLICY
  cat "$TEMP_POLICY_BACKUP" >> "$UFW_DEFAULT_FILE"
  echo "恢复的 DEFAULT_FORWARD_POLICY 已应用."
else
  echo "未找到 $TEMP_POLICY_BACKUP，移除 /etc/default/ufw 中的 DEFAULT_FORWARD_POLICY."
  # 如果没有备份文件，直接移除 DEFAULT_FORWARD_POLICY
  sed -i '/^DEFAULT_FORWARD_POLICY=/d' "$UFW_DEFAULT_FILE"
fi

# 重启 ufw 防火墙
echo "重启 UFW 防火墙以应用更改..."
sudo ufw reload

echo "UFW 配置恢复完成。"
