---
title: 教程：让你的不智能蓝牙灯接入 HomeKit 智能家居
date: 2025-04-26
tags: [蓝牙, HomeKit, Home Assistant, ESPHome, 教程]
---

# 引言

如果你有一个蓝牙灯，并且它能够被以下几个手机应用控制：
- LampSmart Pro
- Lamp Smart Pro - Soft Lighting / Smart Lighting
- FanLamp Pro
- Zhi Jia
- Zhi Guang
- ApplianceSmart
- Vmax smart
- Zhi Mei Deng Kong

那么恭喜你，你可以跟随本篇教程，一步一步将它接入 HomeKit 智能家居。
来实现通过 iPhone 家庭应用控制以及 Siri 语音控制。
对于实现后的效果，可以看我另一篇博文：[折腾：HomeKit 接入蓝牙吸顶灯](./integrate-bluetooth-lamp-into-homekit)

非常感谢 https://github.com/NicoIIT/ha-ble-adv/，本篇教程实际是从零接入该项目。

## 开始之前

在开始之前，需要一点点基础的计算机知识，确保满足以下条件：
- 熟悉 Home Assistant 概念和一些基本操作，可以阅读官方文档快速熟悉；
- 能够使用 Terminal 命令行工具；
- 已安装 Docker 并且可用；
- 有一个 GitHub 帐号；
- **关键：一块 ESP32 开发板**；
  - 主要用于蓝牙通信，如果没有的话，可以网购一块，25 元左右的价格；
  - （未来会研究如何直接使用系统自带的蓝牙）；

## 教程方式

本教程以 MacOS 为例。如果你使用 Linux 或 Windows，部分操作可能需要稍作调整。
教程的每个步骤会说明：**要做什么**、**怎么做**、以及**验证结果**。请确保完成验证后再进行下一步。遇到问题时，可以参考自查攻略（部分步骤有）或联系我。

# 如何实现

