# Zigbee2MQTT Helm Chart

This repository contains a Helm chart for deploying Zigbee2MQTT.

## Usage (local)

From the repository root:

- `helm install my-zigbee charts/zigbee2mqtt`
- `helm upgrade my-zigbee charts/zigbee2mqtt`
- `helm uninstall my-zigbee`

By default the chart:

- Runs Zigbee2MQTT as a StatefulSet with a persistent volume
- Mounts the USB Zigbee adapter from the host (default `/dev/ttyUSB0`)
- Exposes the Zigbee2MQTT web UI on port 8080 via a ClusterIP Service
