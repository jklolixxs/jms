#!/bin/bash

# 检查当前用户是否为 root 用户
if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 用户身份运行此脚本"
  exit
fi

while true; do
clear
echo =================================================
echo 系统支持: 支持Ubuntu / Debian / Centos系统
echo 作者: jms
echo 反馈:  https://github.com/jklolixxs/jms/issues
echo =================================================
echo "1. 系统信息查询"
echo "2. 系统相关功能 ▶"
echo "3. 常用工具安装 ▶"
echo "------------------------"
echo "5. Docker管理 ▶"
echo "6. aaPanel管理 ▶"
echo "7. Sing-Box管理 ▶"
echo "------------------------"
echo "30. 一些常用脚本 ▶"
echo "------------------------"
echo "99. 脚本相关功能 ▶"
echo "------------------------"
echo "0. 退出脚本"
echo "------------------------"
read -p "请输入你的选择: " choice
case $choice in
  1)
    clear
    # 函数: 获取IPv4和IPv6地址
    fetch_ip_addresses() {
      ipv4_address=$(curl -s ipv4.ip.sb)
      ipv6_address=$(curl -s ipv6.ip.sb)
    }

    # 获取IP地址
    fetch_ip_addresses

    if [ "$(uname -m)" == "x86_64" ]; then
      cpu_info=$(cat /proc/cpuinfo | grep 'model name' | uniq | sed -e 's/model name[[:space:]]*: //')
    else
      cpu_info=$(lscpu | grep 'Model name' | sed -e 's/Model name[[:space:]]*: //')
    fi

    cpu_usage=$(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')
    cpu_usage_percent=$(printf "%.2f" "$cpu_usage")%

    cpu_cores=$(nproc)

    mem_info=$(free -b | awk 'NR==2{printf "%.2f/%.2f MB (%.2f%%)", $3/1024/1024, $2/1024/1024, $3*100/$2}')

    disk_info=$(df -h | awk '$NF=="/"{printf "%d/%dGB (%s)", $3,$2,$5}')

    ipv4_info=$(curl -s "http://ipinfo.io/$ipv4_address/json")
    country=$(echo "$ipv4_info" | grep -o '"country": "[^"]*' | cut -d'"' -f4)
    city=$(echo "$ipv4_info" | grep -o '"city": "[^"]*' | cut -d'"' -f4)

    isp_info=$(curl -s ipinfo.io/org | sed -e 's/^[ \t]*//' | sed -e 's/\"//g')

    cpu_arch=$(uname -m)

    hostname=$(hostname)

    kernel_version=$(uname -r)

    congestion_algorithm=$(sysctl -n net.ipv4.tcp_congestion_control)
    queue_algorithm=$(sysctl -n net.core.default_qdisc)

    # 尝试使用 lsb_release 获取系统信息
    os_info=$(lsb_release -ds 2>/dev/null)

    # 如果 lsb_release 命令失败，则尝试其他方法
    if [ -z "$os_info" ]; then
      # 检查常见的发行文件
      if [ -f "/etc/os-release" ]; then
        os_info=$(source /etc/os-release && echo "$PRETTY_NAME")
      elif [ -f "/etc/debian_version" ]; then
        os_info="Debian $(cat /etc/debian_version)"
      elif [ -f "/etc/redhat-release" ]; then
        os_info=$(cat /etc/redhat-release)
      else
        os_info="Unknown"
      fi
    fi

    clear
    output=$(awk 'BEGIN { rx_total = 0; tx_total = 0 }
      NR > 2 { rx_total += $2; tx_total += $10 }
      END {
        rx_units = "Bytes";
        tx_units = "Bytes";
        if (rx_total > 1024) { rx_total /= 1024; rx_units = "KB"; }
        if (rx_total > 1024) { rx_total /= 1024; rx_units = "MB"; }
        if (rx_total > 1024) { rx_total /= 1024; rx_units = "GB"; }

        if (tx_total > 1024) { tx_total /= 1024; tx_units = "KB"; }
        if (tx_total > 1024) { tx_total /= 1024; tx_units = "MB"; }
        if (tx_total > 1024) { tx_total /= 1024; tx_units = "GB"; }

        printf("总接收: %.2f %s\n总发送: %.2f %s\n", rx_total, rx_units, tx_total, tx_units);
      }' /proc/net/dev)

    current_time=$(date "+%Y-%m-%d %I:%M %p")

    swap_used=$(free -m | awk 'NR==3{print $3}')
    swap_total=$(free -m | awk 'NR==3{print $2}')

    if [ "$swap_total" -eq 0 ]; then
      swap_percentage=0
    else
      swap_percentage=$((swap_used * 100 / swap_total))
    fi

    swap_info="${swap_used}MB/${swap_total}MB (${swap_percentage}%)"

    echo ""
    echo "系统信息查询"
    echo "------------------------"
    echo "主机名: $hostname"
    echo "运营商: $isp_info"
    echo "------------------------"
    echo "系统版本: $os_info"
    echo "Linux版本: $kernel_version"
    echo "------------------------"
    echo "CPU架构: $cpu_arch"
    echo "CPU型号: $cpu_info"
    echo "CPU核心数: $cpu_cores"
    echo "------------------------"
    echo "CPU占用: $cpu_usage_percent"
    echo "物理内存: $mem_info"
    echo "虚拟内存: $swap_info"
    echo "硬盘占用: $disk_info"
    echo "------------------------"
    echo "$output"
    echo "------------------------"
    echo "网络拥堵算法: $congestion_algorithm $queue_algorithm"
    echo "------------------------"
    echo "公网IPv4地址: $ipv4_address"
    echo "公网IPv6地址: $ipv6_address"
    echo "------------------------"
    echo "地理位置: $country $city"
    echo "系统时间: $current_time"
    echo
    ;;

  2)
    while true; do
    clear
    echo " ▼ "
    echo "系统相关功能"
    echo "------------------------"
    echo "1. 修改root用户密码"
    echo "2. 修改SSH端口"
    echo "3. 修改当前用户密码"
    echo "4. 更改为root用户+密码登录模式"
    echo "5. 禁用root用户并创建新拥有sudo权限用户"
    echo "6. 增删改用户 ▶"
    echo "------------------------"
    echo "20. 系统更新"
    echo "21. 系统清理"
    echo "------------------------"
    echo "0. 返回上一级"
    echo "------------------------"
    read -p "请输入你的选择: " sub_choice
    case $sub_choice in
      1)
        clear
        echo "密码隐性输入，不可见，但实际已经输入了"
        echo "输入密码："
        passwd root
        service ssh restart
        service sshd restart
        ;;
      2)
        clear
        # 提示用户输入内容
        echo "输入例子 1024 或 12345"
        read -p "请输入SSH的端口： " user_input
	  
        # 构建完整的命令
        command="bash <(curl -fsSL git.io/key.sh) -o -p $user_input"
	  
        # 打印最终的命令
        echo "将要更改的SSH登录端口是："
        echo "$user_input"
	  
        # 确认是否执行命令
        read -p "是否要执行更换SSH登录端口？(y/n) " execute
        if [ "$execute" == "y" ]; then
          # 执行命令
          clear
          eval "$command"
          # 检查命令是否执行成功
          if [ $? -eq 0 ]; then
            echo "------------------------"
            service ssh restart
            echo "更换完成，当前SSH登录端口是："
            echo "$user_input"
            echo "密码更改完成！"
            echo "如您开启了ufw等防火墙软件，请及时放行对应的端口，防止失联！"
            echo "------------------------"
          else
            echo "------------------------"
            echo "更换未完成，当前SSH登录端口未更换"
            echo "------------------------"
          fi
        else
          echo "已取消执行命令。"
        fi
        ;;
      3)
        clear
        echo "密码隐性输入，不可见，但实际已经输入了"
        echo "输入密码："
        passwd
        service ssh restart
        service sshd restart
        ;;
      4)
        clear
        echo "设置你的root密码"
        passwd root
        sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
        sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
        service ssh restart
        service sshd restart
        echo "root用户登录开启成功"
        echo "密码更改完成！"
        echo "如您开启了ufw等防火墙软件，请及时放行对应的端口，防止失联！"
        read -p "需要重启服务器吗？(Y/N): " choice
        case "$choice" in
          [Yy])
            reboot
            ;;
          [Nn])
            echo "已取消"
            ;;
          *)
            echo "无效的选择，请输入 Y 或 N。"
            ;;
        esac
        ;;
      5)
        clear
        if ! command -v sudo &>/dev/null; then
          if command -v apt &>/dev/null; then
            apt update -y && apt install -y sudo
          elif command -v yum &>/dev/null; then
            yum -y update && yum -y install sudo
          else
            exit 1
          fi
        fi
	  
        # 提示用户输入新用户名
        read -p "请输入新用户名: " new_username
	  
        # 创建新用户并设置密码
        sudo useradd -m -s /bin/bash "$new_username"
        sudo passwd "$new_username"
	  
        # 赋予新用户sudo权限
        echo "$new_username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
	  
        # 禁用ROOT用户登录
        sudo passwd -l root
	  
        echo "操作已完成。"
        ;;
      6)
        while true; do
        clear
        # 显示所有用户、用户权限、用户组和是否在sudoers中
        echo "用户列表"
        echo "----------------------------------------------------------------------------"
        printf "%-24s %-34s %-20s %-10s\n" "用户名" "用户权限" "用户组" "sudo权限"
        while IFS=: read -r username _ userid groupid _ _ homedir shell; do
          groups=$(groups "$username" | cut -d : -f 2)
          sudo_status=$(sudo -n -lU "$username" 2>/dev/null | grep -q '(ALL : ALL)' && echo "Yes" || echo "No")
          printf "%-20s %-30s %-20s %-10s\n" "$username" "$homedir" "$groups" "$sudo_status"
        done < /etc/passwd
        echo ""
        echo "账户操作"
        echo "------------------------"
        echo "1. 创建普通账户             2. 创建高级账户"
        echo "------------------------"
        echo "3. 赋予最高权限             4. 取消最高权限"
        echo "------------------------"
        echo "5. 删除账号"
        echo "------------------------"
        echo "0. 返回上一级"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice
        case $sub_choice in
          1)
            if ! command -v sudo &>/dev/null; then
              if command -v apt &>/dev/null; then
                apt update -y && apt install -y sudo
              elif command -v yum &>/dev/null; then
                yum -y update && yum -y install sudo
              else
                echo ""
              fi
            fi
              # 提示用户输入新用户名
              read -p "请输入新用户名: " new_username
              # 创建新用户并设置密码
              sudo useradd -m -s /bin/bash "$new_username"
              sudo passwd "$new_username"
              echo "操作已完成。"
              ;;
          2)
            if ! command -v sudo &>/dev/null; then
              if command -v apt &>/dev/null; then
                apt update -y && apt install -y sudo
              elif command -v yum &>/dev/null; then
                yum -y update && yum -y install sudo
              else
                echo ""
              fi
            fi
            # 提示用户输入新用户名
            read -p "请输入新用户名: " new_username
            # 创建新用户并设置密码
            sudo useradd -m -s /bin/bash "$new_username"
            sudo passwd "$new_username"
            # 赋予新用户sudo权限
            echo "$new_username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
            echo "操作已完成。"
            ;;
          3)
            if ! command -v sudo &>/dev/null; then
              if command -v apt &>/dev/null; then
                apt update -y && apt install -y sudo
              elif command -v yum &>/dev/null; then
                yum -y update && yum -y install sudo
              else
                 echo ""
              fi
            fi
            read -p "请输入用户名: " username
            # 赋予新用户sudo权限
            echo "$username ALL=(ALL:ALL) ALL" | sudo tee -a /etc/sudoers
            ;;
          4)
            if ! command -v sudo &>/dev/null; then
              if command -v apt &>/dev/null; then
                apt update -y && apt install -y sudo
              elif command -v yum &>/dev/null; then
                yum -y update && yum -y install sudo
              else
                echo ""
              fi
            fi
            read -p "请输入用户名: " username
            # 从sudoers文件中移除用户的sudo权限
            sudo sed -i "/^$username\sALL=(ALL:ALL)\sALL/d" /etc/sudoers
            ;;
          5)
            if ! command -v sudo &>/dev/null; then
              if command -v apt &>/dev/null; then
                apt update -y && apt install -y sudo
              elif command -v yum &>/dev/null; then
                yum -y update && yum -y install sudo
              else
                echo ""
              fi
            fi
            read -p "请输入要删除的用户名: " username
            # 删除用户及其主目录
            sudo userdel -r "$username"
            ;;
          0)
            break  # 跳出循环，退出菜单
            ;;
          *)
            echo "无效的输入!"
            ;;
        esac
          echo -e "\033[0;32m操作完成\033[0m"
          echo "按任意键继续..."
          read -n 1 -s -r -p ""
          echo ""
          clear
        done
        ;;
      20)
        clear
        # Update system on Debian-based systems
        if [ -f "/etc/debian_version" ]; then
          DEBIAN_FRONTEND=noninteractive apt update -y && DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
        fi
      
        # Update system on Red Hat-based systems
        if [ -f "/etc/redhat-release" ]; then
          yum -y update
        fi
        ;;
      21)
        clear
        if [ -f "/etc/debian_version" ]; then
          # Debian-based systems
          apt autoremove --purge -y
          apt clean -y
          apt autoclean -y
          apt remove --purge $(dpkg -l | awk '/^rc/ {print $2}') -y
          journalctl --rotate
          journalctl --vacuum-time=1s
          journalctl --vacuum-size=50M
          apt remove --purge $(dpkg -l | awk '/^ii linux-(image|headers)-[^ ]+/{print $2}' | grep -v $(uname -r | sed 's/-.*//') | xargs) -y
        elif [ -f "/etc/redhat-release" ]; then
          # Red Hat-based systems
          yum autoremove -y
          yum clean all
          journalctl --rotate
          journalctl --vacuum-time=1s
          journalctl --vacuum-size=50M
          yum remove $(rpm -q kernel | grep -v $(uname -r)) -y
        fi
        ;;
      0)
        break  # 跳出循环，退出菜单
        ;;
      *)
        echo "无效的输入!"
        ;;
    esac
      echo -e "\033[0;32m操作完成\033[0m"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
    done
    ;;
  3)
    while true; do
    clear
    echo "安装常用工具"
    echo "------------------------"
    echo "1. curl 下载工具"
    echo "2. wget 下载工具"
    echo "3. git 分布式版本控制系统"
    echo "4. sudo 超级管理权限工具"
    echo "5. ufw 防火墙管理工具 (仅建议Debian/Ubuntu安装)"
    echo "6. screen 多终端窗口后台运行工具"
    echo "7. socat 通信连接工具 (申请域名证书必备)"
    echo "8. dnsutils DNS相关工具 (仅限Debian/Ubuntu安装)"
    echo "9. bind-utils DNS相关工具 (仅限Centos安装)"
    echo "10. cpulimit 限制CPU使用率"
    echo "11. htop 系统监控工具"
    echo "12. chrony NTP时间同步工具"
    echo "13. iftop 网络流量监控工具"
    echo "14. unzip ZIP压缩解压工具z"
    echo "15. tar GZ压缩解压工具"
    echo "16. screenfetch 通过有趣的图形和标志展现有关您的系统和发行版的信息"
    echo "17. jq 用于处理JSON数据 (如果后面使用一键脚本，可能需要用到此工具)"
    echo "------------------------"
    echo "31. 全部安装"
    echo "32. 全部卸载"
    echo "------------------------"
    echo "0. 返回上一级"
    echo "------------------------"
    read -p "请输入你的选择: " sub_choice
    case $sub_choice in
      1)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y curl
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install curl
        else
          echo "未知的包管理器!"
        fi
        ;;
      2)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y wget
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install wget
        else
          echo "未知的包管理器!"
        fi
        ;;
      3)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y git
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install git
        else
         echo "未知的包管理器!"
        fi
        ;;
      4)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y sudo
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install sudo
        else
          echo "未知的包管理器!"
        fi
        ;;
      5)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y ufw
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install ufw
        else
          echo "未知的包管理器!"
        fi
        ;;
      6)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y screen
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install screen
        else
          echo "未知的包管理器!"
        fi
        ;;
      7)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y socat
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install socat
        else
          echo "未知的包管理器!"
        fi
        ;;
      8)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y dnsutils
        else
          echo "未知的包管理器!"
        fi
        ;;
      9)
        clear
        if command -v yum &>/dev/null; then
          yum -y update && yum -y install bind-utils
        else
          echo "未知的包管理器!"
        fi
        ;;
      10)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y cpulimit
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install cpulimit
        else
          echo "未知的包管理器!"
        fi
        ;;
      11)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y htop
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install htop
        else
          echo "未知的包管理器!"
        fi
        ;;
      12)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y chrony
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install chrony
        else
          echo "未知的包管理器!"
        fi
        ;;
      13)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y iftop
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install iftop
        else
          echo "未知的包管理器!"
        fi
        ;;
      14)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y unzip
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install unzip
        else
          echo "未知的包管理器!"
        fi
        ;;
      15)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y tar
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install tar
        else
          echo "未知的包管理器!"
        fi
        ;;
      16)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y screenfetch
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install screenfetch
        else
          echo "未知的包管理器!"
        fi
        ;;
      17)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y jq
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install jq
        else
          echo "未知的包管理器!"
        fi
        ;;
      31)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt install -y curl wget git sudo ufw screen socat dnsutils cpulimit htop chrony iftop unzip tar screenfetch jq
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y install curl wget git sudo ufw screen socat bind-utils cpulimit htop chrony iftop unzip tar screenfetch jq
        else
          echo "未知的包管理器!"
        fi
        ;;
      32)
        clear
        if command -v apt &>/dev/null; then
          apt update -y && apt remove -y curl wget git sudo ufw screen socat dnsutils cpulimit htop chrony iftop unzip tar screenfetch jq
        elif command -v yum &>/dev/null; then
          yum -y update && yum -y remove curl wget git sudo ufw screen socat bind-utils cpulimit htop chrony iftop unzip tar screenfetch jq
        else
          echo "未知的包管理器!"
        fi
        ;;
      0)
        break  # 跳出循环，退出菜单
        ;;
      *)
        echo "无效的输入!"
        ;;
    esac
      echo -e "\033[0;32m操作完成\033[0m"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
    done
    ;;
  5)
    while true; do
    clear
    echo "Docker管理器"
    echo "------------------------"
    echo "1. 安装更新Docker环境"
    echo "------------------------"
    echo "2. 查看Docker全局状态"
    echo "------------------------"
    echo "3. Docker容器管理 ▶"
    echo "4. Docker镜像管理 ▶"
    echo "5. Docker网络管理 ▶"
    echo "6. Docker卷管理 ▶"
    echo "------------------------"
    echo "7. 清理无用的docker容器和镜像网络数据卷"
    echo "------------------------"
    echo "8. 卸载Docker环境"
    echo "------------------------"
    echo "0. 返回上一级"
    echo "------------------------"
    read -p "请输入你的选择: " sub_choice
    case $sub_choice in
      1)
        clear
        curl -fsSL https://get.docker.com | sh
        systemctl start docker
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
        ;;
      2)
        clear
        echo "Docker版本"
        docker --version
        docker-compose --version
        echo ""
        echo "Docker镜像列表"
        docker image ls
        echo ""
        echo "Docker容器列表"
        docker ps -a
        echo ""
        echo "Docker卷列表"
        docker volume ls
        echo ""
        echo "Docker网络列表"
        docker network ls
        echo ""
        ;;
      3)
        while true; do
        clear
        echo "Docker容器列表"
        docker ps -a
        echo ""
        echo "容器操作"
        echo "------------------------"
        echo "1. 创建新的容器"
        echo "------------------------"
        echo "2. 启动指定容器             6. 启动所有容器"
        echo "3. 停止指定容器             7. 暂停所有容器"
        echo "4. 删除指定容器             8. 删除所有容器"
        echo "5. 重启指定容器             9. 重启所有容器"
        echo "------------------------"
        echo "11. 进入指定容器           12. 查看容器日志"
        echo "------------------------"
        echo "0. 返回上一级"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice
        case $sub_choice in
          1)
            read -p "请输入创建命令：" dockername
            $dockername
            ;;
          2)
            read -p "请输入容器名：" dockername
            docker start $dockername
            ;;
          3)
            read -p "请输入容器名：" dockername
            docker stop $dockername
            ;;
          4)
            read -p "请输入容器名：" dockername
            docker rm -f $dockername
            ;;
          5)
            read -p "请输入容器名：" dockername
            docker restart $dockername
            ;;
          6)
            docker start $(docker ps -a -q)
            ;;
          7)
            docker stop $(docker ps -q)
            ;;
          8)
            read -p "确定删除所有容器吗？(Y/N): " choice
            case "$choice" in
              [Yy])
                docker rm -f $(docker ps -a -q)
                ;;
              [Nn])
                ;;
              *)
                echo "无效的选择，请输入 Y 或 N。"
                ;;
            esac
            ;;
          9)
            docker restart $(docker ps -q)
            ;;
          11)
            read -p "请输入容器名：" dockername
            docker exec -it $dockername /bin/bash
            ;;
          12)
            read -p "请输入容器名：" dockername
            docker logs $dockername
            echo -e "\033[0;32m操作完成\033[0m"
            echo "按任意键继续..."
            read -n 1 -s -r -p ""
            echo ""
            clear
            ;;
          0)
            break  # 跳出循环，退出菜单
            ;;
          *)
            echo "无效的输入!"
            ;;
        esac
          echo -e "\033[0;32m操作完成\033[0m"
          echo "按任意键继续..."
          read -n 1 -s -r -p ""
          echo ""
          clear
        done
        ;;
      4)
        while true; do
        clear
        echo "Docker镜像列表"
        docker image ls
        echo ""
        echo "镜像操作"
        echo "------------------------"
        echo "1. 获取指定镜像             3. 删除指定镜像"
        echo "2. 更新指定镜像             4. 删除所有镜像"
        echo "------------------------"
        echo "0. 返回上一级"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice
        case $sub_choice in
          1)
            read -p "请输入镜像名：" dockername
            docker pull $dockername
            ;;
          2)
            read -p "请输入镜像名：" dockername
            docker pull $dockername
            ;;
          3)
            read -p "请输入镜像名：" dockername
            docker rmi -f $dockername
            ;;
          4)
            read -p "确定删除所有镜像吗？(Y/N): " choice
            case "$choice" in
              [Yy])
                docker rmi -f $(docker images -q)
                ;;
              [Nn])
                ;;
              *)
                echo "无效的选择，请输入 Y 或 N。"
                ;;
            esac
            ;;
          0)
            break  # 跳出循环，退出菜单
            ;;
          *)
            echo "无效的输入!"
            ;;
        esac
          echo -e "\033[0;32m操作完成\033[0m"
          echo "按任意键继续..."
          read -n 1 -s -r -p ""
          echo ""
          clear
        done
        ;;
      5)
        while true; do
        clear
        echo "Docker网络列表"
        docker network ls
        echo ""
        echo "网络操作"
        echo "------------------------"
        echo "1. 创建网络"
        echo "2. 加入网络"
        echo "3. 删除网络"
        echo "------------------------"
        echo "0. 返回上一级"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice
        case $sub_choice in
          1)
            read -p "设置新网络名：" dockernetwork
            docker network create $dockernetwork
            ;;
          2)
            read -p "加入网络名：" dockernetwork
            read -p "那些容器加入该网络：" dockername
            docker network connect $dockernetwork $dockername
            ;;
          3)
            read -p "请输入要删除的网络名：" dockernetwork
            docker network rm $dockernetwork
            ;;
          0)
            break  # 跳出循环，退出菜单
            ;;
          *)
            echo "无效的输入!"
            ;;
        esac
          echo -e "\033[0;32m操作完成\033[0m"
          echo "按任意键继续..."
          read -n 1 -s -r -p ""
          echo ""
          clear
        done
        ;;
      6)
        while true; do
        clear
        echo "Docker卷列表"
        docker volume ls
        echo ""
        echo "卷操作"
        echo "------------------------"
        echo "1. 创建新卷"
        echo "2. 删除卷"
        echo "------------------------"
        echo "0. 返回上一级"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice
        case $sub_choice in
          1)
            read -p "设置新卷名：" dockerjuan
            docker volume create $dockerjuan
            ;;
          2)
            read -p "输入删除卷名：" dockerjuan
            docker volume rm $dockerjuan
            ;;
          0)
            break  # 跳出循环，退出菜单
            ;;
          *)
            echo "无效的输入!"
            ;;
        esac
          echo -e "\033[0;32m操作完成\033[0m"
          echo "按任意键继续..."
          read -n 1 -s -r -p ""
          echo ""
          clear
        done
        ;;
      7)
        clear
        read -p "确定清理无用的镜像容器网络吗？(Y/N): " choice
        case "$choice" in
          [Yy])
            docker system prune -af --volumes
            ;;
          [Nn])
            ;;
          *)
            echo "无效的选择，请输入 Y 或 N。"
            ;;
        esac
        ;;
      8)
        clear
        read -p "确定卸载docker环境吗？(Y/N): " choice
        case "$choice" in
          [Yy])
            docker rm $(docker ps -a -q) && docker rmi $(docker images -q) && docker network prune
            apt-get remove docker -y
            apt-get remove docker-ce -y
            apt-get purge docker-ce -y
            rm -rf /var/lib/docker
            ;;
          [Nn])
            ;;
          *)
            echo "无效的选择，请输入 Y 或 N。"
            ;;
        esac
        ;;
      0)
        break  # 跳出循环，退出菜单
        ;;
      *)
        echo "无效的输入!"
        ;;
    esac
      echo -e "\033[0;32m操作完成\033[0m"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
    done
    ;;
  6)
    while true; do
    clear
    echo "aaPanel管理"
    echo "------------------------"
    echo "1. 安装aaPanel"
    echo "2. BT官方修改脚本"
    echo "3. 查看官方修改脚本翻译"
    echo "------------------------"
    echo "4. 启动aaPanel"
    echo "5. 停止aaPanel"
    echo "6. 重新启动aaPanel"
    echo "------------------------"
    echo "7. 查看控制面板错误日志"
    echo "8. 查看数据库错误日志"
    echo "------------------------"
    echo "99. 卸载aaPanel"
    echo "------------------------"
    echo "0. 返回上一级"
    echo "------------------------"
    read -p "请输入你的选择: " sub_choice
    case $sub_choice in
      1)
        clear
        # Check if the system is Debian
        if [ -f /etc/debian_version ]; then
            wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh aapanel

        # Check if the system is Ubuntu or Deepin
        elif [ -f /etc/lsb-release ] && grep -qi "ubuntu\|deepin" /etc/lsb-release; then
            wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh && bash install.sh aapanel

        # Check if the system is CentOS
        elif [ -f /etc/centos-release ]; then
            yum install -y wget && wget -O install.sh http://www.aapanel.com/script/install_6.0_en.sh && bash install.sh aapanel

        # If the system is not recognized, display an error message
        else
            echo "不支持的系统"
        fi
        ;;
      2)
        clear
        bt
        ;;
      3)
        clear
        echo "===============aaPanel CLI（命令行界面）==============="
        echo "(1) 重启面板                          (8) 更改面板端口"
        echo "(2) 停止面板                          (9) 清除面板缓存"
        echo "(3) 启动面板                          (10) 清除登录限制"
        echo "(4) 重新加载面板                      (11) 取消入口限制"
        echo "(5) 更改面板密码                      (12) 取消域名绑定限制"
        echo "(6) 更改面板用户名                    (13) 取消IP访问限制"
        echo "(7) 强制更改MySQL根密码               (14) 查看面板默认信息"
        echo "(22) 显示面板错误日志                 (15) 清除系统垃圾"
        echo "(23) 关闭BasicAuth身份验证            (16) 修复面板（检查错误并更新面板文件到最新版本）"
        echo "(24) 关闭Google Authenticator         (17) 设置日志切割开关/压缩"
        echo "(25) 设置是否保存文件的历史副本        (18) 设置是否自动备份面板"
        echo "(26) 在备份到云存储时保留/移除本地备份 (0) 取消"
        ;;
      4)
        clear
        service bt stop
        echo "已执行启动命令"
        ;;
      5)
        clear
        service bt start
        echo "已执行停止命令"
        ;;
      6)
        clear
        service bt restart
        echo "已执行重启命令"
        ;;
      7)
        clear
        cat /tmp/panelBoot
        ;;
      8)
        clear
        cat /www/server/data/*.err
        ;;
      99)
        clear
        wget http://download.bt.cn/install/bt-uninstall.sh && sh bt-uninstall.sh
        ;;
      0)
        break  # 跳出循环，退出菜单
        ;;
      *)
        echo "无效的输入!"
        ;;
    esac
      echo -e "\033[0;32m操作完成\033[0m"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
    done
    ;;
  7)
    while true; do
    clear
    echo "Sing-Box相关"
    echo "--------使用官方内核--------"
    echo "1. 下载Sing-Box官方内核"
    echo "2. 安装Sing-Box官方内核"
    echo "3. 查看Sing-Box官方内核安装位置"
    echo "4. 卸载Sing-Box官方内核"
    echo "---------自行编译---------"
    echo "5. 安装go"
    echo "6. 编译Sing-box全flags内核 ▶"
    echo "------------------------"
    echo "99. 目前已知问题的解决方案 ▶"
    echo "------------------------"
    echo "0. 返回主菜单"
    echo "------------------------"
    read -p "请输入你的选择: " sub_choice
    case $sub_choice in
      1)
        clear
        # 提示用户输入版本号
        read -p "请输入版本号: " desired_version
        # 检查操作系统类型
        if [[ -f /etc/os-release ]]; then
          source /etc/os-release
          if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
            file_extension="deb"
          elif [[ "$ID" == "centos" ]]; then
            file_extension="rpm"
          else
            echo "不支持的操作系统类型"
            exit 1
          fi
        else
          echo "无法确定操作系统类型"
          exit 1
        fi
        # 构建下载链接
        download_link="https://github.com/SagerNet/sing-box/releases/download/v${desired_version}/sing-box_${desired_version}_linux_amd64.${file_extension}"
        # 输出下载链接
        echo "下载链接: $download_link"
        # 使用curl命令下载文件
        curl -L -o sing-box.${file_extension} $download_link
        echo "文件下载完成！"
        ;;
      2)
        clear
        # 检查操作系统类型
        if [[ -f /etc/os-release ]]; then
          source /etc/os-release
          if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
            dpkg -i sing-box.deb
          elif [[ "$ID" == "centos" ]]; then
            rpm -i sing-box.rpm
          else
            echo "不支持的操作系统类型"
            exit 1
          fi
        else
          echo "无法确定操作系统类型"
          exit 1
        fi
        echo "软件安装完成！"
        ;;
      3)
        clear
        # 检查操作系统类型
        if [[ -f /etc/os-release ]]; then
          source /etc/os-release
          if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
            echo "------------------------"
            dpkg -c sing-box.deb
            echo "------------------------"
          elif [[ "$ID" == "centos" ]]; then
            echo "------------------------"
            rpm -c sing-box.rpm
            echo "------------------------"
          else
            echo "不支持的操作系统类型"
            exit 1
          fi
        else
          echo "无法确定操作系统类型"
          exit 1
        fi
        ;;
      4)
        clear
        # 检查操作系统类型
        if [[ -f /etc/os-release ]]; then
          source /etc/os-release
          if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
            echo "------------------------"
            echo "开始卸载"
            rm -f /root/sing-box.deb
            rm -f /etc/systemd/system/sing-box.service
            rm -f /etc/systemd/system/sing-box@.service
            rm -f /usr/bin/sing-box
            rm -rf /etc/sing-box
            rm -rf /usr/share/licenses/
            sleep 1
            echo "------------------------"
            echo "卸载完成"
            echo "------------------------"
          elif [[ "$ID" == "centos" ]]; then
            echo "------------------------"
            echo "开始卸载"
            rm -f /root/sing-box.rpm
            rm -f /etc/systemd/system/sing-box.service
            rm -f /etc/systemd/system/sing-box@.service
            rm -f /usr/bin/sing-box
            rm -rf /etc/sing-box
            rm -rf /usr/share/licenses/
            sleep 1
            echo "------------------------"
            echo "卸载完成"
            echo "------------------------"
          else
            echo "不支持的操作系统类型"
            exit 1
          fi
        else
          echo "无法确定操作系统类型"
          exit 1
        fi
        ;;
      5)
        clear
        # Get the latest Go version from the official website
        latest_version=$(curl -sSfL https://go.dev/dl/ | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]*' | head -n 1)
        clear
        echo "获取到go的最新版为：$latest_version"
        echo "------------------------"
        # Construct the download URL
        download_url="https://go.dev/dl/${latest_version}.linux-amd64.tar.gz"
        echo "开始下载"
        wget -q -c $download_url -O - | tar -xz -C /usr/local && echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile
        rm -f /root/$latest_version.linux-amd64.tar.gz
        source /etc/profile
        sleep 1
        clear
        echo "下载完成，请手动执行此条命令用于为go配置环境："
        echo "------------------------"
        echo "source /etc/profile"
        echo "------------------------"
        ;;
      6)
        while true; do
        clear
        echo "Sing-Box相关"
        echo "------------------------"
        echo "1. 编译最新Latest版"
        echo "2. 编译最新dev-next版"
        echo "3. 编译指定版本"
        echo "------------------------"
        echo "0. 返回主菜单"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice
        case $sub_choice in
          1)
            clear
            /usr/local/go/bin/go install -v -trimpath -ldflags "-s -w -buildid=" -tags with_quic,with_grpc,with_dhcp,with_wireguard,with_shadowsocksr,with_ech,with_utls,with_reality_server,with_acme,with_clash_api,with_v2ray_api,with_gvisor github.com/sagernet/sing-box/cmd/sing-box@latest
            ;;
          2)
            clear
            /usr/local/go/bin/go install -v -trimpath -ldflags "-s -w -buildid=" -tags with_quic,with_grpc,with_dhcp,with_wireguard,with_shadowsocksr,with_ech,with_utls,with_reality_server,with_acme,with_clash_api,with_v2ray_api,with_gvisor github.com/sagernet/sing-box/cmd/sing-box@dev-next
            ;;
          3)
            clear
            # 提示用户输入内容
            echo "获取最新版本号中..."
            REPO_URL="https://api.github.com/repos/SagerNet/sing-box/releases"
            LATEST_TAG=$(curl -s $REPO_URL | jq -r '.[0].tag_name')
            echo "获取成功"
            sleep 1
            clear
            echo "------------------------"
            echo "当前最新的版本为: $LATEST_TAG"
            echo "输入例子 v1.4.0-rc.3 或 v1.4.0-beta.1 或 v1.3.6"
            echo "------------------------"
            read -p "请输入要编译的版本号： " user_input
            clear
            # 构建完整的命令
            command="/usr/local/go/bin/go install -v -trimpath -ldflags "-s -w -buildid=" -tags with_quic,with_grpc,with_dhcp,with_wireguard,with_shadowsocksr,with_ech,with_utls,with_reality_server,with_acme,with_clash_api,with_v2ray_api,with_gvisor github.com/sagernet/sing-box/cmd/sing-box@$user_input"
            # 打印最终的命令
            echo "将要编译的版本是："
            echo "------------------------"
            echo "$user_input"
            echo "------------------------"
            # 确认是否执行命令
            read -p "是否开始编译？(y/n) " execute
            if [ "$execute" == "y" ]; then
              # 执行命令
            clear
            eval "$command"
            # 检查命令是否执行成功
            if [ $? -eq 0 ]; then
              echo "------------------------"
              echo "指令运行完成，内核所在位置："
              echo "/root/go/bin/sing-box"
              echo "------------------------"
            else
              echo "------------------------"
              echo "编译未完成，请检查输入的版本号是否正确，或者是否执行命令5安装go"
              echo "------------------------"
            fi
            else
              echo "已取消执行命令。"
            fi
            ;;
          0)
            break  # 跳出循环，退出菜单
            ;;
          *)
            echo "无效的输入!"
            ;;
        esac
          echo -e "\033[0;32m操作完成\033[0m"
          echo "按任意键继续..."
          read -n 1 -s -r -p ""
          echo ""
          clear
        done
        ;;
      99)
        while true; do
        clear
        echo "已知问题相关"
        echo "------------------------"
        echo "1. 如果SSH登录后显示-bash-x.x 选我"
        echo "------------------------"
        echo "0. 返回主菜单"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice
        case $sub_choice in
          1)
            clear
            cp /etc/skel/.bash_logout /root && cp /etc/skel/.bashrc /root && cp /etc/skel/.profile /root
            echo "已修复，请断开SSH重新连接尝试"
            ;;
          0)
            break  # 跳出循环，退出菜单
            ;;
          *)
            echo "无效的输入!"
            ;;
        esac
          echo -e "\033[0;32m操作完成\033[0m"
          echo "按任意键继续..."
          read -n 1 -s -r -p ""
          echo ""
          clear
        done
        ;;
      0)
        break  # 跳出循环，退出菜单
        ;;
      *)
        echo "无效的输入!"
        ;;
    esac
      echo -e "\033[0;32m操作完成\033[0m"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
    done
    ;;
  30)
    while true; do
    clear
    echo "------------------------"
    echo "1. Yet-Another-Bench-Script 一键测试脚本 ▶"
    echo "2. 优化合集一键脚本"
    echo "3. LemonBench 一键测试脚本 ▶"
    echo "------------------------"
    echo "11. VPS启动耗时"
    echo "12. 硬盘测试"
    echo "------------------------"
    echo "21. 流媒体检测"
    echo "------------------------"
    echo "31. 三网回程测试TCP"
    echo "32. 三网回程测试ICMP"
    echo "33. 三网回程测试TCP/ICMP"
    echo "34. 三网测速"
    echo "------------------------"
    echo "0. 返回上一级"
    echo "------------------------"
    read -p "请输入你的选择: " sub_choice
    case $sub_choice in
      1)
        while true; do
        clear
        echo "Yet-Another-Bench-Script 一键测试脚本"
        echo "------------------------"
        echo "1. wget获取"
        echo "2. curl获取"
        echo "3. 携带参数 - wget获取 ▶"
        echo "4. 携带参数 - curl获取 ▶"
        echo "------------------------"
        echo "0. 返回上一级"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice
        case $sub_choice in
          1)
            clear
            wget -qO- yabs.sh | bash
            ;;
          2)
            clear
            curl -sL yabs.sh | bash
            ;;
          3)
            while true; do
            clear
            echo "wget 版"
            echo "------------------------"
            echo "1. 生成测试脚本链接"
            echo "2. 查询参数"
            echo "------------------------"
            echo "0. 返回上一级"
            echo "------------------------"
            read -p "请输入你的选择: " sub_choice
            case $sub_choice in
              1)
                clear
                echo "------------------------"
                echo "-b: 强制使用仓库中的预编译二进制文件，而不使用本地包"
                echo "-f/-d: 禁用fio（磁盘性能）测试"
                echo "-i: 禁用iperf（网络性能）测试"
                echo "-g: 禁用Geekbench（系统性能）测试"
                echo "-n: 跳过网络信息查找和打印"
                echo "-h: 打印帮助信息，包括用法、检测到的标志和本地包（fio/iperf）状态"
                echo "-r: 减少iperf位置的数量（Scaleway/Clouvider LON+NYC）以减少带宽使用"
                echo "-4: 运行Geekbench 4测试并禁用Geekbench 6测试"
                echo "-5: 运行Geekbench 5测试并禁用Geekbench 6测试"
                echo "-9: 运行Geekbench 4和5测试，而不运行Geekbench 6测试"
                echo "-6: 如果使用了以下任何一个标志：-4、-5或-9，则重新启用Geekbench 6测试（-6标志必须放在最后以防被覆盖）"
                echo "-j: 将结果以JSON格式打印到屏幕上"
                echo "-w <文件名>: 使用提供的文件名将JSON结果写入文件"
                echo "-s <URL>: 将结果以JSON格式发送到指定的URL（见下文部分）"
                echo "------------------------"
                echo "选项可以组合在一起跳过多个测试"
                echo "例子："
                echo "-fg 跳过磁盘和系统性能测试（实际上只测试网络性能）"
                echo "输入的参数需要携带 - "
                echo "------------------------"
                read -p "请输入参数: " input
                # 构建完整的wget命令
                wget_command="wget -qO- yabs.sh | bash -s -- $input"
                # 执行wget命令
                eval "$wget_command"
                ;;
              2)
                clear
                echo "------------------------"
                echo "-b: Forces use of pre-compiled binaries from repo over local packages"
                echo "-f/-d: Disables the fio (disk performance) test"
                echo "-i: Disables the iperf (network performance) test"
                echo "-g: Disables the Geekbench (system performance) test"
                echo "-n: Skips the network information lookup and print out"
                echo "-h: Prints the help message with usage, flags detected, and local package (fio/iperf) status"
                echo "-r: Reduces the number of iperf locations (Scaleway/Clouvider LON+NYC) to lessen bandwidth usage"
                echo "-4: Runs a Geekbench 4 test and disables the Geekbench 6 test"
                echo "-5: Runs a Geekbench 5 test and disables the Geekbench 6 test"
                echo "-9: Runs both the Geekbench 4 and 5 tests instead of the Geekbench 6 test"
                echo "-6: Re-enables the Geekbench 6 test if any of the following were used: -4, -5, or -9 (-6 flag must be last to not be overridden)"
                echo "-j: Prints a JSON representation of the results to the screen"
                echo "-w <filename>: Writes the JSON results to a file using the file name provided"
                echo "-s <url>: Sends a JSON representation of the results to the designated URL(s) (see section below)"
                echo "------------------------"
                ;;
              0)
                break  # 跳出循环，退出菜单
                ;;
              *)
                echo "无效的输入!"
                ;;
            esac
              echo -e "\033[0;32m操作完成\033[0m"
              echo "按任意键继续..."
              read -n 1 -s -r -p ""
              echo ""
              clear
            done
            ;;
          4)
            while true; do
            clear
            echo "curl 版"
            echo "------------------------"
            echo "1. 生成测试脚本链接"
            echo "2. 查询参数"
            echo "------------------------"
            echo "0. 返回上一级"
            echo "------------------------"
            read -p "请输入你的选择: " sub_choice
            case $sub_choice in
              1)
                clear
                echo "------------------------"
                echo "-b: 强制使用仓库中的预编译二进制文件，而不使用本地包"
                echo "-f/-d: 禁用fio（磁盘性能）测试"
                echo "-i: 禁用iperf（网络性能）测试"
                echo "-g: 禁用Geekbench（系统性能）测试"
                echo "-n: 跳过网络信息查找和打印"
                echo "-h: 打印帮助信息，包括用法、检测到的标志和本地包（fio/iperf）状态"
                echo "-r: 减少iperf位置的数量（Scaleway/Clouvider LON+NYC）以减少带宽使用"
                echo "-4: 运行Geekbench 4测试并禁用Geekbench 6测试"
                echo "-5: 运行Geekbench 5测试并禁用Geekbench 6测试"
                echo "-9: 运行Geekbench 4和5测试，而不运行Geekbench 6测试"
                echo "-6: 如果使用了以下任何一个标志：-4、-5或-9，则重新启用Geekbench 6测试（-6标志必须放在最后以防被覆盖）"
                echo "-j: 将结果以JSON格式打印到屏幕上"
                echo "-w <文件名>: 使用提供的文件名将JSON结果写入文件"
                echo "-s <URL>: 将结果以JSON格式发送到指定的URL（见下文部分）"
                echo "------------------------"
                echo "选项可以组合在一起跳过多个测试"
                echo "例子："
                echo "-fg 跳过磁盘和系统性能测试（实际上只测试网络性能）"
                echo "输入的参数需要携带 - "
                echo "------------------------"
                read -p "请输入参数: " input
                # 构建完整的curl命令
                curl_command="curl -sL yabs.sh | bash -s -- $input"
                # 执行curl命令
                eval "$curl_command"
                ;;
              2)
                clear
                echo "------------------------"
                echo "-b: Forces use of pre-compiled binaries from repo over local packages"
                echo "-f/-d: Disables the fio (disk performance) test"
                echo "-i: Disables the iperf (network performance) test"
                echo "-g: Disables the Geekbench (system performance) test"
                echo "-n: Skips the network information lookup and print out"
                echo "-h: Prints the help message with usage, flags detected, and local package (fio/iperf) status"
                echo "-r: Reduces the number of iperf locations (Scaleway/Clouvider LON+NYC) to lessen bandwidth usage"
                echo "-4: Runs a Geekbench 4 test and disables the Geekbench 6 test"
                echo "-5: Runs a Geekbench 5 test and disables the Geekbench 6 test"
                echo "-9: Runs both the Geekbench 4 and 5 tests instead of the Geekbench 6 test"
                echo "-6: Re-enables the Geekbench 6 test if any of the following were used: -4, -5, or -9 (-6 flag must be last to not be overridden)"
                echo "-j: Prints a JSON representation of the results to the screen"
                echo "-w <filename>: Writes the JSON results to a file using the file name provided"
                echo "-s <url>: Sends a JSON representation of the results to the designated URL(s) (see section below)"
                echo "------------------------"
                ;;
              0)
                break  # 跳出循环，退出菜单
                ;;
              *)
                echo "无效的输入!"
                ;;
            esac
              echo -e "\033[0;32m操作完成\033[0m"
              echo "按任意键继续..."
              read -n 1 -s -r -p ""
              echo ""
              clear
            done
            ;;
          0)
            break  # 跳出循环，退出菜单
            ;;
          *)
            echo "无效的输入!"
            ;;
        esac
          echo -e "\033[0;32m操作完成\033[0m"
          echo "按任意键继续..."
          read -n 1 -s -r -p ""
          echo ""
          clear
        done
        ;;
      2)
        clear
        wget -O tcpx.sh "https://github.com/ylx2016/Linux-NetSpeed/raw/master/tcpx.sh" && chmod +x tcpx.sh && ./tcpx.sh
        ;;
      3)
        while true; do
        clear
        echo "LemonBench 一键测试脚本"
        echo "------------------------"
        echo "1. 稳定版 - wget获取"
        echo "2. 稳定版 - curl获取"
        echo "3. 测试版 - wget获取 (可及时体验新功能)"
        echo "4. 测试版 - curl获取 (可及时体验新功能)"
        echo "------------------------"
        echo "0. 返回上一级"
        echo "------------------------"
        read -p "请输入你的选择: " sub_choice
        case $sub_choice in
          1)
            clear
            wget -O- https://ilemonra.in/LemonBench | bash -s -- --fast
            ;;
          2)
            clear
            curl -fsL https://ilemonra.in/LemonBench | bash -s -- --fast
            ;;
          3)
            clear
            wget -O- https://ilemonra.in/LemonBench-Beta | bash -s -- --fast
            ;;
          4)
            clear
            curl -fsL https://ilemonra.in/LemonBench-Beta | bash -s -- --fast
            ;;
          0)
            break  # 跳出循环，退出菜单
            ;;
          *)
            echo "无效的输入!"
            ;;
        esac
          echo -e "\033[0;32m操作完成\033[0m"
          echo "按任意键继续..."
          read -n 1 -s -r -p ""
          echo ""
          clear
        done
        ;;
      11)
        clear
        systemd-analyze
        ;;
      12)
        clear
        echo "耗时较长，请耐心等待 (数值越高越好)"
        dd bs=64k count=4k if=/dev/zero of=test oflag=dsync
		    rm -f /root/test
        ;;
      21)
        clear
        echo "请稍等，启动脚本前需下载一些必备软件"
        bash <(curl -L -s check.unlock.media)
        ;;
      31)
        clear
        curl https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh|bash
        ;;
      32)
        clear
        curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
        ;;
      33)
        clear
        wget https://raw.githubusercontent.com/vpsxb/testrace/main/testrace.sh -O testrace.sh && bash testrace.sh
        ;;
      34)
        clear
        bash <(curl -Lso- https://git.io/superspeed_uxh)
        ;;
      0)
        break  # 跳出循环，退出菜单
        ;;

      *)
        echo "无效的输入!"
        ;;
    esac
      echo -e "\033[0;32m操作完成\033[0m"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
    done
    ;;
  99)
    while true; do
    clear
    echo "------------------------"
    echo "1. 添加快捷指令"
    echo "2. 更新脚本"
    echo "3. 删除脚本"
    echo "------------------------"
    echo "0. 返回上一级"
    echo "------------------------"
    read -p "请输入你的选择: " sub_choice
    case $sub_choice in
      1)
        clear
        sed -i '/alias jms=.*jms.sh/d' .bashrc
        read -p "请输入你的快捷按键: " jms
        if ! grep -q "alias $jms='wget -q -P /root -N --no-check-certificate "https://raw.githubusercontent.com/jklolixxs/jms/main/jms.sh" && chmod 700 /root/jms.sh'" ~/.bashrc; then
          echo "alias $jms='wget -q -P /root -N --no-check-certificate "https://raw.githubusercontent.com/jklolixxs/jms/main/jms.sh" && chmod 700 /root/jms.sh'" >> ~/.bashrc
          source  ~/.bashrc
        fi
        echo "------------------------"
        echo "添加成功"
        echo "输入下面这条指令同步缓存："
        echo "------------------------"
        echo "source ~/.bashrc"
        echo "------------------------"
        echo "如无效，请重启机器"
        echo "------------------------"
        ;;
      2)
        clear
        echo "------------------------"
        echo "开始更新脚本"
        echo "------------------------"
        rm -f /root/jms.sh
        wget -q -P /root -N --no-check-certificate "https://raw.githubusercontent.com/jklolixxs/jms/main/jms.sh" && chmod 700 /root/jms.sh
        clear
        echo "------------------------"
        echo "脚本更新完毕"
        echo "------------------------"
        /root/jms.sh
        exit
        ;;
      3)
        clear
        read -p "请输入你设置的快捷按键: " jms
        sed -i "/alias $jms=.*jms.sh/d" .bashrc
        source ~/.bashrc
        rm -f /root/jms.sh
        echo "------------------------"
        echo "脚本删除成功"
        echo "请手动输入下面这条指令同步缓存："
        echo "------------------------"
        echo "source ~/.bashrc"
        echo "------------------------"
        echo "如仍存在缓存，请重启机器"
        echo "------------------------"
        exit
        ;;
      0)
        break  # 跳出循环，退出菜单
        ;;
      *)
        echo "无效的输入!"
        ;;
    esac
      echo -e "\033[0;32m操作完成\033[0m"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
    done
    ;;
  0)
    clear
    break  # 跳出循环，退出菜单
    ;;
  *)
    echo "无效的输入!"
esac
  echo -e "\033[0;32m操作完成\033[0m"
  echo "按任意键继续..."
  read -n 1 -s -r -p ""
  echo ""
  clear
done
