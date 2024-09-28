#!/bin/bash

# 检查是否以 root 权限运行脚本
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 权限运行此脚本."
  exit 1
fi

# 备份现有的 /etc/ufw/after.rules 文件
AFTER_RULES_FILE="/etc/ufw/after.rules"
BACKUP_FILE="/etc/ufw/after.rules.bak"

if [ -f "$AFTER_RULES_FILE" ]; then
  echo "备份现有的 after.rules 文件为 $BACKUP_FILE"
  cp "$AFTER_RULES_FILE" "$BACKUP_FILE"
else
  echo "没有找到 /etc/ufw/after.rules 文件，创建一个新的文件..."
  touch "$AFTER_RULES_FILE"
fi

# 检查规则是否已经存在，避免重复添加
if ! grep -q "BEGIN UFW AND DOCKER FIX" "$AFTER_RULES_FILE"; then
  echo "添加 UFW 和 Docker 兼容的规则到 /etc/ufw/after.rules"
  cat <<EOT >> "$AFTER_RULES_FILE"

# BEGIN UFW AND DOCKER FIX
*filter
:ufw-before-forward - [0:0]
-A FORWARD -j ufw-before-forward
-A ufw-before-forward -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A ufw-before-forward -m conntrack --ctstate INVALID -j DROP
-A ufw-before-forward -j ufw-user-forward
COMMIT
# END UFW AND DOCKER FIX
EOT
else
  echo "UFW 和 Docker 兼容规则已存在，跳过添加。"
fi

# 确保 /etc/default/ufw 文件中 DEFAULT_FORWARD_POLICY 设置为 ACCEPT
UFW_DEFAULT_FILE="/etc/default/ufw"
if grep -q "^DEFAULT_FORWARD_POLICY=" "$UFW_DEFAULT_FILE"; then
  echo "修改 /etc/default/ufw 中的 DEFAULT_FORWARD_POLICY 为 ACCEPT"
  sed -i 's/^DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' "$UFW_DEFAULT_FILE"
else
  echo "添加 DEFAULT_FORWARD_POLICY=\"ACCEPT\" 到 /etc/default/ufw"
  echo 'DEFAULT_FORWARD_POLICY="ACCEPT"' >> "$UFW_DEFAULT_FILE"
fi

# 重启 UFW 防火墙
echo "重启 UFW 防火墙以应用更改..."
sudo ufw reload

echo "UFW 和 Docker 配置已调整完成。"
