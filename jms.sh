#!/bin/bash

while true; do
clear
echo JMS一键脚本
echo 支持Ubuntu / Debian / Centos系统
echo "------------------------"
echo "1. 系统信息查询"
echo "2. 系统更新"
echo "3. 系统清理"
echo "------------------------"
echo "4. 常用工具安装 ▶"
echo "5. Docker管理 ▶"
echo "------------------------"
echo "7. 一些常用脚本 ▶"
echo "------------------------"
echo "0. 退出脚本"
echo "------------------------"
echo "99. 添加快捷方式与如何删除快捷方式"
echo "------------------------"
read -p "请输入你的选择: " choice

case $choice in
  1)
    clear
    # 函数：获取IPv4和IPv6地址
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
    echo "内存占用: $mem_info"
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
    echo "系统时间：$current_time"
    echo
    ;;

  2)
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

  3)
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

  4)
  while true; do
      clear
      echo "安装常用工具"
      echo "------------------------"
      echo "1. curl 下载工具"
      echo "2. wget 下载工具"
      echo "3. sudo 超级管理权限工具"
      echo "4. ufw 防火墙管理工具 (仅建议Debian/Ubuntu安装)"
      echo "5. screen 多终端窗口后台运行工具"
      echo "6. socat 通信连接工具 (申请域名证书必备)"
      echo "7. dnsutils DNS相关工具 (仅限Debian/Ubuntu安装)"
      echo "8. bind-utils DNS相关工具 (仅限Centos安装)"
      echo "9. cpulimit 限制CPU使用率"
      echo "10. htop 系统监控工具"
      echo "11. chrony NTP时间同步工具"
      echo "12. iftop 网络流量监控工具"
      echo "13. unzip ZIP压缩解压工具z"
      echo "14. tar GZ压缩解压工具"
      echo "15. screenfetch 通过有趣的图形和标志展现有关您的系统和发行版的信息"
      echo "16. jq 用于处理JSON数据 (如果后面使用一键脚本，可能需要用到此工具)"
      echo "------------------------"
      echo "31. 全部安装"
      echo "32. 全部卸载"
      echo "------------------------"
      echo "0. 返回主菜单"
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
                  apt update -y && apt install -y sudo
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install sudo
              else
                  echo "未知的包管理器!"
              fi
              ;;
            4)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y ufw
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install ufw
              else
                  echo "未知的包管理器!"
              fi
              ;;
            5)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y screen
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install screen
              else
                  echo "未知的包管理器!"
              fi
              ;;
            6)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y socat
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install socat
              else
                  echo "未知的包管理器!"
              fi
              ;;
            7)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y dnsutils
              else
                  echo "未知的包管理器!"
              fi
              ;;
            8)
              clear
              if command -v yum &>/dev/null; then
                  yum -y update && yum -y install bind-utils
              else
                  echo "未知的包管理器!"
              fi
              ;;
            9)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y cpulimit
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install cpulimit
              else
                  echo "未知的包管理器!"
              fi
              ;;
            10)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y htop
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install htop
              else
                  echo "未知的包管理器!"
              fi
              ;;
            11)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y chrony
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install chrony
              else
                  echo "未知的包管理器!"
              fi
              ;;
            12)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y iftop
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install iftop
              else
                  echo "未知的包管理器!"
              fi
              ;;
            13)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y unzip
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install unzip
              else
                  echo "未知的包管理器!"
              fi
              ;;
            14)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y tar
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install tar
              else
                  echo "未知的包管理器!"
              fi
              ;;
            15)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y screenfetch
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install screenfetch
              else
                  echo "未知的包管理器!"
              fi
              ;;


          31)
              clear
              if command -v apt &>/dev/null; then
                  apt update -y && apt install -y curl wget sudo ufw screen socat dnsutils cpulimit htop chrony iftop unzip tar screenfetch jq
              elif command -v yum &>/dev/null; then
                  yum -y update && yum -y install curl wget sudo ufw screen socat bind-utils cpulimit htop chrony iftop unzip tar screenfetch jq
              else
                  echo "未知的包管理器!"
              fi
              ;;

          32)
              clear
              if command -v apt &>/dev/null; then
                  apt remove -y htop iftop unzip tmux ffmpeg
              elif command -v yum &>/dev/null; then
                  yum -y remove htop iftop unzip tmux ffmpeg
              else
                  echo "未知的包管理器!"
              fi
              ;;

          0)
              /root/jms.sh
              exit
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
      echo "2. 查看Dcoker全局状态"
      echo "------------------------"
      echo "3. Dcoker容器管理 ▶"
      echo "4. Dcoker镜像管理 ▶"
      echo "5. Dcoker网络管理 ▶"
      echo "6. Dcoker卷管理 ▶"
      echo "------------------------"
      echo "7. 清理无用的docker容器和镜像网络数据卷"
      echo "------------------------"
      echo "8. 卸载Dcoker环境"
      echo "------------------------"
      echo "0. 返回主菜单"
      echo "------------------------"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in
          1)
              clear
              curl -fsSL https://get.docker.com | sh
              sudo systemctl start docker
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
              ;;
          2)
              clear
              echo "Dcoker版本"
              docker --version
              docker-compose --version
              echo ""
              echo "Dcoker镜像列表"
              docker image ls
              echo ""
              echo "Dcoker容器列表"
              docker ps -a
              echo ""
              echo "Dcoker卷列表"
              docker volume ls
              echo ""
              echo "Dcoker网络列表"
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
                  echo "0. 返回上一级选单"
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
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
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
                  echo "0. 返回上一级选单"
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
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
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
                  echo "0. 返回上一级选单"
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
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
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
                  echo "0. 返回上一级选单"
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
                          break  # 跳出循环，退出菜单
                          ;;
                  esac
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
              /root/jms.sh
              exit
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
      # Update system on Debian-based systems
      if [ -f "/etc/debian_version" ]; then
          if ! command -v jq &>/dev/null; then
              echo "------------------------"
              echo "首次打开会检测是否安装必备应用jq，如果未安装，则会安装，请耐心等待"
              echo "------------------------"
              DEBIAN_FRONTEND=noninteractive apt update -y > /dev/null 2>&1 && DEBIAN_FRONTEND=noninteractive apt install jq -y > /dev/null 2>&1
              clear
          fi
      fi
      # Update system on Red Hat-based systems
      if [ -f "/etc/redhat-release" ]; then
          if ! command -v jq &>/dev/null; then
              echo "------------------------"
              echo "首次打开会检测是否安装必备应用jq，如果未安装，则会安装，请耐心等待"
              echo "------------------------"
              yum -y update > /dev/null 2>&1 && yum install -y jq > /dev/null 2>&1
              clear
          fi
      fi
      echo "系统相关脚本"
      echo "1. 优化合集一键脚本"
      echo "2. DD脚本"
      echo "3. WARP一键脚本"
      echo "4. 一键修改SSH登录端口"
      echo "------------------------"
      echo "测试相关脚本"
      echo "31. VPS启动耗时"
      echo "32. 硬盘测试"
      echo "33. 流媒体检测"
      echo "34. 三网回程测试TCP"
      echo "35. 三网回程测试ICMP"
      echo "36. 三网回程测试TCP/ICMP"
      echo "37. 三网测速"
      echo "38. LemonBench 一键测试脚本 ▶"
      echo "------------------------"
      echo "翻墙脚本"
      echo "51. X-UI"
      echo "53. 3X-UI"
      echo "54. xray8合1一键部署脚本"
      echo "55. Hysteria一键脚本"
      echo "56. Sing-Box相关 ▶"
      echo "------------------------"
      echo "0. 返回主菜单"
      echo "------------------------"
      read -p "请输入你的选择: " sub_choice

      case $sub_choice in
          1)
              clear
              wget -O /root/tcpx.sh "https://github.com/ylx2016/Linux-NetSpeed/raw/master/tcpx.sh" && chmod +x /root/tcpx.sh && /root/tcpx.sh
              ;;

          2)
              clear
              wget --no-check-certificate -O /root/NewReinstall.sh https://git.io/newbetags && chmod a+x /root/NewReinstall.sh && bash /root/NewReinstall.sh
              ;;

          3)
              clear
              wget -N https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh && bash menu.sh [option]
              ;;

          4)
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
                       echo "更换完成，当前SSH登录端口是："
                       echo "$user_input"
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

          31)
              clear
              systemd-analyze
              ;;

          32)
              clear
              echo "耗时较长，请耐心等待 (数值越高越好)"
              dd bs=64k count=4k if=/dev/zero of=test oflag=dsync
			  rm -f /root/test
              ;;

          33)
              clear
              bash <(curl -L -s check.unlock.media)
              ;;

          34)
              clear
              curl https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh|bash
              ;;

          35)
              clear
              curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
              ;;

          36)
              clear
              wget https://raw.githubusercontent.com/vpsxb/testrace/main/testrace.sh -O testrace.sh && bash testrace.sh
              ;;

          37)
              clear
              bash <(curl -Lso- https://git.io/superspeed_uxh)
              ;;

          38)
            while true; do
            clear
            echo "LemonBench 一键测试脚本"
            echo "------------------------"
            echo "1. 稳定版 - wget"
            echo "2. 稳定版 - curl"
            echo "3. 测试版 - wget (可及时体验新功能)"
            echo "4. 测试版 - curl (可及时体验新功能)"
            echo "------------------------"
            echo "0. 返回主菜单"
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
                    /root/jms.sh
                    exit
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

          51)
              clear
              bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh)
              ;;

          53)
              clear
              bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
              ;;

          54)
              clear
              wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
              ;;

          55)
              clear
              bash <(curl -fsSL https://git.io/hysteria.sh)
              ;;

          56)
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
                                  sudo dpkg -i sing-box.deb
                              elif [[ "$ID" == "centos" ]]; then
                                  sudo rpm -i sing-box.rpm
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
                                  sudo dpkg -c sing-box.deb
                                  echo "------------------------"
                              elif [[ "$ID" == "centos" ]]; then
                                  echo "------------------------"
                                  sudo rpm -c sing-box.rpm
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
                          set -e -o pipefail
              
                          go_version=$(curl -s https://raw.githubusercontent.com/actions/go-versions/main/versions-manifest.json | grep -oE '"version": "[0-9]{1}.[0-9]{1,}(.[0-9]{1,})?"' | head -1 | cut -d':' -f2 | sed 's/ //g; s/"//g')
                          curl -Lo go.tar.gz "https://go.dev/dl/go$go_version.linux-amd64.tar.gz"
                          sudo rm -rf /usr/local/go
                          sudo tar -C /usr/local -xzf go.tar.gz
                          rm go.tar.gz
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
                                go install -v -tags with_quic,with_grpc,with_dhcp,with_wireguard,with_shadowsocksr,with_ech,with_utls,with_reality_server,with_acme,with_clash_api,with_v2ray_api,with_gvisor github.com/sagernet/sing-box/cmd/sing-box@latest
                                ;;
              
                            2)
                                clear
                                go install -v -tags with_quic,with_grpc,with_dhcp,with_wireguard,with_shadowsocksr,with_ech,with_utls,with_reality_server,with_acme,with_clash_api,with_v2ray_api,with_gvisor github.com/sagernet/sing-box/cmd/sing-box@dev-next
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
                                command="go install -v -tags with_quic,with_grpc,with_dhcp,with_wireguard,with_shadowsocksr,with_ech,with_utls,with_reality_server,with_acme,with_clash_api,with_v2ray_api,with_gvisor github.com/sagernet/sing-box/cmd/sing-box@$user_input"
              
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
                                        echo "编译未完成，请检查输入的版本号是否正确"
                                        echo "------------------------"
                                    fi
                                else
                                   echo "已取消执行命令。"
                                fi
                                ;;
              
                            0)
                                /root/jms.sh
                                exit
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
                                /root/jms.sh
                                exit
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
                          /root/jms.sh
                          exit
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
              /root/jms.sh
              exit
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
    clear

    shortcut_added=false
    # Check if the alias is already added in .bashrc
    if ! grep -q "alias jms='wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/jklolixxs/jms/main/jms.sh" && chmod 700 /root/jms.sh && /root/jms.sh Bash'" ~/.bashrc; then
        echo "alias jms='wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/jklolixxs/jms/main/jms.sh" && chmod 700 /root/jms.sh && /root/jms.sh Bash'" >> ~/.bashrc
        shortcut_added=true
    fi

    # If shortcut was added, then source .bashrc
    if [ "$shortcut_added" = true ]; then
        source ~/.bashrc

    fi
    echo "快捷方式添加成功"
    echo "输入 jms 即可唤醒脚本"
    echo "------------------------"
    echo "删除快捷方式："
    echo ""
    echo "sed -i '/alias jms=.*Bash/d' .bashrc && source ~/.bashrc"
    echo ""
    echo "------------------------"
    echo "如需卸载脚本，请自行运行:"
    echo ""
    echo "rm -f /root/jms.sh"
    echo ""
    echo "------------------------"
    ;;

  0)
    clear
    exit
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
