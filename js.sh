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
  echo 反馈: https://github.com/jklolixxs/jms/issues
  echo =================================================
  echo "1. Docker 管理器 ▶"
  echo "2. Docker 容器一键安装 ▶"
  echo "------------------------"
  echo "99. 脚本相关功能 ▶"
  echo "------------------------"
  echo "0. 退出脚本"
  echo "------------------------"
  read -p "请输入你的选择: " choice
  case $choice in
  1)
    while true; do
      clear
      echo "Docker管理器"
      echo "------------------------"
      echo "1. 安装 Docker 及相关组件"
      echo "2. 更新 Docker 及相关组件"
      echo "3. 卸载 Docker 及相关组件"
      echo "------------------------"
      echo "4. 查看 Docker 全局状态"
      echo "------------------------"
      echo "5. Docker 容器管理 ▶"
      echo "6. Docker 镜像管理 ▶"
      echo "7. Docker 网络管理 ▶"
      echo "8. Docker 卷管理 ▶"
      echo "------------------------"
      echo "9. 清理无用的 Docker 容器和镜像网络数据卷"
      echo "------------------------"
      echo "0. 返回上一级"
      echo "------------------------"
      read -p "请输入你的选择: " sub_choice
      case $sub_choice in
      1)
        clear
        # 检测 curl 是否已安装
        if command -v curl &>/dev/null; then
          # 已安装，略过，向下执行
          :
        else
          # 静默更新并安装curl
          echo "未安装curl，正在安装，请稍等..."
          apt update -qq
          apt install curl -y -qq
          sleep 0.5
        fi
        # 检测 Docker 是否已安装
        if command -v docker &>/dev/null; then
          echo "------------------------------------------------"
          echo "Docker         已安装，版本为 $(docker --version)"
          echo "Docker Compose 已安装，版本为 $(docker compose version)"
          echo "如要更新或卸载，请执行 2 "
          echo "------------------------------------------------"
        else
          # curl -fsSL https://get.docker.com | sh
          curl -fsSL https://get.docker.com -o install-docker.sh
          sh get-docker.sh
          systemctl enable docker
          systemctl start docker
        fi
        ;;
      2)
        clear
        # 检测 Docker 是否已安装
        if command -v docker &>/dev/null; then
          echo "------------------------------------------------"
          echo "Docker         已安装，版本为 $(docker --version)"
          echo "Docker Compose 已安装，版本为 $(docker compose version)"
          read -p "确定要 更新 Docker 及相关组件吗？(Y/N): " choice
          case "$choice" in
          [Yy])
            curl -fsSL https://get.docker.com -o install-docker.sh
            sh get-docker.sh
            rm -f ./get-docker.sh
            ;;
          [Nn]) ;;
          *)
            echo "无效的选择，请输入 Y 或 N。"
            ;;
          esac
        else
          echo "请先安装 Docker"
        fi
        ;;
      3)
        clear
        # 检测 Docker 是否已安装
        if command -v docker &>/dev/null; then
          echo "------------------------------------------------"
          echo "Docker         已安装，版本为 $(docker --version)"
          echo "Docker Compose 已安装，版本为 $(docker compose version)"
          read -p "确定要 更新 Docker 及相关组件吗？(Y/N): " choice
          case "$choice" in
          [Yy])
            apt purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras -y
            ;;
          [Nn]) ;;
          *)
            echo "无效的选择，请输入 Y 或 N。"
            ;;
          esac
        else
          echo "请先安装 Docker"
        fi
        ;;
      4)
        clear
        # 检查 docker 版本
        echo "Docke         版本为 $(docker --version)"
        # 检查 docker compose 版本
        if output=$(docker-compose --version 2>&1); then
          echo "Docker Compose 版本为 $output"
        else
          docker compose version
        fi
        echo ""
        echo "Docker 镜像列表"
        docker image ls
        echo ""
        echo "Docker 容器列表"
        docker ps -a
        echo ""
        echo "Docker 卷列表"
        docker volume ls
        echo ""
        echo "Docker 网络列表"
        docker network ls
        echo ""
        ;;
      5)
        while true; do
          clear
          echo "Docker 容器列表"
          docker ps -a
          echo ""
          echo "容器操作"
          echo "------------------------"
          echo "1. 启动指定容器             2. 启动所有容器"
          echo "3. 重启指定容器             4. 重启所有容器"
          echo "5. 停止指定容器             6. 停止所有容器"
          echo "7. 删除指定容器             8. 删除所有容器"
          echo "------------------------"
          echo "9. 进入指定容器             10. 查看容器日志"
          echo "------------------------"
          echo "0. 返回上一级"
          echo "------------------------"
          read -p "请输入你的选择: " sub_choice
          case $sub_choice in
          1)
            read -p "请输入容器名：" dockername
            docker start $dockername
            ;;
          2)
            docker start $(docker ps -a -q)
            ;;
          3)
            read -p "请输入容器名：" dockername
            docker restart $dockername
            ;;
          4)
            docker restart $(docker ps -q)
            ;;
          5)
            read -p "请输入容器名：" dockername
            docker stop $dockername
            ;;
          6)
            docker stop $(docker ps -q)
            ;;
          7)
            read -p "确定删除所有容器吗？(Y/N): " choice
            case "$choice" in
            [Yy])
              docker rm -f $(docker ps -a -q)
              ;;
            [Nn]) ;;
            *)
              echo "无效的选择，请输入 Y 或 N。"
              ;;
            esac
            ;;
          8)
            read -p "请输入容器名：" dockername
            docker rm -f $dockername
            ;;
          9)
            read -p "请输入容器名：" dockername
            docker exec -it $dockername /bin/bash
            ;;
          10)
            read -p "请输入容器名：" dockername
            docker logs $dockername
            ;;
          0)
            break # 跳出循环，退出菜单
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
          echo "Docker 镜像列表"
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
            [Nn]) ;;
            *)
              echo "无效的选择，请输入 Y 或 N。"
              ;;
            esac
            ;;
          0)
            break # 跳出循环，退出菜单
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
            break # 跳出循环，退出菜单
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
      8)
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
            break # 跳出循环，退出菜单
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
      9)
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
    10)
      clear
      read -p "确定清理无用的镜像容器网络吗？(Y/N): " choice
      case "$choice" in
      [Yy])
        docker system prune -af --volumes
        ;;
      [Nn]) ;;
      *)
        echo "无效的选择，请输入 Y 或 N。"
        ;;
      esac
      ;;
    0)
      break # 跳出循环，退出菜单
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
    while true; do
      clear
      echo "Docker 容器一键搭建"
      echo "------------------------"
      echo "面板专区"
      echo "1. NginxProxyManager可视化面板"
      echo "------------------------"
      echo "建站专区"
      echo "30. vaultwarden密码管理器                  31. AList多存储文件程序"
      echo "32. searxng聚合搜索引擎"
      echo "------------------------"
      echo "程序专区"
      echo "60. acme自动申请证书工具                    61. AList多存储文件列表程序"
      echo "------------------------"
      echo "0. 返回上一级"
      echo "------------------------"
      read -p "请输入你的选择: " sub_choice
      case $sub_choice in
      1)
        clear
        # 检查容器是否在运行
        if docker ps --format '{{.Names}}' | grep -q "npm"; then
          while true; do
            clear
            echo "------------------------"
            echo "NginxProxyManager可视化面板"
            echo "------------------------"
            echo "1. 启动容器"
            echo "2. 重启容器"
            echo "3. 停止容器"
            echo "4. 删除容器"
            echo "5. 更新容器"
            echo "------------------------"
            echo "0. 返回上一级"
            echo "------------------------"
            read -p "请输入你的选择: " sub_choice
            case $sub_choice in
            1)
              docker compose -f /home/docker/docker-npm.yml up -d npm
              echo "容器已启动"
              ;;
            2)
              docker compose -f /home/docker/docker-npm.yml restart npm
              echo "容器已重启"
              ;;
            3)
              docker compose -f /home/docker/docker-npm.yml stop npm
              echo "容器已停止"
              ;;
            4)
              docker compose -f /home/docker/docker-npm.yml down npm
              echo "容器已删除"
              ;;
            5)
              docker compose -f /home/docker/docker-npm.yml pull npm
              echo "容器已更新"
              ;;
            0)
              break # 跳出循环，退出菜单
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
        else
          echo 'services:
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: npm
    restart: always
    # network_mode: host
    volumes:
      - ./acme:/acme.sh
    logging:
      driver: "json-file"
      options:
        max-size: "5m"
        max-file: "3"
