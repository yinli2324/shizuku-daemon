![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-orange.svg)
<div align="center">
  <img src="./logo.png" alt="Project Logo" width="200"/>
  <h1>Shizuku进程守护脚本</h1>
  <p><mark>保姆级使用教程 · 音YINLI黎制作</mark></p>
    </div>

  ---
  

## 🔗 Termux与Shizuku官方仓库

>为了方便大家查找官方仓库和解决环境问题，这里直接提供官方仓库的跳转链接：

| 工具 | 官方仓库 |
| :--- | :--- |
| **<img src="./Termux.png" width="16"/> Termux** | [termux/termux-app](https://github.com/termux/termux-app) |
| **<img src="./shizuku.png" width="16"/> Shizuku** | [RikkaApps/Shizuku](https://github.com/RikkaApps/Shizuku) |

---

## 🛠️ Termux与Shizuku环境准备

>在开始使用前，请确保你的设备已准备好以下环境，并确保安卓版本大于或等于Android11。本板块提供了直接复制粘贴即可使用的指令。

### 1. Termux 初始配置与存储授权

>打开 Termux 应用，依次复制并执行以下指令：

# 授予 Termux 访问手机内部存储的权限（必须执行）
```bash
termux-setup-storage
```

# 更新包管理器并安装 ADB 工具
```bash
pkg update && pkg upgrade -y pkg install android-tools -y
```

# 若你觉得下载太慢可切换到镜像源后再下载（以清华大学镜像源为例）
```bash
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main@' $PREFIX/etc/apt/sources.list && pkg update && pkg upgrade -y
```

# 移动脚本到shizuku私有目录（以默认内部存储目录为例）
```bash
mv  ~/storage/shared/shizuku_daemon.sh ~
```
>**如果你不确定你脚本保存在哪里可以先用[MT管理器](http://mt2.cn/)定位文件所在位置，然后直接用『 MT管理器 』移动到Termux私有目录即可**

### 2. ADB 无线调试与授权

>确保你的手机已连接WiFi并开启了开发者选项与无线调试（以下操作请把Termux用小窗打开确保配对不会出错）

# 1. 点使用配对码完成配对，进入配对模式后，输入 IP 地址和配对端口进行配对
```bash
adb pair IP地址:端口号
```
> 然后下方会让你输入配对码

# 2. 配对成功后，连接 ADB 服务
```bash
adb connect IP地址:端口号
```

# 3. 自定义TCP端口号（范围1024-65535）
```bash
adb tcpip 端口号
```


# 3. 脚本运行准备

## 方案一

### 赋予脚本执行权限
```bash
chmod +x shizuku_daemon.sh
```

### 执行脚本
```bash
./shizuku_daemon.sh
```
## 方案二

### 直接用bash执行
```bash
bash shizuku_daemon.sh
```

> 💡 **提示**：以上步骤只需在首次使用时完整执行一次。之后每次使用只需输入`adb connect IP地址:端口号`，然后直接运行 `./shizuku_daemon.sh`
 或者`bash shizuku_daemon.sh`即可。


---

## 🌟 核心特性

>本项目旨在为 Android 玩机爱好者提供一个稳定、高效的 Shizuku 进程守护脚本，主要作用是保证shizuku能保持服务运行状态，当ADB服务进程掉线的时候自动复活省去手动激活的麻烦。

---

## 📢 关于作者

<p align="center">
  <img src="./YINLI.png" alt="Author Avatar" width="100"/>
  
  <h>脚本开发者：音YINLI黎</h>
  <p>抖音号：YINLI2324959492</p>
  
  
> **制作不易，搬运必究。**

本脚本由 **音YINLI黎** 制作开发。如果你觉得这个项目对你有帮助，欢迎关注我的抖音号，获取更多玩机教程与资源：

*   👤 **抖音号**：[音YINLI黎](https://v.douyin.com/ONvBHrHbCGo/)
*   🐧**QQ号**：[2324959492](https://qm.qq.com/q/raoEUmkrbG)
*   🌐 **个人网站**：[音黎资源网](https://yinlitoolbox.me/)
*   💬 **安卓玩机交流群**：[抖音群](https://v.douyin.com/group/918840653195)

>**⚠️ 版权警告**：
本仓库的所有代码和资源均受版权保护。**严禁**任何个人或组织未经授权将此脚本用于商业售卖、打包进付费工具箱或营销牟利。**严禁**私自逆向破解、篡改作者署名进行倒卖的行为，我们将保留追究其法律责任的权利。

---

## ⚠️ 免责声明

>**请在运行本脚本前仔细阅读以下条款：**
>1.  **风险自担**：本脚本涉及 `adb shell dumpsys`、`device_config` 等底层系统级干预操作，运行即视为您已了解并接受所有潜在风险。
>2.  **设备损坏**：作者不对因使用本脚本导致的任何设备损坏、数据丢失、电池异常、系统变砖、保修失效等后果承担任何责任。
>3.  **无担保承诺**：本软件按“原样”提供，不提供任何明示或暗示的担保，包括但不限于适销性和特定用途的适用性。
>4.  **合法使用**：技术本无罪，责任在使用者。若您将本脚本用于任何违反所在地法律法规的场景，一切后果由您自行承担。
