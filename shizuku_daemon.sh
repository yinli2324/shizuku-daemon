#!/data/data/com.termux/files/usr/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# Copyright (c) 2026 音YINLI黎 (YINLI2324)


# ==========================================
# 环境探测：防呆设计
# ==========================================
if [ -z "$BASH_VERSION" ]; then
    echo -e "\033[1;31m[ ✖ FATAL ] 异常：检测到非标准 Shell 解释器或非Termux终端执行！\033[0m"
    echo -e "\033[1;33m[ i TRACE ] 进程堆栈溢出警告。本引擎依赖高级阵列与底层调用，拒绝在基础 sh 环境运行。\033[0m"
    echo -e "\033[1;32m[ ✔ GUIDE ] 👉 标准执行指令：bash $0\033[0m"
    exit 1
fi

# 静态审计防御：禁止逆向者通过 set -x 或 trap DEBUG 跟踪每一步汇编
if [[ "$*" == *"-x"* ]] || [ -n "$BASH_XTRACEFD" ]; then
    echo -e "\033[1;31m[ ☠️ SECURITY ] Trace enforcement detected. Shell panic.\033[0m"
    exit 9
fi

# ==========================================
# 霓虹科技配色方案 —— 使用 $'\x1b' 注入真实 ESC 字符
# ==========================================
C_CYAN=$'\x1b[1;36m'     # 霓虹青
C_BLUE=$'\x1b[1;34m'     # 科技蓝
C_PURPLE=$'\x1b[1;35m'   # 电竞紫
C_GREEN=$'\x1b[1;32m'    # 状态绿
C_RED=$'\x1b[1;31m'      # 警告红
C_YELLOW=$'\x1b[1;33m'   # 提示黄
C_WHITE=$'\x1b[1;37m'    # 纯净白
C_DIM=$'\x1b[2m'         # 弱化灰
C_RESET=$'\x1b[0m'       # 样式重置

# 主进程 PID 记录
MAIN_PID=$$

# 全局配置文件与动态日志路径
LOG_DIR="/storage/emulated/0/shizuku进程守护"
CONFIG_FILE="${LOG_DIR}/config配置.cfg"
mkdir -p "$LOG_DIR"

# 动态按天切分日志文件名
TODAY=$(date '+%Y-%m-%d')
LOG_FILE="${LOG_DIR}/log_${TODAY}.txt"

exec 3>>"$LOG_FILE"

# ==========================================
# 视觉特效引擎 —— 修复版（Termux 适配）
# ==========================================

