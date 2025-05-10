---
title: "Tutorial: Make Your Non-Smart Bluetooth Light Work with HomeKit"
date: 2025-04-27
tags: [Bluetooth, HomeKit, Home Assistant, ESPHome, Tutorial]
---

# Introduction

This tutorial demonstrates how to integrate Bluetooth-enabled lights into Apple's HomeKit ecosystem. The following mobile apps are supported:
- LampSmart Pro
- Lamp Smart Pro - Soft Lighting / Smart Lighting
- FanLamp Pro
- Zhi Jia
- Zhi Guang
- ApplianceSmart
- Vmax smart
- Zhi Mei Deng Kong

By following this guide, you'll be able to control your Bluetooth light through the iPhone Home app and Siri voice commands. For a demonstration of the final implementation, refer to my companion post: [Journal: Integrate Bluetooth Lamp into HomeKit](./integrate-bluetooth-lamp-into-homekit).

This implementation is based on the open-source project [ha-ble-adv](https://github.com/NicoIIT/ha-ble-adv/).

## Prerequisites

Before proceeding, ensure you have:
- Basic understanding of Home Assistant concepts and operations
- Terminal command-line proficiency
- Docker installation
- GitHub account
- **Required Hardware: ESP32 development board**
  - Primary function: Bluetooth communication

## Implementation Overview

This tutorial uses MacOS as the reference environment. Linux and Windows users may need to adjust certain steps accordingly. Each section includes:
- Implementation steps
- Verification procedures
- Troubleshooting guidelines (where applicable)

# Implementation Details

If you're not interested in the technical details, you can skip to [Part 1](#Step1)

## Component List

- [Home Assistant (HA)](https://www.home-assistant.io/)
- [Home Assistant Community Store (HACS)](https://hacs.xyz/)
- **[ha-ble-adv](https://github.com/NicoIIT/ha-ble-adv/)**
    - Home Assistant Bluetooth Low Energy Advertise
- [ESP Home](https://esphome.io/)
- [esphome-ble-adv-proxy](https://github.com/NicoIIT/esphome-ble_adv_proxy)
- ESP32

## System Architecture

1. Core functionality: `ha-ble-adv` handles Bluetooth communication for device control
2. HomeKit integration: Achieved through Home Assistant's HomeKit Bridge
3. Implementation requirements:
   1. `ha-ble-adv` component installation via `HACS`
   2. `esphome-ble-adv-proxy` deployment on ESP32 through ESP Home

System architecture diagram:

{{<image name="ha-ble-adv-arch02">}}

Let's get started. Based on the implementation above, for tutorial continuity, we'll begin with the ESP32.

First, create a directory to store all components we'll use:
```shell
$ mkdir Home-Assistant
$ cd Home-Assistant
```

# Part 1: ESP Home <a name="Step1" />

## Installing ESP Home

### Implementation Steps

Install ESP Home using Docker. For alternative installation methods, refer to the [official documentation](https://esphome.io/guides/getting_started_command_line#bonus-esphome-device-builder).

### Configuration

1. Create a Docker Compose configuration:

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

2. Deploy the service:

```shell
$ docker compose up -d
```

### Verification

Access the ESP Home dashboard at [http://localhost:6052](http://localhost:6052).

For installation issues, refer to the [official documentation](https://esphome.io/guides/getting_started_command_line#installation).

## ESP32 Device Integration

### Implementation Steps

Configure ESP32 in ESP Home for device management.

### Configuration

1. Connect ESP32 to MacOS via USB
2. In the ESP Home dashboard:
   - Add new device
   - Set device name (e.g., `esp32-ble-adv-proxy`)
   - Select ESP32's serial port
   - Configure Wi-Fi credentials
     - **Important: Use 2.4GHz Wi-Fi network**
3. Begin installation:
   - Select "Plug into this computer"
   - Wait for installation completion (minimum 2 minutes)

### Verification

- Installation completion prompt appears
- Device status shows as ONLINE in dashboard
- View device logs through LOGS interface

### Troubleshooting

- Installation timeout:
  - Wait minimum 2 minutes
  - Monitor installation progress
- Device offline:
  - Verify Wi-Fi credentials
  - Confirm 2.4GHz network connection

## Installing `esphome-ble-adv-proxy`

### Implementation Steps

Deploy the community component `esphome-ble_adv_proxy` on the ESP32 device.

For detailed instructions, visit [esphome-ble_adv_proxy](https://github.com/NicoIIT/esphome-ble_adv_proxy).

### Configuration

1. In ESP Home dashboard, select the `esp32-ble-adv-proxy` device
2. Update configuration:

```yaml
(...)

esp32:
  board: esp32dev # Or your specific board model
  framework:
    type: esp-idf # Recommended for BLE stability

# Enable ESP32 Bluetooth Low Energy Tracker
esp32_ble_tracker:
  scan_parameters:
    # Active scanning for enhanced device discovery
    active: true

# Enable Home Assistant Bluetooth Proxy
bluetooth_proxy:
  active: true

# Configure external component source
external_components:
  - source: github://NicoIIT/esphome-ble_adv_proxy

# Initialize ble_adv_proxy component
ble_adv_proxy:
  # Default configuration

(...)
```

3. Save configuration
4. Select wireless installation
5. Wait for installation completion (minimum 2 minutes)

### Verification

- Monitor installation progress in real-time
- Access debug interface at `http://esp32-ble-adv-proxy.local`
- Verify data generation in debug interface

For installation issues, check the installation logs for error messages.

Now that the ESP32 part is ready, let's return to the main Home Assistant setup.

# Part 2: Home Assistant

## Installing Home Assistant

### Implementation Steps

Install Home Assistant Core directly on MacOS using Python. **Note: This implementation is not compatible with Docker-based Home Assistant installations**. See [Q&A](#QA) for details.

For alternative installation methods, refer to the [official documentation](https://www.home-assistant.io/installation/macos#install-home-assistant-core).

### Configuration

1. Initialize Python virtual environment:

```shell
$ python3 -m venv .
$ source ./bin/activate
```

2. Install Home Assistant Core:

```shell
$ pip3 install homeassistant==2025.4.4
```

3. Create configuration directory:
```shell
$ mkdir config
```

4. Launch Home Assistant:
```shell
$ hass --config config
```

### Verification

- Access Home Assistant dashboard at [http://localhost:8123](http://localhost:8123)
- Complete initial account setup

For installation issues, refer to the [official documentation](https://www.home-assistant.io/installation/macos#install-home-assistant-core).

## ESP32 Integration

### Implementation Steps

Add ESP32 device to Home Assistant dashboard.

### Configuration

Home Assistant should automatically discover the ESP32 device. If not, proceed with manual integration:

1. Navigate to `Settings > Devices & Services`
2. Click ADD INTEGRATION
3. Search for ESP Home
4. Enter device address: `esp32-ble-adv-proxy.local`
5. Complete integration using ESP Home API Key

### Verification

- ESP32 device and Bluetooth services appear in `Devices & Services`
- Device status shows as connected

### Troubleshooting

- Integration failure:
  - Verify ESP32 accessibility at [http://esp32-ble-adv-proxy.local](http://esp32-ble-adv-proxy.local)
  - Check ESP Home service status
- API Key retrieval:
  - In ESP Home device card, click ···
  - Select Show API Key

For additional help, refer to the [official documentation](https://esphome.io/guides/getting_started_hassio).

## Home Assistant Community Store Installation

### Implementation Steps

Deploy HACS integration in Home Assistant.

For detailed instructions, visit the [official documentation](https://hacs.xyz/).

### Configuration

1. Ensure `wget` is installed
2. Execute installation command:
```shell
$ wget -O - https://get.hacs.xyz | bash -
```
3. Restart Home Assistant
4. Navigate to `Settings > Devices & Services`
5. Click ADD INTEGRATION
6. Search for HACS
7. Complete GitHub authentication
8. Finalize installation

### Verification

- HACS appears in Home Assistant navigation menu

For configuration issues, refer to the [official documentation](https://hacs.xyz/docs/use/configuration/basic/).

## Installing `ha-ble-adv`

### Implementation Steps

Deploy the custom repository `ha-ble-adv` through HACS.

### Configuration

1. Access Home Assistant HACS interface
2. Click ··· in top-right corner
3. Select `Custom repositories`
4. Add repository: `https://github.com/NicoIIT/ha-ble-adv`

### Verification

- Installation completes successfully
- BLE ADV appears in `Settings > Devices & Services` integration list

For repository installation issues, refer to the [official documentation](https://hacs.xyz/docs/use/repositories/dashboard/).

## Bluetooth Light Integration

### Implementation Steps

Configure `ha-ble-adv` for Bluetooth light control.

### Configuration

1. Navigate to `Settings > Devices & Services`
2. Click ADD INTEGRATION
3. Search for BLE ADV
4. Select "Duplicate Paired Phone App Config"

### Verification

- Integration completes successfully
- Bluetooth light appears in Home Assistant Overview
- Direct control available through Home Assistant interface

### Troubleshooting

- Installation guide inaccessible:
  - Manually load `ble-adv` component
  - Edit `config/configurations.yml`:
```yml
# config/configurations.yml
...
ble_adv:
```
  - Restart Home Assistant
  - Retry integration
- Bluetooth communication issues:
  - Verify ESP32 online status in ESP Home
  - Check debug interface at [http://esp32-ble-adv-proxy.local](http://esp32-ble-adv-proxy.local)
- Additional issues: Refer to [FAQ](https://github.com/NicoIIT/ha-ble-adv?tab=readme-ov-file#faq)

## HomeKit Bridge Integration

### Implementation Steps

Configure HomeKit Bridge for iPhone Home app integration.

For detailed instructions, refer to the [official documentation](https://www.home-assistant.io/integrations/homekit).

### Configuration

1. Navigate to `Settings > Devices & Services`
2. Click ADD INTEGRATION
3. Search for Apple
4. Add HomeKit Bridge
5. Open iPhone Home app
6. Scan QR code from Home Assistant notification
7. Select "Add Anyway" for uncertified accessory

### Verification

- Bluetooth light appears in iPhone Home app
- Control available through Home app and Siri

### Troubleshooting

#### Device Not Found After Scanning

Primary cause: Network configuration issues. Follow these verification steps:

1. Verify mDNS functionality:

```shell
$ dns-sd -B _hap._tcp local
```

Expected output:
```shell
Timestamp     A/R    Flags  if Domain     Service Type     Instance Name
 0:29:39.244  Add        3  10 local.     _hap._tcp.       HASS Bridge xxxxxx
```

2. Enable debug logging:
```yml
logger:
  default: warning
  logs:
    homeassistant.components.homekit: debug
    pyhap: debug
```

3. Restart Home Assistant
4. Retry device addition
5. Check error logs for specific issues

#### Additional Network Verification

1. Install "Discovery - DNS-SD Browser" on iPhone
2. Verify local domain:
   - Check `_hap._tcp` existence
   - Verify `HASS Bridge xxxxxx` presence

#### Network Configuration

1. Verify network connectivity:
   - Ensure iPhone and MacOS on same network
2. Check firewall settings:
   - HomeKit Bridge port: `21063`
   - mDNS port: `5353`
3. Verify router configuration:
   - Ensure mDNS not disabled

#### Additional Resources

- [Official HomeKit Troubleshooting](https://www.home-assistant.io/integrations/homekit#troubleshooting)
- [HomeKit Bridge Docker Guide](https://community.home-assistant.io/t/guide-homekit-bridge-on-home-assistant-in-docker-nanopi-r6s-friendlywrt-possibly-openwrt/775006)
- [Docker HomeKit Integration](https://community.home-assistant.io/t/using-homekit-component-inside-docker/45409)
- [HomeKit Troubleshooting Guide](https://www.reddit.com/r/HomeKit/comments/a3iwwj/troubleshooting_homekit_what_tools_to_use_and_how/)
- [Docker HomeKit Issue](https://github.com/home-assistant/core/issues/15692)
- [MacOS Docker Configuration](https://gist.github.com/dieu/96cded47544ee48ce0b3c69d529b723c)

# Summary

This tutorial demonstrates the integration of Bluetooth-enabled lights into Apple's HomeKit ecosystem using open-source tools. The implementation utilizes an ESP32 development board with `esphome-ble-adv-proxy` for Bluetooth communication. Home Assistant Core on MacOS manages device integration, while the `ha-ble-adv` custom component enables Bluetooth light control. The HomeKit Bridge facilitates iPhone Home app integration, enabling control through both the Home App and Siri. The guide includes comprehensive troubleshooting procedures, particularly for mDNS network issues in HomeKit integration.

# Q&A <a name="QA">

### Q1: Docker Compatibility

**Question**: Can Home Assistant run in Docker?

**Answer**: Yes, but with limitations. Reference implementations:
- [MacOS Docker Guide](https://gist.github.com/dieu/96cded47544ee48ce0b3c69d529b723c)
- [Docker HomeKit Bridge Guide](https://community.home-assistant.io/t/guide-homekit-bridge-on-home-assistant-in-docker-nanopi-r6s-friendlywrt-possibly-openwrt/775006)

**Known Issues**:
- HomeKit connection failures
- mDNS network detection issues
- Incompatibility with host Bluetooth functionality

### Q2: MacOS Bluetooth Integration

**Question**: Can MacOS built-in Bluetooth be used instead of ESP32?

**Answer**: Currently not supported for two reasons:
1. Docker limitations prevent host Bluetooth access
2. MacOS Bluetooth implementation doesn't meet `ble-adv` requirements

### Q3: Home Assistant Service Management

**Background Service Script**:

```shell
#!/bin/bash
source bin/activate
nohup hass --config config > hass.log 2>&1 &
echo "Home Assistant started on: http://localhost:8123"
```

**Service Management**:

1. Add execution permission:
```shell
$ chmod +x run.sh
```

2. Start service:
```shell
$ ./run.sh
```

3. Monitor logs:
```shell
$ tail -f hass.log
```

4. Stop service:
```shell
$ pkill -f "hass --config config"
```

# References

- [Home Assistant](https://www.home-assistant.io/)
- [Home Assistant Community Store](https://hacs.xyz/)
- [ha-ble-adv](https://github.com/NicoIIT/ha-ble-adv/)
- [ESP Home](https://esphome.io/)
- [esphome-ble-adv-proxy](https://github.com/NicoIIT/esphome-ble_adv_proxy)
- [ESP Home Installation Guide](https://esphome.io/guides/getting_started_command_line#bonus-esphome-device-builder)
- [ESP Home Installation Troubleshooting](https://esphome.io/guides/getting_started_command_line#installation)
- [ESP Home Home Assistant Integration](https://esphome.io/guides/getting_started_hassio)
- [Home Assistant MacOS Installation](https://www.home-assistant.io/installation/macos#install-home-assistant-core)
- [Home Assistant HomeKit Integration](https://www.home-assistant.io/integrations/homekit)
- [Home Assistant HomeKit Troubleshooting](https://www.home-assistant.io/integrations/homekit#troubleshooting)
- [HACS Documentation](https://hacs.xyz/)
- [HACS Configuration Guide](https://hacs.xyz/docs/use/configuration/basic/)
- [HACS Custom Repositories](https://hacs.xyz/docs/use/repositories/dashboard/)
- [ha-ble-adv FAQ](https://github.com/NicoIIT/ha-ble-adv?tab=readme-ov-file#faq)
- [HomeKit Bridge Docker Guide](https://community.home-assistant.io/t/guide-homekit-bridge-on-home-assistant-in-docker-nanopi-r6s-friendlywrt-possibly-openwrt/775006)
- [Docker HomeKit Integration](https://community.home-assistant.io/t/using-homekit-component-inside-docker/45409)
- [HomeKit Troubleshooting Guide](https://www.reddit.com/r/HomeKit/comments/a3iwwj/troubleshooting_homekit_what_tools_to_use_and_how/)
- [Docker HomeKit Issue](https://github.com/home-assistant/core/issues/15692)
- [MacOS Docker Configuration](https://gist.github.com/dieu/96cded47544ee48ce0b3c69d529b723c)

**Service URLs**:
- ESP Home Dashboard: [http://localhost:6052](http://localhost:6052)
- Home Assistant Dashboard: [http://localhost:8123](http://localhost:8123)