对于实现不感兴趣的，可以跳转到[下一部分](#Step1)

## 组件列表

- [Home Assistant (HA)](https://www.home-assistant.io/)
- [Home Assistant Community Store (HACS)](https://hacs.xyz/)
- **[ha-ble-adv](https://github.com/NicoIIT/ha-ble-adv/)**
    - 缩写是 Home Assistant Bluetooth Low Energy Advertise
    - 翻译为 Home Assistant 蓝牙低功耗广播
- [ESP Home](https://esphome.io/)
- [esphome-ble-adv-proxy](https://github.com/NicoIIT/esphome-ble_adv_proxy)
- ESP32

## 组件交互

1. 核心是使用 `ha-ble-adv` 通过蓝牙与设备交互，控制开关和亮度
2. 通过 Home Assistant 提供的 HomeKit Bridge 连接到 iPhone 家庭应用，来实现控制
3. 要让 Home Assistant 成功使用上 `ha-ble-adv` 需要具备以下条件：
   1. 通过 `HACS` 安装组件 `ha-ble-adv`
   2. 通过 ESP Home 在 ESP32 上面安装 `esphome-ble-adv-proxy` 以供 `ha-ble-adv` 发送和接收蓝牙信息

以下是整体架构图

{{<image name="ha-ble-adv-arch02">}}


话不多说，让我们开始吧。基于上面的实现，为了教程的连贯性，让我们从 ESP32 开始。

首先创建一个目录存放本次用到的所有组件。
```shell
$ mkdir Home-Assistant
$ cd Home-Assistant
```

# 第一部分： ESP Home <a name="Step1" />

## 安装 ESP Home

### 要做什么

使用 Docker 安装 ESP Home。
当然，可以访问 [官方文档](https://esphome.io/guides/getting_started_command_line#bonus-esphome-device-builder) 获取更多安装方式。

### 怎么做

1. 使用以下 Docker compose 文件

```yml
# Home-Assistant/docker-compose.yml
services:
  esphome:
    container_name: esphome
    image: ghcr.io/esphome/esphome
    volumes:
      - ./esphome/config:/config
      - /etc/localtime:/etc/localtime:ro
    restart: always
    privileged: true
    network_mode: host
```

2. 启动运行

```shell
$ docker compose up -d
```

### 结果验证

在浏览器访问 [http://localhost:6052](http://localhost:6052) 能够进入 ESP Home 后台。

遇到问题请参考 [官方文档](https://esphome.io/guides/getting_started_command_line#installation)。

## 连接 ESP32

### 要做什么

添加 ESP32 到 ESP Home 进行管理，用于后续安装组件。

### 怎么做

1. 将你的 ESP32 设备通过有线连接到 MacOS
2. 在 ESP Home 后台添加设备，设置一个名字，比如 `esp32-ble-adv-proxy`
3. 选择 ESP32 连接的串口
4. 输入 Wi-Fi 信息（SSID & Password）
   - **重要：确保连接 2.4G Wi-Fi**
5. 开始安装，选择 Plug into this computer
6. 等待 2 分钟以上，安装完毕

### 结果验证

- 安装完成后会有提示
- 关闭提示后可以在后台看到刚才添加的设备是在线状态（ONLINE）
- 点击 LOGS 可以查看到相关日志

### 遇到问题

- 无法安装？等待大于 2 分钟以上，检查安装过程中页面上面文案是否有变化
- 安装后设备不在线？
  - 检查 Wi-Fi 信息是否正确
  - 检查是否连接的是 2.4G Wi-Fi

## 安装 `esphome-ble-adv-proxy`

### 要做什么

在 ESP Home 后台为刚连接的 ESP32 设备安装社区组件 `esphome-ble_adv_proxy`。

当然，可以访问 [esphome-ble_adv_proxy](https://github.com/NicoIIT/esphome-ble_adv_proxy) 获取详细安装说明。

### 怎么做

1. 在 ESP Home 后台对设备 `esp32-ble-adv-proxy` 点击 Edit
2. 编辑如下信息

```yaml
(...)

esp32:
  board: esp32dev # Or your specific board model
  framework:
    type: esp-idf # Recommended for BLE stability

# Enable ESP32 Bluetooth Low Energy Tracker
esp32_ble_tracker:
  scan_parameters:
    # Active scanning can discover more devices but uses more power
    active: true

# Enable standard Home Assistant Bluetooth Proxy
bluetooth_proxy:
  active: true

# Define the external component source for ble_adv_proxy
external_components:
  - source: github://NicoIIT/esphome-ble_adv_proxy

# Enable the ble_adv_proxy component
ble_adv_proxy:
  # No specific configuration needed here unless specified by component docs

(...)
```

3. 点击保存（Save），点击安装（Install），选择无线安装（Wireless）
4. 等待 2 分钟以上，安装完毕

### 结果验证

- 选择无线安装以后，可以实时查看安装进度
- 安装完成后，点击新出现的 VISIT 按钮，会跳转到调试页面，观察页面是否有数据产生
- **注意：当前页面地址 `http://esp32-ble-adv-proxy.local`**

遇到问题？可以根据安装日志提示寻找相关解决方案。

至此，ESP32 部分准备完成，让我们回到主线 Home Assistant。

# 第二部分： Home Assistant

## 安装 Home Assistant
### 要做什么

通过 python 直接在 MacOS 主机上面安装 Home Assistant Core。
**注意：本教程对于在 Docker 内运行的 Home Assistant 无法成功**，详见下面 [Q&A](#QA)

当然，可以访问 [官方文档](https://www.home-assistant.io/installation/macos#install-home-assistant-core) 获取更多安装说明。

### 怎么做

1. 初始化 python 环境

```shell
$ python3 -m venv .
$ source ./bin/activate
```

2. 安装 `homeassistant` Core

```shell
$ pip3 install homeassistant==2025.4.4
```

3. 创建一个配置目录
```shell
$ mkdir config
```

4. 启动
```
hass --config config
```

### 结果验证

- 在浏览器访问 [http://localhost:8123](http://localhost:8123) 能够进入 Home Assistant 后台
- 创建帐号，完成首次登录流程

遇到问题请参考 [官方文档](https://www.home-assistant.io/installation/macos#install-home-assistant-core)。

## 接入 ESP32
### 要做什么
在 Home Assistant 后台添加上面 ESP32 集成。

### 怎么做

如果之前的步骤一切顺利的话，在 Home Assistant 完成安装后，会自发现 ESP32 设备，点击添加即可。
如果没有自发现，我们仍然可以手动添加：
1. 在 `Settings > Devices & Services` 点击 ADD INTEGRATION 搜索 ESP Home 进行添加
2. 输入上面的地址 `esp32-ble-adv-proxy.local`
3. 点击添加
4. 回到 ESP Home 复制 `esp32-ble-adv-proxy` API Key 完成集成


### 结果验证

- 在 Home Assistant `Devices & Services` 页面显示添加成功的 ESP32 设备和蓝牙

### 遇到问题

- 手动添加失败？
  - 检查 [http://esp32-ble-adv-proxy.local](http://esp32-ble-adv-proxy.local) 是否可以访问
  - 检查 ESP Home 是否运行
- 找不到 API Key
  - 在 ESP Home 设备卡片，点击 ··· 按钮，点击 Show API Key
- 更多帮助可以查看 [官方文档](https://esphome.io/guides/getting_started_hassio)

## 安装 Home Assistant Community Store  
### 要做什么
在 Home Assistant 后台安装 HACS 集成
当然，可以访问 [官方文档](https://hacs.xyz/) 获取更多安装说明。

### 怎么做

1. 确保 `wget` 是可用的
2. 在命令行执行安装命令
```shell
$ wget -O - https://get.hacs.xyz | bash -
```
3. 重启 Home Assistant
4. 在 `Settings > Devices & Services` 点击 ADD INTEGRATION 搜索 HACS 进行添加
5. 根据指引完成 GitHub 帐号授权
6. 安装完成

### 结果验证

- 在 Home Assistant 后台导航菜单可以看到 HACS

遇到问题？请参考 [官方文档](https://hacs.xyz/docs/use/configuration/basic/) 完成配置

## 安装 `ha-ble-adv`
### 要做什么

通过 HACS 安装自定义仓库 `ha-ble-adv`

### 怎么做

1. 进入 Home Assistant，进入 HACS
2. 点击 ··· 右上角 > `Custom respositories`
3. 根据指引安装 `https://github.com/NicoIIT/ha-ble-adv`

### 结果验证

- 安装成功
- 在 `Settings > Devices & Services` 点击 ADD INTEGRATION 能够搜索到 BLE ADV

遇到问题？请参考 [官方文档](https://hacs.xyz/docs/use/repositories/dashboard/) 安装自定义仓库指引

## 添加 蓝牙灯 设备
### 要做什么

添加 `ha-ble-adv` 蓝牙灯设备集成

### 怎么做

1. 在 `Settings > Devices & Services` 点击 ADD INTEGRATION 搜索 BLE ADV 进行添加
2. 根据指引进行添加，推荐选择 Duplicate Paired Phone App Config

### 结果验证

- 添加成功
- 在 Overview 可以通过 Home Assistant 直接控制蓝牙灯

### 遇到问题

- 无法打开安装指引？
  - 需要手动加载 `ble-adv` 组件
  - 打开 `config/configurations.yml` 进行编辑，在最后一行添加
```yml
# config/configurations.yml
...
ble_adv:
```
  - 重启 Home Assistant， 重新添加
- 无法接收到蓝牙信息？
  - 请确保前面 ESP32 在 EPS Home 是在线状态
  - 可以通过访问 [http://esp32-ble-adv-proxy.local](http://esp32-ble-adv-proxy.local) 来检查
- 其他问题？可以参考 [FAQ](https://github.com/NicoIIT/ha-ble-adv?tab=readme-ov-file#faq) 来排查

## 接入 HomeKit Bridge

截止上一步，我们实现了通过 Home Assistant 控制蓝牙来控制蓝牙灯。
接下来，我们进入最后一步，接入 HomeKit Bridge 来接入家庭应用。

### 要做什么

通过 HomeKit Bridge 接入家庭应用。
当然，可以访问 [官方文档](https://www.home-assistant.io/integrations/homekit) 获取更多安装说明。

### 怎么做

1. 在 `Settings > Devices & Services` 点击 ADD INTEGRATION 搜索 Apple 点击后添加 HomeKit Bridge
2. 这里无需额外配置，直接点击下一步即可
3. 完成添加后，打开左下角 Notification
4. iPhone 打开家庭应用，扫描二维码添加设备
5. 扫描成功后会弹窗 未认证配件，点击 仍要添加 完成配置

### 结果验证

- 蓝牙灯控制出现在 iPhone 家庭应用
- 可以通过 家庭应用 / Siri 控制 灯 开关和灯光

### 遇到问题

在最后一步遇到的问题会多一些，以下是我遇到的问题，排查思路和解决方案。

**扫码后无法添加，提示 找不到设备？**

主要是网络问题引起，请依次检查：

排查一：排查本机 mDNS 是否正常工作：

【操作步骤】

- 在命令行执行以下命令

```shell
$ dns-sd -B _hap._tcp local
```

【结果验证】

如果返回以下信息，说明本机 mDNS 没问题，注意右边 Instance Name 含有 HASS Bridge
```shell
Timestamp     A/R    Flags  if Domain     Service Type     Instance Name
 0:29:39.244  Add        3  10 local.     _hap._tcp.       HASS Bridge xxxxxx
```

【解决方式一】

1. 打开 Debug 日志，打开 `config/configurations.yml` 进行编辑，在最后一行添加 
```yml
logger:
  default: warning
  logs:
    homeassistant.components.homekit: debug
    pyhap: debug
```
2. 重启 Home Assistant
3. 重新扫码添加设备到家庭应用
4. 观察是否有异常日志
5. 根据日志报错搜索相关解决方案

【解决方式二】

- 若使用 Docker 启动 Home Assistant，改为直接安装 Home Assistant 到本机。

排查二：排查手机 mDNS 是否正常工作：

【操作步骤】
1. 在 Apple Store 搜索 Discovery - DNS-SD Browser
2. 安装后打开，检查 local 域

【结果验证】

- 检查是否存在 `_hap._tcp`
- 点击查看，是否存在 `HASS Bridge xxxxxx`
- 如果存在，说明手机 mDNS 通信在同一个网络下没问题

【解决方式一】

- 检查手机和运行 Home Assistant 的 MacOS 是否在同一个网络下

【解决方式二】

- 检查 MacOS 防火墙配置，是否有禁止端口：
  - HomeKit Bridge `21063`
  - mDNS `5353`

【解决方式三】

- 检查路由器配置，是否禁用 mDNS

**其他问题？**

以下是我在排查问题中找到的一些有用的文章，希望能对你有启发：
- [Offcial: HomeKit Troubleshooting](https://www.home-assistant.io/integrations/homekit#troubleshooting)
- [Community: HomeKit Bridge on Home Assistant in Docker](https://community.home-assistant.io/t/guide-homekit-bridge-on-home-assistant-in-docker-nanopi-r6s-friendlywrt-possibly-openwrt/775006)
- [Community: Use HomeKit Component inside Docker](https://community.home-assistant.io/t/using-homekit-component-inside-docker/45409)
- [Reddit: Troubleshooting HomeKit What Tools to Use and How](https://www.reddit.com/r/HomeKit/comments/a3iwwj/troubleshooting_homekit_what_tools_to_use_and_how/)
- [GitHub issue: Homekit not working with docker](https://github.com/home-assistant/core/issues/15692)
- [GitHub gist: Home Assistant Docker on MacOS](https://gist.github.com/dieu/96cded47544ee48ce0b3c69d529b723c)

## Enjoy！

太好了，大功告成！开始享用家庭应用控制蓝牙灯吧。

# 总结

本教程详细介绍了如何将特定的蓝牙灯（如 LampSmart Pro 控制的灯）通过一系列开源工具接入 Apple HomeKit 智能家居系统。我们从准备 ESP32 开发板开始，利用 ESPHome 安装了 `esphome-ble-adv-proxy` 以实现蓝牙通信代理。接着，我们在 MacOS 上安装了 Home Assistant Core，并集成了 ESP32 设备。通过 HACS，我们安装了关键的 `ha-ble-adv` 自定义组件，用于发现和控制蓝牙灯。最后，利用 Home Assistant 内置的 HomeKit Bridge 功能，成功将蓝牙灯设备桥接至 iPhone 的家庭应用，实现了通过家庭 App 和 Siri 进行控制。教程中也涵盖了各个步骤可能遇到的问题及其排查方法，特别是 HomeKit 连接时常见的 mDNS 网络问题。遵循本教程，你可以将原本“不智能”的蓝牙设备融入现代智能家居生态。


# 答疑 <a name="QA">

### Q1 是否可以使用 Docker 运行 Home Assistant

可以，但我没有成功，可以参考
- [GitHub gist: Home Assistant Docker on MacOS](https://gist.github.com/dieu/96cded47544ee48ce0b3c69d529b723c)。
- [Community: HomeKit Bridge on Home Assistant in Docker](https://community.home-assistant.io/t/guide-homekit-bridge-on-home-assistant-in-docker-nanopi-r6s-friendlywrt-possibly-openwrt/775006)

使用 Docker 会有什么问题？

- 我遇到的问题是 HomeKit 死活连不上，排查后发现是主机的 mDNS 网络无法探查到 Docker 内部 HomeKit Bridge 网络。就算使用 `network_mode=host` 也不行，我就放弃折腾 Docker，改为安装到本机。

### Q2 是否可以不用 ESP32， 使用 MacOS 自带的蓝牙功能

目前不行，有 2 个原因：

1. 使用 Docker 运行，无法在 Docker 内使用主机的蓝牙功能，最简单的方式是使用 ESP32 代理一下
2. 目前 MacOS 自带的蓝牙功能无法满足 `ble-adv` 功能，可以参考 [作者回复]()

### Q3 本机运行 Home Assistant 脚本

后台运行脚本，创建一个文件 `run.sh`

```shell
#!/bin/bash
source bin/activate
nohup hass --config config > hass.log 2>&1 &
echo "Home Assistant started on: http://localhost:8123"
```

添加执行权限

```shell
$ chmod +x run.sh
```

启动 Home Assistant

```shell
$ ./run.sh
```

查看日志

```shell
tail -f hass.log
```

停止 Home Assistant

```shell
$ pkill -f "hass --config config"
```


# 引用

- [Home Assistant (HA)](https://www.home-assistant.io/)
- [Home Assistant Community Store (HACS)](https://hacs.xyz/)
- [ha-ble-adv](https://github.com/NicoIIT/ha-ble-adv/)
- [ESP Home](https://esphome.io/)
- [esphome-ble-adv-proxy](https://github.com/NicoIIT/esphome-ble_adv_proxy)
- [ESP Home 官方文档 - 安装](https://esphome.io/guides/getting_started_command_line#bonus-esphome-device-builder)
- [ESP Home 官方文档 - 安装问题](https://esphome.io/guides/getting_started_command_line#installation)
- [ESP Home 官方文档 - Home Assistant 集成](https://esphome.io/guides/getting_started_hassio)
- [Home Assistant 官方文档 - MacOS 安装](https://www.home-assistant.io/installation/macos#install-home-assistant-core)
- [Home Assistant 官方文档 - HomeKit 集成](https://www.home-assistant.io/integrations/homekit)
- [Home Assistant 官方文档 - HomeKit Troubleshooting](https://www.home-assistant.io/integrations/homekit#troubleshooting)
- [HACS 官方文档 - 首页](https://hacs.xyz/)
- [HACS 官方文档 - 配置](https://hacs.xyz/docs/use/configuration/basic/)
- [HACS 官方文档 - 自定义仓库](https://hacs.xyz/docs/use/repositories/dashboard/)
- [ha-ble-adv FAQ](https://github.com/NicoIIT/ha-ble-adv?tab=readme-ov-file#faq)
- [Community: HomeKit Bridge on Home Assistant in Docker](https://community.home-assistant.io/t/guide-homekit-bridge-on-home-assistant-in-docker-nanopi-r6s-friendlywrt-possibly-openwrt/775006)
- [Community: Use HomeKit Component inside Docker](https://community.home-assistant.io/t/using-homekit-component-inside-docker/45409)
- [Reddit: Troubleshooting HomeKit What Tools to Use and How](https://www.reddit.com/r/HomeKit/comments/a3iwwj/troubleshooting_homekit_what_tools_to_use_and_how/)
- [GitHub issue: Homekit not working with docker](https://github.com/home-assistant/core/issues/15692)
- [GitHub gist: Home Assistant Docker on MacOS](https://gist.github.com/dieu/96cded47544ee48ce0b3c69d529b723c)
- ESP Home 后台 [http://localhost:6052](http://localhost:6052)
- Home Assistant 后台 [http://localhost:8123](http://localhost:8123)