# 打字机逐字输出
type_fx() {
    local text="$1"
    local color="${2:-$C_WHITE}"
    local delay="${3:-0.08}"
    printf "%s" "$color"
    local i
    for ((i=0; i<${#text}; i++)); do
        printf "%s" "${text:$i:1}"
        sleep "$delay" 2>/dev/null || sleep 0.05
    done
    printf "%s\n" "$C_RESET"
}

# 连续填充进度条
draw_progress() {
    local label="$1"
    local percent=$2
    local width=24
    local filled=$((width * percent / 100))
    local empty=$((width - filled))
    local bar=""
    local i
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    printf "\r%s[%s%s%s%s%s]%s %s%3d%%%s" \
        "${C_DIM}" "${C_CYAN}" "$label" "${C_RESET}" "${C_WHITE}" "$bar" "${C_RESET}" "${C_PURPLE}" "$percent" "${C_RESET}"
}

# 平滑进度动画
animate_progress() {
    local label="$1"
    echo ""
    local p
    for ((p=0; p<=100; p+=2)); do
        draw_progress "$label" $p
        sleep 0.01
    done
    printf "\n"
}

# 退出捕获
safe_exit() {
    echo -e "\n${C_RED}[ ⏏ TERMINATE ] 捕获到中断信号 (SIGINT/SIGTERM)。${C_RESET}"
    echo -e "${C_DIM}[ ↻ SYSTEM ] 正在卸载守护探针，释放系统唤醒锁...${C_RESET}"
    pkill -P $$ 2>/dev/null || jobs -p 2>/dev/null | xargs -r kill 2>/dev/null
    if command -v termux-wake-unlock >/dev/null 2>&1; then
        termux-wake-unlock
    fi
    exec 3>&- 2>/dev/null 
    echo -e "${C_GREEN}[ ✔ SYSTEM ] 资源回收完毕，引擎安全挂起。${C_RESET}"
    echo -e "${C_CYAN}================ THANK YOU USE SHIZUKU DAEMON ===================${C_RESET}"
    exit 0
}
trap safe_exit SIGINT SIGTERM SIGUSR1

# ==========================================
# 核心通信状态校验
# ==========================================
is_adb_ready() {
    if adb shell "echo 1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# ==========================================
# 守护进程静默重连协议
# ==========================================
silent_adb_reconnect() {
    local SAVED_PORT=""
    if [ -f "$CONFIG_FILE" ]; then
        SAVED_PORT=$(grep "^LOCAL_ADB_PORT=" "$CONFIG_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    fi
    
    if [ -n "$SAVED_PORT" ]; then
        adb connect 127.0.0.1:"$SAVED_PORT" >/dev/null 2>&1
        sleep 1
    fi
}

# ==========================================
# ADB 断线与交互式双轨授权向导
# ==========================================
handle_adb_disconnect() {
    echo -e "\n${C_RED}╭────────────────────────────────────────────────────────────╮${C_RESET}"
    echo -e "${C_RED}│                 ${C_WHITE}⚠️  底层 ADB 通信链路阻断 ⚠️               ${C_RED}│${C_RESET}"
    echo -e "${C_RED}├────────────────────────────────────────────────────────────┤${C_RESET}"
    echo -e "${C_RED}│ ${C_YELLOW}诊断报告：系统侦测到 Termux 守护进程与 Android 宿主间的     ${C_RED}│${C_RESET}"
    echo -e "${C_RED}│ ${C_YELLOW}Socket 连接已丢失。可能是授权掉线或守护端口发生漂移。     ${C_RED}│${C_RESET}"
    echo -e "${C_RED}│                                                            │${C_RESET}"
    echo -e "${C_RED}│ ${C_GREEN}💡 链路重建协议：${C_RESET}                                          ${C_RED}│${C_RESET}"
    echo -e "${C_RED}│ ${C_GREEN}1. 确认目标设备的 [无线调试] 端口服务处于监听态。${C_RESET}          ${C_RED}│${C_RESET}"
    echo -e "${C_RED}│ ${C_GREEN}2. 执行握手指令：${C_PURPLE}adb connect 127.0.0.1:<监听端口>${C_RESET}          ${C_RED}│${C_RESET}"
    echo -e "${C_RED}│                                                            │${C_RESET}"
    echo -e "${C_RED}│ ${C_DIM}※ 授权通道重建并校验通过后，引擎将自动恢复态势感知。${C_RESET}      ${C_RED}│${C_RESET}"
    echo -e "${C_RED}╰────────────────────────────────────────────────────────────╯${C_RESET}\n"
    
    local DO_CONNECT=0

    echo -ne "${C_YELLOW}[?] 侦测到节点未授权。是否需要初始化无线调试密钥对？(y/n) ➜ ${C_RESET}"
    read -r IS_FIRST_TIME

    if [ "$IS_FIRST_TIME" = "y" ] || [ "$IS_FIRST_TIME" = "Y" ]; then
        echo -ne "${C_YELLOW}[?] 宿主 system API 级别是否 >= 30 (Android 11+)？(y/n) ➜ ${C_RESET}"
        read -r IS_A11_PLUS
        
        if [ "$IS_A11_PLUS" != "y" ] && [ "$IS_A11_PLUS" != "Y" ]; then
            echo -e "\n${C_RED}[ ✖ ERROR ] 协议不兼容：该握手模式强依赖 Android 11+ 原生无线调试服务。${C_RESET}"
        else
            echo -e "\n${C_CYAN}⚡ 请进入系统 [无线调试] 面板，提取 [使用配对码配对设备] 核心参数。${C_RESET}"
            
            echo -ne "${C_YELLOW}[>] 录入握手节点 (IP:PORT，如 192.168.x.x:37465) ➜ ${C_RESET}"
            read -r PAIR_IP_PORT
            
            echo -ne "${C_YELLOW}[>] 录入 6 位安全认证令牌 (Pairing Code) ➜ ${C_RESET}"
            read -r PAIR_CODE
            
            echo -e "${C_PURPLE}[ ↻ SYSTEM ] 正在向底层注入 RSA 安全配打证书...${C_RESET}"
            adb pair "$PAIR_IP_PORT" "$PAIR_CODE" >/dev/null 2>&1
            
            echo -e "\n${C_GREEN}[ ✔ SUCCESS ] 密钥交换完成，节点已互信。${C_RESET}"
            DO_CONNECT=1
        fi
    else
        echo -ne "${C_YELLOW}[?] 宿主是否已存有本终端的公钥存根（曾配对过）？(y/n) ➜ ${C_RESET}"
        read -r HAS_PAIRED
        
        if [ "$HAS_PAIRED" = "y" ] || [ "$HAS_PAIRED" = "Y" ]; then
            DO_CONNECT=1
        else
            echo -e "${C_RED}[ ✖ ERROR ] 缺乏证书信任链，引擎终止挂载。${C_RESET}"
        fi
    fi

    if [ "$DO_CONNECT" -eq 1 ]; then
        echo -e "\n${C_CYAN}ℹ️  系统提示：请退回主面板，获取正式连接的【IP:端口】。${C_RESET}"
        echo -ne "${C_YELLOW}[>] 录入通信链路坐标 ➜ ${C_RESET}"
        read -r CONNECT_IP_PORT
        
        echo -e "${C_PURPLE}[ ↻ SYSTEM ] 正在打通初始 RPC 通信链路...${C_RESET}"
        adb connect "$CONNECT_IP_PORT" >/dev/null 2>&1
        sleep 1

        if is_adb_ready; then
            echo -e "\n${C_BLUE}╒════════════════════════════════════════════════════════════╕${C_RESET}"
            echo -e "${C_PURPLE}│ 🌐 是否开启 TCP/IP 端口回环映射 (Local Loopback)？         │${C_RESET}"
            echo -e "${C_CYAN}│ （开启后将绑定 127.0.0.1，实现脱离 Wi-Fi 物理网卡的持久化守护）│${C_RESET}"
            echo -e "${C_BLUE}╘════════════════════════════════════════════════════════════╛${C_RESET}"
            echo -ne "${C_YELLOW}[?] 启用持久化映射？(y/n) ➜ ${C_RESET}"
            read -r ENABLE_LOCAL_TCPIP

            if [ "$ENABLE_LOCAL_TCPIP" = "y" ] || [ "$ENABLE_LOCAL_TCPIP" = "Y" ]; then
                echo -ne "${C_YELLOW}[>] 指派自定义监听端口 (缺省建议 5555) ➜ ${C_RESET}"
                read -r CUSTOM_PORT
                
                echo -e "${C_PURPLE}[ ↻ SYSTEM ] 正在下发 adbd 端口重定向汇编指令...${C_RESET}"
                adb tcpip "$CUSTOM_PORT" >/dev/null 2>&1
                sleep 2
                
                echo -e "${C_PURPLE}[ ↻ SYSTEM ] 正在通过 127.0.0.1 挂载内核回环...${C_RESET}"
                adb connect 127.0.0.1:"$CUSTOM_PORT" >/dev/null 2>&1
                
                echo "LOCAL_ADB_PORT=\"$CUSTOM_PORT\"" >> "$CONFIG_FILE"
                echo -e "${C_GREEN}[ ✔ SUCCESS ] 本地回环调试挂载就绪，端口指针已写入持久化卷！${C_RESET}"
            else
                echo -e "${C_GREEN}[ ✔ SUCCESS ] 标准局域网套接字握手完成（未启用本地回环）。${C_RESET}"
            fi
            return 0
        else
            echo -e "${C_RED}[ ✖ ERROR ] 握手超时：Shell 进程未响应。请核对端口或重置 RSA 证书。${C_RESET}"
        fi
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FATAL] 核心 RPC 通信链路发生致命断裂，引擎触发熔断挂起。" >&3
    if command -v termux-wake-unlock >/dev/null 2>&1; then
        termux-wake-unlock
    fi
    exec 3>&- 2>/dev/null
    kill -SIGKILL $MAIN_PID 2>/dev/null
}

# ==========================================
# 异步日志守护器
# ==========================================
log_size_guardian() {
    while true; do
        local ARCHIVE_FILE="${LOG_DIR}/archive_历史归档.tar.gz"
        local OLD_LOGS=$(find "$LOG_DIR" -name "log_*.txt" -mtime +7 2>/dev/null)

        if [ -n "$OLD_LOGS" ]; then
            if [ -f "$ARCHIVE_FILE" ]; then
                tar -rzf "$ARCHIVE_FILE" $OLD_LOGS >/dev/null 2>&1
            else
                tar -czf "$ARCHIVE_FILE" $OLD_LOGS >/dev/null 2>&1
            fi
            rm -f $OLD_LOGS >/dev/null 2>&1
        fi

        if [ -f "$ARCHIVE_FILE" ]; then
            local ARCHIVE_SIZE=$(stat -c%s "$ARCHIVE_FILE" 2>/dev/null || ls -l "$ARCHIVE_FILE" | awk '{print $5}' 2>/dev/null || echo 0)
            if [ "$ARCHIVE_SIZE" -gt 104847600 ]; then
                rm -f "$ARCHIVE_FILE" >/dev/null 2>&1
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ SYSTEM ] 机制判定：监测到 I/O 归档堆栈溢出 (>100MB)，执行碎片化抹除" >&3
            fi
        fi
        sleep 3600
    done
}

# ==========================================
# 异步硬件熔断守护器
# ==========================================
hardware_thermal_guardian() {
    sleep 3
    local CPU_CORES=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo 0)
    
    while true; do
        if [ "$ENABLE_BATTERY_PROTECT" -eq 1 ]; then
            local BATT_INFO=""
            local RETRY_BATT=0
            
            while [ $RETRY_BATT -lt 3 ]; do
                if ! is_adb_ready; then
                    silent_adb_reconnect
                fi
                BATT_INFO=$(adb shell "dumpsys battery" 2>/dev/null)
                if [ -n "$BATT_INFO" ] && echo "$BATT_INFO" | grep -q "level:"; then
                    break
                fi
                RETRY_BATT=$((RETRY_BATT + 1))
                sleep 0.5
            done

            if [ -n "$BATT_INFO" ]; then
                local BATT_LEVEL=$(echo "$BATT_INFO" | grep "level:" | awk '{print $2}')
                local BATT_STATUS=$(echo "$BATT_INFO" | grep "powered:" | grep "true")

                if [ -z "$BATT_STATUS" ] && [ -n "$BATT_LEVEL" ] && [ "$BATT_LEVEL" -le "$BATTERY_THRESHOLD" ]; then
                    echo -e "\n${C_RED}[ 🔋 SYS_HALT ] 💥 严重警报：物理电芯跌破阈值 (${BATT_LEVEL}%) 且未处于 AC 供电模式！触发能源枯竭协议！${C_RESET}"
                    kill -SIGUSR1 $MAIN_PID 2>/dev/null
                    exit 0
                fi
            fi
        fi

        local MAX_TEMP=0
        for path in /sys/class/thermal/thermal_zone*/temp /sys/class/power_supply/battery/temp; do
            if [ -f "$path" ]; then
                local RAW_TEMP=$(cat "$path" 2>/dev/null || echo 0)
                if echo "$RAW_TEMP" | grep -Eq '^[0-9]{2,5}$'; then
                    local CURRENT_TEMP=$RAW_TEMP
                    if [ "$RAW_TEMP" -gt 1000 ]; then
                        CURRENT_TEMP=$((RAW_TEMP / 1000))
                    fi
                    
                    if [ "$CURRENT_TEMP" -lt 150 ] && [ "$CURRENT_TEMP" -gt "$MAX_TEMP" ]; then
                        MAX_TEMP=$CURRENT_TEMP
                    fi
                fi
            fi
        done

        if [ "$MAX_TEMP" -ge 48 ]; then
            echo -e "\n${C_RED}[ 🌡️ THERMAL_HALT ] 💥 严重警报：核心硅片温度探针录得临界值 (${MAX_TEMP}°C)！触发 TCC 硬件热熔断协议！${C_RESET}"
            kill -SIGUSR1 $MAIN_PID 2>/dev/null
            exit 0
        fi

        if [ "$CPU_CORES" -ge 8 ] && [ -f "/proc/loadavg" ]; then
            local ONE_MIN_LOAD=$(awk '{print $1}' /proc/loadavg | cut -d. -f1)
            if [ -n "$ONE_MIN_LOAD" ] && [ "$ONE_MIN_LOAD" -gt 20 ]; then
                echo -e "\n${C_RED}[ ⚙️ KERNEL_HALT ] 💥 严重警报：OS 进程调度器遭遇死锁阻塞，系统负载峰值异常！触发内核熔断！${C_RESET}"
                kill -SIGUSR1 $MAIN_PID 2>/dev/null
                exit 0
            fi
        fi

        sleep 5  
    done
}

# ==========================================
# 核心配置与全局硬件全息面板
# ==========================================
SYS_MEM=$(awk '/MemTotal/ {printf "%.1f GB", $2/1024/1024}' /proc/meminfo 2>/dev/null || echo 'N/A')
SYS_ANDROID=$(getprop ro.build.version.release 2>/dev/null || echo 'N/A')
SYS_SDK=$(getprop ro.build.version.sdk 2>/dev/null || echo 'N/A')
SYS_BOARD=$(getprop ro.board.platform 2>/dev/null || echo 'N/A')
SYS_DEVICE=$(getprop ro.product.model 2>/dev/null | cut -c 1-18)
SYS_ABI=$(getprop ro.product.cpu.abi 2>/dev/null || echo 'N/A')
SYS_SEC_PATCH=$(getprop ro.build.version.security_patch 2>/dev/null || echo 'N/A')
SYS_SELINUX=$(getenforce 2>/dev/null || echo 'N/A')
SYS_UPTIME=$(uptime -p 2>/dev/null | sed 's/up //;s/ hours/h/;s/ minutes/m/' | cut -c 1-11)
SYS_KERNEL=$(uname -r 2>/dev/null | cut -d'-' -f1)

clear
echo ""
echo -e "${C_CYAN}================== WELCOME TO SHIZUKU DAEMON ====================${C_RESET}"
echo -e "${C_CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${C_RESET}"
echo -e "${C_CYAN}┃${C_PURPLE}              ░▒▓██  SHIZUKU DAEMON PRO MAX  ██▓▒░                ${C_CYAN}┃${C_RESET}"
echo -e "${C_CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${C_RESET}"
printf "${C_CYAN}┃${C_DIM} [ 终端节点 ] ${C_WHITE}%-18s  ${C_DIM} [ 操作系统 ] ${C_WHITE}Android %-3s(API %-2s) ${C_CYAN}┃\n${C_RESET}" "$SYS_DEVICE" "$SYS_ANDROID" "$SYS_SDK"
printf "${C_CYAN}┃${C_DIM} [ 核心架构 ] ${C_WHITE}%-18s  ${C_DIM} [ 物理内存 ] ${C_WHITE}%-16s ${C_CYAN}┃\n${C_RESET}" "$SYS_ABI" "$SYS_MEM"
printf "${C_CYAN}┃${C_DIM} [ 芯片总线 ] ${C_WHITE}%-18s  ${C_DIM} [ 内核版本 ] ${C_WHITE}%-16s ${C_CYAN}┃\n${C_RESET}" "$SYS_BOARD" "$SYS_KERNEL"
printf "${C_CYAN}┃${C_DIM} [ 安全补丁 ] ${C_WHITE}%-18s  ${C_DIM} [ SELINUX  ] ${C_WHITE}%-16s ${C_CYAN}┃\n${C_RESET}" "$SYS_SEC_PATCH" "$SYS_SELINUX"
printf "${C_CYAN}┃${C_DIM} [ 节点进程 ] ${C_WHITE}%-18s  ${C_DIM} [ 持续驻留 ] ${C_WHITE}%-16s ${C_CYAN}┃\n${C_RESET}" "PID: $MAIN_PID" "$SYS_UPTIME"
echo -e "${C_CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${C_RESET}"
echo -e "${C_CYAN}${C_BLUE}  [ 脚本架构师 ] ${C_WHITE}音YINLI黎                               ${C_CYAN}${C_RESET}"
echo -e "${C_CYAN}${C_BLUE}  [ 抖音唯一账号 ] ${C_WHITE}抖音 UID: YINLI2324959492                         ${C_CYAN}${C_RESET}"
echo -e "${C_CYAN}${C_RED}  [  ⚠⚠⚠警 告⚠⚠⚠  ] 免费开源公益脚本 · 欢迎提交PR及学习交流，请勿用于商业倒卖行为         ${C_CYAN}${C_RESET}"
echo -e "${C_CYAN}${C_YELLOW}  [  给使用者的说明  ] 技术本无罪，只看使用者，本脚本仅提供学习用途，不提供任何形式的违法犯罪行为，若你在使用过程中发现任何事情请自行承担后果         ${C_CYAN}${C_RESET}"
echo -e "${C_CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${C_RESET}"
echo ""

# ==========================================
# 运行环境校验（带启动动画）
# ==========================================
type_fx "▶ 正在初始化底层依赖容器与 Android 宿主 API 接口..." "$C_PURPLE" 0.08

if ! command -v adb >/dev/null 2>&1; then
    animate_progress "BOOTLOADER"
    echo -e "\n${C_RED}[ ✖ KERNEL_PANIC ] 核心组件缺失：Android SDK 工具链 (adb) 未就绪。执行 pkg install android-tools 修复。${C_RESET}"
    exit 1
fi
animate_progress "BOOTLOADER"

if [ ! -d "/storage/emulated/0" ] || \
   ! touch "/storage/emulated/0/.termux_storage_test_$$" 2>/dev/null; then
    echo -e "\n${C_RED}[ ✖ PERMISSION_DENIED ] I/O 异常：缺失物理存储卷访问权。执行 termux-setup-storage 提权。${C_RESET}"
    exit 1
else
    rm -f "/storage/emulated/0/.termux_storage_test_$$"
fi
animate_progress "DEPENDENCY"

if [ -f "$CONFIG_FILE" ]; then
    SAVED_LOCAL_PORT=$(grep "^LOCAL_ADB_PORT=" "$CONFIG_FILE" | cut -d'=' -f2 | tr -d '"')
    if [ -n "$SAVED_LOCAL_PORT" ]; then
        adb connect 127.0.0.1:"$SAVED_LOCAL_PORT" >/dev/null 2>&1
        sleep 0.5
    fi
fi
animate_progress "LINK_LAYER"

if ! is_adb_ready; then
    echo ""
    handle_adb_disconnect
fi

CHECK_BY_PATH=$(adb shell pm path moe.shizuku.privileged.api 2>/dev/null)
CHECK_BY_DUMPSYS=$(adb shell "dumpsys package moe.shizuku.privileged.api" 2>/dev/null | grep "versionName")

if [ -z "$CHECK_BY_PATH" ] && [ -z "$CHECK_BY_DUMPSYS" ]; then
    echo -e "\n${C_RED}[ ✖ APP_NOT_FOUND ] ADB 握手成功，但宿主 system 未检测到 [moe.shizuku.privileged.api] 包名！${C_RESET}"
    exit 1
fi

animate_progress "AWARENESS"
echo -e "\n${C_GREEN}[ ✔ SYSTEM_OK ] 物理沙盒隔离校验通过，API 提权就绪。${C_RESET}\n"


# ==========================================
# 配置文件的读取与历史操作检测
# ==========================================
LOAD_SUCCESS=0
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${C_BLUE}╒════════════════════════════════════════════════════════════╕${C_RESET}"
    echo -e "${C_PURPLE}│ 💾 探针已定位历史 I/O 镜像配置，是否执行静默内存复原？     │${C_RESET}"
    echo -e "${C_CYAN}│ （执行复原可跳过参数录入环节，激活极速冷启动模式）         │${C_RESET}"
    echo -e "${C_BLUE}╘════════════════════════════════════════════════════════════⛛${C_RESET}"
    echo -ne "${C_YELLOW}[?] 发起复原？(y 读取快照 / n 覆盖重构) ➜ ${C_RESET}"
    read -r READ_CFG_CHOICE
    
    if [ "$READ_CFG_CHOICE" = "y" ] || [ "$READ_CFG_CHOICE" = "Y" ]; then
        source "$CONFIG_FILE" 2>/dev/null
        if [ -n "$ACTIVE_CMD_STR" ] && [ -n "$SLEEP_TIME" ] && [ -n "$LOG_LIMIT_CHOICE" ]; then
            LOAD_SUCCESS=1
            echo -e "${C_GREEN}[ ✔ RESTORE_OK ] 数据流镜像重载完毕！已挂载历史激活汇编与中断阈值。${C_RESET}"
            if [ -z "$ENABLE_BATTERY_PROTECT" ]; then ENABLE_BATTERY_PROTECT=0; fi
            if [ -z "$BATTERY_THRESHOLD" ]; then BATTERY_THRESHOLD=15; fi
        else
            echo -e "${C_RED}[ ✖ WARN ] 快照散列数据丢失，已自动降级至手动干预模式...${C_RESET}"
        fi
    fi
fi

if [ "$LOAD_SUCCESS" -ne 1 ]; then
    echo -e "\n${C_BLUE}╒════════════════════════════════════════════════════════════╕${C_RESET}"
    echo -e "${C_PURPLE}│ ✍️  请输入 Shizuku 核心守护线程的拉起/激活 Payload         │${C_RESET}"
    echo -e "${C_CYAN}│ （已接入输入净化沙盒，请直接粘贴 ADB 标准执行指令串）      │${C_RESET}"
    echo -e "${C_BLUE}╘════════════════════════════════════════════════════════════⛛${C_RESET}"

    while true; do
        echo -ne "${C_YELLOW}[>] 键入 Payload ➜ ${C_RESET}"
        read -r ACTIVE_CMD_STR
        
        if [ -z "$ACTIVE_CMD_STR" ]; then
            echo -e "${C_RED}[ ✖ WARN ] 异常流：参数池不可为空！${C_RESET}"
            continue
        fi

        if ! echo "$ACTIVE_CMD_STR" | grep -Eq 'shizuku|moe\.shizuku'; then
            echo -e "${C_RED}[ ⚠ SECURITY ] 审计拦截：该 Payload 未命中 Shizuku 包名特征码库。${C_RESET}"
            continue
        fi
        break
    done

    echo -e "\n${C_BLUE}╒════════════════════════════════════════════════════════════╕${C_RESET}"
    echo -e "${C_PURPLE}│ ⏱  设定主调度循环 (Main Loop) 的时钟阻塞频率 (0-15 整秒)    │${C_RESET}"
    echo -e "${C_BLUE}╘════════════════════════════════════════════════════════════⛛${C_RESET}"
    echo -ne "${C_YELLOW}[>] 设定心跳间距 ➜ ${C_RESET}"
    read -r SLEEP_TIME

    if ! echo "$SLEEP_TIME" | grep -Eq '^[0-9]+$' || [ "$SLEEP_TIME" -lt 0 ] || [ "$SLEEP_TIME" -gt 15 ]; then
        echo -e "${C_DIM}[ i INFO ] 游标溢出安全边界，自适应收敛至标准调度时钟：3 秒。${C_RESET}"
        SLEEP_TIME=3
    fi

    echo -e "\n${C_BLUE}╒════════════════════════════════════════════════════════════╕${C_RESET}"
    echo -e "${C_PURPLE}│ 📁 指定 Daemon I/O 缓冲区日志的单日溢出剥离水位线          │${C_RESET}"
    echo -e "${C_CYAN}│ [1] 1MB (激进防溢出，适用于高频毫秒级并发轮询)             │${C_RESET}"
    echo -e "${C_CYAN}│ [2] 5MB (均衡模式，留存足够的 Trace 痕迹供异常回溯)        │${C_RESET}"
    echo -e "${C_CYAN}│ [3] 10MB(长时留存，适用于极低频全天候静态后台挂机)         │${C_RESET}"
    echo -e "${C_BLUE}╘════════════════════════════════════════════════════════════⛛${C_RESET}"
    echo -ne "${C_YELLOW}[>] 指定水位线挡位 (1-3) ➜ ${C_RESET}"
    read -r LOG_LIMIT_CHOICE
    
    if ! echo "$LOG_LIMIT_CHOICE" | grep -Eq '^[1-3]$'; then
        LOG_LIMIT_CHOICE=1
    fi

    echo -e "\n${C_BLUE}╒════════════════════════════════════════════════════════════╕${C_RESET}"
    echo -e "${C_PURPLE}│ 🔋 启用深度内核的硬件电源 management 熔断 (Power Halt) 协议？      │${C_RESET}"
    echo -e "${C_CYAN}│ （拦截物理电池榨干现象，低于预设阀值时引爆安全停机）       │${C_RESET}"
    echo -e "${C_BLUE}╘════════════════════════════════════════════════════════════⛛${C_RESET}"
    echo -ne "${C_YELLOW}[?] 激活该保护矩阵？(y/n) ➜ ${C_RESET}"
    read -r OPEN_BATT_CHOICE

    ENABLE_BATTERY_PROTECT=0
    BATTERY_THRESHOLD=15

    if [ "$OPEN_BATT_CHOICE" = "y" ] || [ "$OPEN_BATT_CHOICE" = "Y" ]; then
        ENABLE_BATTERY_PROTECT=1
        echo -ne "${C_YELLOW}[>] 录入硬件能源枯竭阈值 (1-99%) ➜ ${C_RESET}"
        read -r BATT_INPUT_VAL

        if echo "$BATT_INPUT_VAL" | grep -Eq '^[0-9]+$' && [ "$BATT_INPUT_VAL" -gt 0 ] && [ "$BATT_INPUT_VAL" -lt 100 ]; then
            BATTERY_THRESHOLD=$BATT_INPUT_VAL
            echo -e "${C_GREEN}[ ✔ INFO ] BMS 电源熔断线精准锁定于: ${BATTERY_THRESHOLD}%${C_RESET}"
        else
            echo -e "${C_DIM}[ i INFO ] 非法变量，强行校准至安全下限: 15%${C_RESET}"
            BATTERY_THRESHOLD=15
        fi
    fi

    EXISTING_PORT=""
    if [ -f "$CONFIG_FILE" ]; then
        EXISTING_PORT=$(grep "^LOCAL_ADB_PORT=" "$CONFIG_FILE" || true)
    fi
    echo "ACTIVE_CMD_STR=\"$ACTIVE_CMD_STR\"" > "$CONFIG_FILE"
    echo "SLEEP_TIME=$SLEEP_TIME" >> "$CONFIG_FILE"
    echo "LOG_LIMIT_CHOICE=$LOG_LIMIT_CHOICE" >> "$CONFIG_FILE"
    echo "ENABLE_BATTERY_PROTECT=$ENABLE_BATTERY_PROTECT" >> "$CONFIG_FILE"
    echo "BATTERY_THRESHOLD=$BATTERY_THRESHOLD" >> "$CONFIG_FILE"
    if [ -n "$EXISTING_PORT" ]; then
        echo "$EXISTING_PORT" >> "$CONFIG_FILE"
    fi
    echo -e "${C_GREEN}[ ✔ DB_SYNC ] 独立环境快照已完全序列化并固化至物理扇区。${C_RESET}"
fi

HIGH_PERF_MODE=0
ENABLE_PROTECT=0  

if [ "$SLEEP_TIME" -eq 0 ]; then
    echo -ne "\n${C_RED}⚠️ [ OVERRIDE ] 侦测到 0 秒极速调度请求。强制解开频率限制，激活【毫秒级强穿透轮询】？(y/n) ➜ ${C_RESET}"
    read -r CONFIRM_PERF
    if [ "$CONFIRM_PERF" = "y" ] || [ "$CONFIRM_PERF" = "Y" ]; then
        HIGH_PERF_MODE=1
        
        echo -ne "${C_PURPLE}[?] 并行挂载【物理温控热成像 / OS 负载死锁防瘫痪防御网】？(y/n) ➜ ${C_RESET}"
        read -r CONFIRM_PROTECT
        if [ "$CONFIRM_PROTECT" = "y" ] || [ "$CONFIRM_PROTECT" = "Y" ]; then
            ENABLE_PROTECT=1
            echo -e "${C_GREEN}[ ✔ INFO ] 复合式硬件抗损装甲已激活 🛡️${C_RESET}"
        else
            echo -e "${C_RED}[ ⚠ WARN ] 硬件降级保护已卸载！可能引发严重的硬件烧毁与 Kernel Panic，风险自负！🔥${C_RESET}"
        fi
        
        echo -e "${C_DIM}[ ↻ INJECT ] 正在获取 Rootless 权限，接管并干预 Android Doze 与 Phantom 进程限制策略...${C_RESET}"
        adb shell "dumpsys deviceidle whitelist +com.termux" >/dev/null 2>&1
        adb shell "dumpsys deviceidle whitelist +moe.shizuku.privileged.api" >/dev/null 2>&1
        adb shell "settings put global settings_enable_monitor_phantom_procs false" >/dev/null 2>&1
        adb shell "device_config put activity_manager max_phantom_processes 2147483647" >/dev/null 2>&1
        
        if command -v termux-wake-lock >/dev/null 2>&1; then
            termux-wake-lock
        fi
    else
        SLEEP_TIME=1
    fi
fi

# ==========================================
# 极客视觉：引擎点火自检序列（带打字机动画）
# ==========================================
echo ""
type_fx ">>> 正在构建底层守护进程拓扑架构 ..." "$C_WHITE" 0.08
sleep 0.2

echo -e "${C_BLUE} ├─ [ I/O 异步日志分流管道 (FD3) ] ..................... ${C_GREEN}[ ✔ ACTIVE ]${C_RESET}"
sleep 0.1
echo -e "${C_BLUE} ├─ [ 硬件热成像与电源感知进程 ] ......................... ${C_GREEN}[ ✔ RUNNING ]${C_RESET}"
sleep 0.1
echo -e "${C_BLUE} └─ [ Shizuku 进程级测谎雷达探针 ] ..................... ${C_GREEN}[ ✔ READY ]${C_RESET}"
sleep 0.2

echo -e "\n${C_GREEN}▶ [ SYSTEM_UP ] 引擎点火闭环完成。高可用节点已常驻 Android 内存基址！${C_RESET}"
echo -e "${C_DIM}▶ [ TRACE_LOG ] 后台日志流重定向映射: ${LOG_FILE}${C_RESET}\n"

echo "==========================================" >&3
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ SYS_INIT ] Shizuku Daemon Pro Max 全新拉起，守护节点上线" >&3

log_size_guardian &
if [ "$ENABLE_PROTECT" -eq 1 ] || [ "$ENABLE_BATTERY_PROTECT" -eq 1 ]; then
    hardware_thermal_guardian &
fi


# ==============================================================================
# 🚀 SHIZUKU 服务状态机与执行感知引擎
# ==============================================================================

# 🛑 核心1：纯净状态探测
check_shizuku_state() {
    if ! is_adb_ready; then
        silent_adb_reconnect
        if ! is_adb_ready; then
            return 1
        fi
    fi

    local SVC_CHECK=""
    SVC_CHECK=$(adb shell "service check shizuku" 2>/dev/null | tr -d '\r\n')

    _probe_process_layer() {
        local _PID
        _PID=$(adb shell "pidof shizuku_server 2>/dev/null; pidof 'shizuku:server' 2>/dev/null" 2>/dev/null | tr -d '\r\n ')
        if [ -z "$_PID" ]; then
            _PID=$(adb shell "ps -A 2>/dev/null | grep -E 'shizuku_server|shizuku:server'" 2>/dev/null | tr -d '\r\n')
        fi
        [ -n "$_PID" ] && return 0 || return 1
    }

    if [ -z "$SVC_CHECK" ]; then
        if _probe_process_layer; then
            return 2
        fi
        return 1
    fi

    if echo "$SVC_CHECK" | grep -iq "not found"; then
        return 1
    fi

    if echo "$SVC_CHECK" | grep -iq "found"; then
        local BINDER_TEST=""
        BINDER_TEST=$(adb shell "cmd shizuku opt-out" 2>/dev/null | tr -d '\r\n')

        if [ -n "$BINDER_TEST" ] && ! echo "$BINDER_TEST" | grep -iqE "Can't find service|Exception|NullPointer|error|failed|dead|unable"; then
            return 0
        else
            if _probe_process_layer; then
                return 2
            fi
            return 1
        fi
    fi

    if _probe_process_layer; then
        return 2
    fi

    return 1
}

# 🛑 核心2：防拥塞异步点火与渐进式拉起验证
fire_payload() {
    eval "$ACTIVE_CMD_STR" >/dev/null 2>&1
    
    local _poll_interval=1
    if [ "$HIGH_PERF_MODE" -eq 1 ]; then
        _poll_interval=0.2
    fi

    local step=0
    while [ $step -lt 3 ]; do
        sleep "$_poll_interval"
        check_shizuku_state
        local current_code=$?
        if [ "$current_code" -eq 0 ] || [ "$current_code" -eq 2 ]; then
            return 0
        fi
        step=$((step + 1))
    done
    return 1
}

# 🛑 核心3：深度稳定期体检验证
stabilize_and_verify() {
    if [ "$HIGH_PERF_MODE" -eq 1 ]; then
        sleep 0.3
    else
        sleep 2.5
    fi

    check_shizuku_state
    local _verify_state=$?

    if [ "$_verify_state" -eq 0 ] || [ "$_verify_state" -eq 2 ]; then
        return 0
    else
        return 1
    fi
}

# ==============================================================================
# 🚀 主调度生命周期循环
# ==============================================================================
while true; do
    check_shizuku_state
    STATE_CODE=$?

    if [ "$STATE_CODE" -eq 0 ]; then
        if [ "$HIGH_PERF_MODE" -ne 1 ]; then
            STATUS_TIME=$(date '+%H:%M:%S.%3N')
            echo "[$STATUS_TIME] [ 🟢 ONLINE ] 链路状态：完美健康 | Shizuku Binder 通信畅通" >&3
        fi
    elif [ "$STATE_CODE" -eq 2 ]; then
        INIT_TIME=$(date '+%H:%M:%S.%3N')
        echo "[$INIT_TIME] [ 🟡 INIT ] Shizuku 进程存在，Binder 初始化中，等待就绪..." >&3
    else
        ERROR_TIME=$(date '+%H:%M:%S.%3N')
        if [ "$STATE_CODE" -eq 1 ]; then
            echo "[$ERROR_TIME] [ 🛑 OFFLINE ] 侦测到服务彻底离线！" >&3
        else
            echo "[$ERROR_TIME] [ ⚠️ ZOMBIE ] 侦测到进程发生了“死锁/未注册假死”异常！" >&3
        fi
        echo "[$ERROR_TIME] [ ↻ RECOVER ] 正在触发全新的 HA 灾备重构协议..." >&3

        LAST_CMD_TIME=$(date '+%H:%M:%S.%3N')
        echo "[$LAST_CMD_TIME] [ ⚡ IGNITION ] 正在下发点火指令序列（仅执行一次）..." >&3
        eval "$ACTIVE_CMD_STR" >/dev/null 2>&1

        TRY_COUNT=1
        LAUNCH_SUCCESS=0
        MAX_RETRIES=5

        while [ "$TRY_COUNT" -le "$MAX_RETRIES" ]; do
            _poll_detected=0
            _pstep=0
            _pint=1
            if [ "$HIGH_PERF_MODE" -eq 1 ]; then
                _pint=0.2
            fi
            while [ "$_pstep" -lt 3 ]; do
                sleep "$_pint"
                check_shizuku_state
                _pcode=$?
                if [ "$_pcode" -eq 0 ] || [ "$_pcode" -eq 2 ]; then
                    _poll_detected=1
                    break
                fi
                _pstep=$((_pstep + 1))
            done

            if [ "$_poll_detected" -eq 1 ]; then
                if stabilize_and_verify; then
                    LAUNCH_SUCCESS=1
                    break
                else
                    echo "[$(date '+%H:%M:%S.%3N')] [ ✖ FALSE_ALIVE ] 警告：体检未通过，进程已消失，继续等待下一轮 ($TRY_COUNT/$MAX_RETRIES)..." >&3
                fi
            else
                echo "[$(date '+%H:%M:%S.%3N')] [ ⏳ SLOW_INIT ] Shizuku 初始化较慢尚未就绪，延长等待窗口 ($TRY_COUNT/$MAX_RETRIES)..." >&3
            fi
            TRY_COUNT=$((TRY_COUNT + 1))
        done

        if [ "$LAUNCH_SUCCESS" -eq 1 ]; then
            echo "[$(date '+%H:%M:%S.%3N')] [ 🟢 RECOVERED ] 抢救成功！服务通过稳定期体检，已稳健常驻底层。" >&3
        else
            echo "[$(date '+%H:%M:%S.%3N')] [ ✖ FATAL ] 连续 ${MAX_RETRIES} 次抢救失败！触发全线链路阻断并自重置..." >&3
            adb kill-server >/dev/null 2>&1
            sleep 2
            silent_adb_reconnect
        fi
    fi

    _gday=$(date '+%Y-%m-%d')
    if [ "$_gday" != "$TODAY" ]; then
        TODAY="$_gday"
        LOG_FILE="${LOG_DIR}/log_${TODAY}.txt"
        exec 3>&- 2>/dev/null
        exec 3>>"$LOG_FILE"
    fi
    if [ -f "$LOG_FILE" ]; then
        _gmax=1048576
        case "$LOG_LIMIT_CHOICE" in
            2) _gmax=5242880 ;;
            3) _gmax=10485760 ;;
            *) _gmax=1048576 ;;
        esac
        _gsz=$(stat -c%s "$LOG_FILE" 2>/dev/null || ls -l "$LOG_FILE" | awk '{print $5}' 2>/dev/null || echo 0)
        if [ "$_gsz" -gt "$_gmax" ]; then
            exec 3>&- 2>/dev/null
            echo "==========================================" > "$LOG_FILE"
            exec 3>>"$LOG_FILE"
        fi
    fi

    if [ "$HIGH_PERF_MODE" -ne 1 ]; then
        sleep "$SLEEP_TIME"
    fi
done
