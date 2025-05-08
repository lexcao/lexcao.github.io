---
title: 折腾：HomeKit 接入蓝牙吸顶灯
date: 2025-04-26
tags: [蓝牙, HomeKit, Home Assistant, ESPHome]
---

## 一、缘起：一个“丐版”吸顶灯的智能化挑战

最近给家里客厅换了个新吸顶灯。这灯不仅能用遥控器，还能用手机 App 控制，感觉挺智能的。然而，美中不足的是，它竟然不支持接入米家或者 HomeKit。
搜索后才发现，原来同品牌更贵版本是支持米家控制的，而我买的这个乞丐版不支持，大概价差 100 元左右。

作为一个爱折腾的程序员，我立马开启了第一性原理思考模式：既然它能通过手机 App 控制，通过打开 App 时申请蓝牙权限可以推断是通过蓝牙进行通信。既然是蓝牙控制，那理论上就能通过别的蓝牙程序来控制它，进而接入智能家居生态。对，没错，肯定行！

【注意】想要着手操作一番的朋友，可以参考我的另一篇博文：[教程：让你的不智能蓝牙灯接入 HomeKit 智能家居](./integrate-bluetooth-lamp-into-homekit-step-by-step)

{{<video name="remoter_control_lamp">}}
{{<video name="app_control_lamp">}}

## 二、探索：Home Assistant 与蓝牙控制方案

于是乎，我兴冲冲地开始了我的折腾之旅，进行了大量的搜索尝试。既然直接接入米家此路不通，那曲线救国呢？我灵机一动，开始搜索如何将米家设备接入 HomeKit。
这一搜让我打开了一个新世界的大门 —— Home Assistant (HA)！

