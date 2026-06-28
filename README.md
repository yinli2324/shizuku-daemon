![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-orange.svg)
<div align="center">
  <img src="./logo.png" alt="Project Logo" width="200"/>
  <h1>Shizuku进程守护脚本</h1>
  <p><mark>保姆级使用教程 · 音YINLI黎制作</mark></p>
    </div>

  ---
  

## 🔗 Termux与Shizuku官方仓库

> **为了方便大家查找官方仓库和解决环境问题，这里直接提供官方仓库的跳转链接：**

| 工具 | 官方仓库 |
| :--- | :--- |
| **<img src="./Termux.png" width="16"/> Termux** | [termux/termux-app](https://github.com/termux/termux-app) |
| **<img src="./shizuku.png" width="16"/> Shizuku** | [RikkaApps/Shizuku](https://github.com/RikkaApps/Shizuku) |

---

## 🛠️ Termux与Shizuku环境准备

>在开始使用前，请确保你的设备已准备好以下环境，并确保安卓版本大于或等于Android11。本板块提供了直接复制粘贴即可使用的指令（如果你想偷懒就下滑到快捷偷懒板块）。

### 1. Termux 初始配置与存储授权

>打开 Termux 应用，依次复制并执行以下指令：

# 授予 Termux 访问手机内部存储的权限（必须执行）
```bash
termux-setup-storage
```

# 更新包管理器并安装 ADB 工具
```bash
pkg update && pkg upgrade -y && pkg install android-tools -y
```

# 若你觉得下载太慢可切换到镜像源后再下载（以清华大学镜像源为例）
```bash
sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/apt/termux-main stable main@' $PREFIX/etc/apt/sources.list && pkg update && pkg upgrade -y
```

# 移动脚本到shizuku私有目录（以默认内部存储目录为例）
```bash
mv  ~/storage/shared/shizuku_daemon.sh ~
```
> **如果你不确定你脚本保存在哪里可以先用[MT管理器](http://mt2.cn/)定位文件所在位置，然后直接用『 MT管理器 』移动到Termux私有目录即可**

### 2. ADB 无线调试与授权

> **确保你的手机已连接WiFi并开启了开发者选项与无线调试（以下操作请把Termux用小窗打开并且已经进入开发者选项里的无线调试界面确保配对不会出错）**

# 1. 点使用配对码完成配对，进入配对模式后，输入 IP 地址和配对端口进行配对
```bash
adb pair IP地址:端口号
```
> **然后下方会让你输入配对码，你把你看到的6位数配对码输入进去按回车就行**

# 2. 配对成功后，连接 ADB 服务
```bash
adb connect IP地址:端口号
```

# 3. 自定义TCP端口号（端口设置范围1024-65535）

> **无WiFi使用的办法，可做可不做（设置了TCP端口以后可以直接用`adb connect 127.0.0.1:端口号`或者`adb connect localhost:端口号`连接ADB服务）**

```bash
adb tcpip 端口号
```


# 3. 脚本运行准备（脚本发布在[Releases](https://github.com/yinli2324/shizuku-daemon/releases/)里）

> **下载脚本👉[shizuku进程守护脚本](https://github.com/yinli2324/shizuku-daemon/releases/)**

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

## 非必要但建议
> ***不想每次都搞这么麻烦？是不是想偷懒，没问题，帮你解决***

### 在`Termux`里输入这个指令添加配置文件

```bash
nano ~/.bashrc
```

### 然后复制粘贴这个指令
```bash
adb connect IP地址:端口号
bash shizuku_daemon.sh
```
> ***IP地址和端口号请修改为你自己的，如果已经设置了TCP端口，IP地址可以改成`127.0.0.1`***

> ***然后`Ctrl+O`保存，回车确定，`Ctrl+X`退出***

> ***这样每次打开`Termux`的时候就会自动开启脚本啦***

## 快捷偷懒
> **你还真是个小懒虫，居然真跑到这来了，不过，既然你都来了，那我就给你提供偷懒的办法**

> **首先，你先下载我提供的【脚本】[点击下载](https://github.com/yinli2324/shizuku-daemon/releases/tag/v1.0.1)termux_setup.sh和shizuku_daemon.sh都要下载**

> **然后确定文件所在位置并记住一会要用，不确定可以用『 [MT管理器](http://mt2.cn/) 』 定位文件所在位置**

### ***然后打开你的Termux，先给管理所有文件权限***
```bash
termux-setup-storage
```
### ***然后给脚本可执行权限***

### 方案一
> **这里以默认的内部存储目录为例，请根据实际情况自行修改路径**
```bash
chmod +x /storage/emulated/0/Documents/termux_setup.sh && chmod +x /storage/emulated/0/Documents/shizuku_daemon.sh
```

### ***然后执行脚本文件***
> **注：进入ADB配对时请把Termux弄成小窗并保证已开启开发者选项和已进入无线调试配对，初始配对时请点击使用配对码完成配对，然后把IP地址和端口号填进去，下面会让你输入6位数的配对码，你把你看到的配对码输入进去就算配对成功了，然后会让你再次输入IP地址和端口号，这次的IP地址和端口号是你这个界面里默认的那一个，然后会问你是否设置TCP端口，这个的作用是可以让你在无WiFi的情况下仍然可以使用脚本，范围我也给你定好了，完成全部配对以后脚本就到此结束了**
```bash
sh /storage/emulated/0/Documents/termux_setup.sh
```
### 方案二
> **使用『 MT管理器 』把 `termux_setup.sh` 和 `shizuku_daemon` 移动到Termux的私有目录里**
> **然后给脚本可执行权限**
```bash
chmod +x termux_setup.sh && chmod +x shizuku_daemon.sh
```
> **最后执行脚本，操作方法跟方案一的注意事项一样**
```bash
./termux_setup.sh
```
> **初始配置搞完以后就可以进行下一步了，运行shizuku进程守护脚本**
```bash
./shizuku_daemon.sh
```
> **或者***
```bash
bash shizuku_daemon.sh
```

---

## 🌟 核心特性

> ***本项目旨在为 Android 玩机爱好者提供一个稳定、高效的 Shizuku 进程守护脚本，主要作用是保证shizuku能保持服务运行状态，当ADB服务进程掉线的时候自动复活省去手动激活的麻烦。***

---

## 📢 关于作者

<p align="center">
  <img src="./YINLI.png" alt="Author Avatar" width="100"/>
  
  <div align="center"><strong>音YINLI黎</strong></div>
  <div align="center"><strong>一个安卓玩机与数码科技爱好者</strong></div>
  <div align="center"><strong>抖音号：YINLI2324959492</strong></div>
  
  
> ***制作不易，搬运必究。***

本脚本由 ***音YINLI黎*** 制作开发。如果你觉得这个项目对你有帮助，欢迎关注我的抖音号，获取更多玩机教程与资源：

*   👤 ***抖音号***：[音YINLI黎 UID：YINLI2324959492](https://v.douyin.com/ONvBHrHbCGo/)
*   🐧***QQ号***：[༺❀ൢ音༒黎ൢ❀༻ QQ：2324959492](https://qm.qq.com/q/raoEUmkrbG)
*   🌐 ***个人网站***：[音黎资源网：https://yinlitoolbox.me/](https://yinlitoolbox.me/)
*   💬 ***安卓玩机交流群***：[抖音群：918840653195](https://v.douyin.com/group/918840653195)

> **⚠️ 版权警告**：
本仓库的所有代码和资源均受版权保护。**严禁**任何个人或组织未经授权将此脚本用于商业售卖、打包进付费工具箱或营销牟利。**严禁**私自逆向破解、篡改作者署名进行倒卖的行为，我们将保留追究其法律责任的权利。

---

## ⚠️ 免责声明

>**请在运行本脚本前仔细阅读以下条款：**
>1.  **风险自担**：本脚本涉及 `adb shell dumpsys`、`device_config` 等底层系统级干预操作，运行即视为您已了解并接受所有潜在风险。
>2.  **设备损坏**：作者不对因使用本脚本导致的任何设备损坏、数据丢失、电池异常、系统变砖、保修失效等后果承担任何责任。
>3.  **无担保承诺**：本软件按“原样”提供，不提供任何明示或暗示的担保，包括但不限于适销性和特定用途的适用性。
>4.  **合法使用**：技术本无罪，责任在使用者。若您将本脚本用于任何违反所在地法律法规的场景，一切后果由您自行承担。

---

<details>
<summary><b>这里啥也没有，千万别点</b></summary>
<h1>好吧，你还是点进来了</h1>
<p>这是我意想不到的结果，你居然能看完我整个发布说明并且点进来这个不起眼的小东西</p>
<h2>作者的一些心里话</h2>
<p>谢谢你能看完我整个README.md发布说明，说实话，这个项目是我实际花了半年时间制作，去年开始就有这个想法，因为我也是一个安卓玩机爱好者，但shizuku时不时抽疯掉线真的很烦，于是我就在想有没有什么办法可以解决这个问题，所以我开始研究这个项目，但本人对代码编程不是很熟，所以这个脚本有问题有bug是正常的，嗯，就说这么多吧，再次感谢你能看到这里--音YINLI黎</p>
</details>

---

<details>
<summary><b>支持作者</b></summary>
<div align="center"><strong><mark>谢谢老板的支持</mark></strong></div>
  <img src="./0000.png" alt="Project Logo" width="520"/>
  <div align="center"><strong><mark>未成年人禁止打赏</mark></strong></div>