' > /home/docker/docker-npm.yml
          # echo "$yaml_content" 
          docker compose -f /home/docker/docker-npm.yml up -d npm
          echo "Nginx Proxy Manager 容器已运行"
          # 缺失的 'fi' 被添加在这里
        fi
        ;;
      30|31|32|60|61)
        clear
        echo "该功能暂未开发,请期待后续更新"
        ;; 
      0)
        break # 跳出循环，退出菜单
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
        sed -i '/alias .*jms.sh/d' .bashrc
        read -p "请输入你的快捷按键: " jms
        if ! grep -q "alias $jms='wget -q -P /root -N --no-check-certificate "https://raw.githubusercontent.com/jklolixxs/jms/main/jd.sh" && chmod 700 /root/jms.sh && /root/jd.sh'" ~/.bashrc; then
          echo "alias $jms='wget -q -P /root -N --no-check-certificate "https://raw.githubusercontent.com/jklolixxs/jms/main/jd.sh" && chmod 700 /root/jms.sh && /root/jd.sh'" >>~/.bashrc
          source ~/.bashrc
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
        rm -f /root/jd.sh
        wget -q -P /root -N --no-check-certificate "https://raw.githubusercontent.com/jklolixxs/jms/main/jd.sh" && chmod 700 /root/jd.sh
        clear
        echo "------------------------"
        echo "脚本更新完毕"
        echo "------------------------"
        /root/jd.sh
        exit
        ;;
      3)
        clear
        read -p "请输入你为脚本设置的快捷按键: " jms
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
        break # 跳出循环，退出菜单
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
    break # 跳出循环，退出菜单
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