- [Home Assistant](https://www.home-assistant.io/)
> Open source home automation that puts local control and privacy first. Powered by a worldwide community of tinkerers and DIY enthusiasts.
> 以本地控制和隐私为先的开源家庭自动化。由全球工匠和 DIY 爱好者社区提供支持。

顺藤摸瓜，我又发现 Home Assistant 竟然有个叫 HomeKit Bridge 的组件，能把各种非 HomeKit 设备桥接到 HomeKit。看到这里，我仿佛看到了曙光！

继续在 Home Assistant 的社区里搜索，感谢万能的网友，挖到了一个宝藏项目：`ha-ble-adv`！看名字就知道，这玩意儿跟蓝牙有关，简直是为我量身定做的！

- Home Assistant Bluetooth Low Energy Advertisement
- Home Assistant 蓝牙低功耗广播
- [HA Custom Integration to control BLE ADV Ceiling Fans / Lamps](https://community.home-assistant.io/t/ha-custom-integration-to-control-ble-adv-ceiling-fans-lamps/866888/1)
- [Integration of Bluetooth controlled ceiling lamp](https://community.home-assistant.io/t/integration-of-bluetooth-controlled-ceiling-lamp/372969/1)
- [Convert a “smart” chinese lamp to a real smart lamp](https://community.home-assistant.io/t/convert-a-smart-chinese-lamp-to-a-real-smart-lamp/560607/1)
- [Controlling BLE ceiling light with HA](https://community.home-assistant.io/t/controlling-ble-ceiling-light-with-ha/520612/1)

此时，我的脑海中已经浮现出一副蓝图：
1. 通过 `ha-ble-adv` 控制蓝牙灯。
2. 通过 Home Assistant 控制 `ha-ble-adv`。
3. 通过 Home Assistant 的 Home Bridge 接入 HomeKit。

{{<image name="ha-ble-adv-arch01" >}}

## 三、实践：Docker 环境下的重重阻碍

理论可行，开始实践！我踏上了从零开始折腾 Home Assistant 的旅程。根据文档一路过关斩将：
1. 安装 Home Assistant。
2. 安装 Home Assistant 社区商店（HACS）。
3. 通过 HACS 安装 `ha-ble-adv`。

一切似乎都那么顺利，然而，当我打开 `ha-ble-adv` 准备连接蓝牙灯时，遇到了第一个障碍：**找不到蓝牙适配器**。
通过大量搜索，我发现 Docker 部署的 Home Assistant 是无法使用宿主机的蓝牙设备。网络上相关的教程文章大多针对 Linux 环境。
直到找到一篇文章描述到：
> Easiest way to handle bluetooth (basically regardless of how you're running HA) is to use an ESPHome BT proxy. Spend $5 on a ESP32, flash the BT proxy firmware, and you magically have bluetooth connectivity wherever you place your ESP(s)
> -- Reddit: [Is bluetooth possible for docker in Mac?](https://www.reddit.com/r/homeassistant/comments/1hpyhlq/is_bluetooth_possible_for_docker_in_mac/)

翻译过来是：
> 处理蓝牙的最简单方法（基本上与运行 HA 的方式无关）是使用 ESPHome BT 代理。花 5 美元买一个 ESP32，刷入 BT 代理固件，然后无论你把 ESP 放在哪里，都能神奇地实现蓝牙连接。

另外，`ha-ble-adv` 本身也不支持 macOS 原生蓝牙设备，详情可以看这个 [issue](https://github.com/NicoIIT/ha-ble-adv/discussions/33)。

既然最简单的方式是使用 ESP32，那么我便着手购买。网上随便选了一个 ESP32 板子，花费 25 元。

一天后，ESP32 板子到手。

{{<image name="esp32" >}}

### 3.1 ESP32 初体验：Wi-Fi 连接难题

接下来开始进入折腾之旅第二章：配置 ESP32。
查阅 `ha-ble-adv` 文档，发现其更推荐使用 `esphome-ble_adv_proxy` 作为蓝牙代理。

{{<image name="ha-ble-adv-arch02" >}}

由于是第一次接触 ESP32 板子，我并没有多想，严格按照文档指引，一步步攻克：
1. 安装 ESPHome：用于 ESP32 的快速配置和与 Home Assistant 的无缝集成。
2. 连接 ESP32 板子：在 ESPHome 中添加新设备。
3. 刷入 `ble_adv_proxy` 组件：为 ESP32 板子烧录 ESPHome 的 `ble_adv_proxy` 固件。

然而，第二个障碍出现了：**板子接上后一直处于离线状态**。
再次投入到 ESPHome 的相关文档中，经过一番搜索，发现问题可能出在安装时填写的 Wi-Fi 信息上——原来，大部分 ESP32 型号仅支持 2.4GHz 频段的 Wi-Fi。
调整了 Wi-Fi 设置后，问题迎刃而解。

ESP32 成功接入 `ble_adv_proxy` 的过程还算顺利。当打开 ESP32 的 Debug 网页，看到它开始接收到周围的蓝牙信号时，心中还是涌起了一阵小小的成就感。

{{<image name="esp32-debug-page" >}}

### 3.2 Home Assistant 集成 ESP32：mDNS 的"坑"

回到主线任务：将 ESPHome 接入 Home Assistant，这样 `ha-ble-adv` 就能利用 `ble_adv_proxy` 来收发蓝牙消息了。

根据 ESPHome 的文档，如果网络配置正确，Home Assistant 应该能自动发现 ESP32 设备。
但事与愿违，第三个障碍出现了：**ESP32 添加失败**。
由于我的配置存在问题，自动发现并未成功。尝试手动添加，输入 ESP32 的 `.local` 地址，也无法连接。
我开始排查：既然 ESP32 的 `.local` 地址无法识别，那直接使用 IP 地址是否可行？
考虑到我使用 Docker 部署 Home Assistant，容器内可能无法正确解析 ESP32 的 `.local` 地址。于是，我在 Home Assistant 的 Docker 配置中添加了 `extra_hosts`，实现容器内的手动 DNS 解析：
```
    extra_hosts:
    - "esp32.local:192.168.50.66" # 将 esp32.local 指向其 IP 地址
```

后话：其实，这里未能自动发现设备，已经暗示了更深层次的问题——服务自发现协议 mDNS 没有正常工作。这是 Docker 环境下部署 Home Assistant 时常见的一个坑，也为后续的一系列问题埋下了伏笔。可以说，之后遇到的所有麻烦，基本都与 mDNS 失效有关。

重启 Home Assistant 后，尝试通过 ESP32 的 `.local` 地址再次添加，设备成功连接！看来手动配置 DNS 解析确实有效。

### 3.3 `ha-ble-adv` 配置风波

添加成功后，`ha-ble-adv` 终于能够识别到 ESP32 这个蓝牙适配器了。
然而，就在我准备进一步配置时，第四个障碍又不期而至：**`ha-ble-adv` 的配置页面无法打开**。
查看 Debug 日志，发现了一个 Python 代码报错。经过一番排查，依旧未能定位问题。
无奈之下，我决定向项目作者提个 [issue](https://github.com/NicoIIT/ha-ble-adv/discussions/30) 求助。
幸运的是，作者在一天后就快速响应，并修复了该报错。

更新 `ha-ble-adv` 后，我终于成功进入了配置页面。按照指引，顺利配置好了我的蓝牙吸顶灯。
至此，第一个重要的里程碑达成：成功通过 ESP32 这个第三方蓝牙设备控制了吸顶灯！
也就是说，我现在已经可以用 Home Assistant 来控制灯的开关和亮度了。

## 四、终极挑战：HomeKit Bridge 集成难题

胜利在望，接下来就是最后一步：添加 HomeKit Bridge，将这个灯接入苹果的 HomeKit 生态。
我原以为这会是最简单的一步，只需在 Home Assistant 中启用 HomeKit Bridge 组件，然后在家庭 App 中添加即可。
万万没想到，最后一个，也是最折磨人的障碍出现了：**HomeKit Bridge 无法添加到 HomeKit**。这个问题足足困扰了我三天。

我开始了又一轮大量的搜索，查阅各种社区帖子和官方文档，希望能找到解决方案。
根据各方线索，问题逐渐指向网络层面。我尝试检查和调整了以下几个方面：
- Docker 的 `network_mode` 设置
- mDNS 相关的网络配置
- HomeKit 对网络环境的要求
- Wi-Fi 网络设置

甚至尝试了重装 Home Assistant，把之前的整个流程重新走了一遍，但问题依旧。
我开始采用控制变量法，不断调整 Docker 部署 Home Assistant 的各项配置，希望能找到症结所在。
在搜索过程中，我发现许多用户都报告了在 Docker 环境下运行 Home Assistant 时遇到各种网络问题，尤其是与 mDNS 和 HomeKit 相关的。

## 五、柳暗花明：告别 Docker，拥抱原生

这时，一个大胆的想法萌生了：Docker 就是最大的变量，可以尝试去掉！
我决定直接在我的 macOS 上原生部署 Home Assistant！然后，把之前的全部流程在 macOS 环境下重走一遍。
奇迹发生了：
1. MacOS 宿主机的蓝牙适配器被 Home Assistant 自动识别并成功启用了。
2. ESP32 通过 ESPHome 连接后，也被 Home Assistant 自动发现了。

一步步重复之前的安装和配置，每一步都比在 Docker 环境下更加顺畅，结果也更符合预期。这给了我极大的信心，感觉这次真的要成功了！
终于，到了最后一步——添加 HomeKit Bridge 到 HomeKit。这一次，一切都如丝般顺滑，成功了！🎉

现在，我终于可以通过 iPhone 上的"家庭" App，甚至直接用 Siri 来控制我的吸顶灯了！开关灯、调节亮度，一切都随心所欲。

{{<video name="home_control_lamp">}}
{{<video name="hey_siri_关灯">}}

## 六、总结与感悟

回顾整个过程，虽然充满波折，但最终凭借一块小小的 ESP32（成本仅 25 元），我不但成功地将这个"非智能"的吸顶灯接入了 HomeKit，还省下了购买原装米家版灯具的 150多元差价。这波折腾，不仅技术上有所收获，经济上也相当划算，成就感满满！
更重要的是，这次经历也让我再次实践了从第一性原理出发思考和解决问题的能力。整个过程虽然艰辛，但结果令人愉悦。特此记录下这段经历，以作分享。
