# zigbee2mqtt

![Version: 0.3.2](https://img.shields.io/badge/Version-0.3.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.6.3](https://img.shields.io/badge/AppVersion-2.6.3-informational?style=flat-square)

Zigbee2MQTT Helm chart

**Homepage:** <https://github.com/ammarlakis/zigbee2mqtt-chart>

## Maintainers

| Name        | Email | Url                             |
| ----------- | ----- | ------------------------------- |
| Ammar Lakis |       | <https://github.com/ammarlakis> |

## Source Code

- <https://github.com/Koenkk/zigbee2mqtt>

## Values

| Key                             | Type   | Default                                                                   | Description                                                                                                                                                       |
| ------------------------------- | ------ | ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| zigbee2mqtt.image               | object | `{"repository":"koenkk/zigbee2mqtt","tag":""}`                            | Zigbee2MQTT image configuration.                                                                                                                                  |
| zigbee2mqtt.image.repository    | string | `"koenkk/zigbee2mqtt"`                                                    | Container image repository for Zigbee2MQTT.                                                                                                                       |
| zigbee2mqtt.image.tag           | string | `""`                                                                      | Container image tag. Defaults to .Chart.AppVersion when empty.                                                                                                    |
| zigbee2mqtt.ingress             | object | `{"annotations":{},"className":"","enabled":false,"hosts":null,"tls":[]}` | Ingress configuration for exposing the HTTP API / frontend.                                                                                                       |
| zigbee2mqtt.ingress.annotations | object | `{}`                                                                      | Additional Ingress annotations.                                                                                                                                   |
| zigbee2mqtt.ingress.className   | string | `""`                                                                      | Ingress class name. If empty, the cluster default is used.                                                                                                        |
| zigbee2mqtt.ingress.enabled     | bool   | `false`                                                                   | Enable Ingress resource for Zigbee2MQTT.                                                                                                                          |
| zigbee2mqtt.ingress.hosts       | string | `nil`                                                                     | List of Ingress host definitions.                                                                                                                                 |
| zigbee2mqtt.ingress.tls         | list   | `[]`                                                                      | Ingress TLS configuration.                                                                                                                                        |
| zigbee2mqtt.initConfig          | object | `{}`                                                                      | Initial Zigbee2MQTT configuration written to configuration.yaml.                                                                                                  |
| zigbee2mqtt.overwriteConfig     | bool   | `false`                                                                   | If true, always overwrite configuration.yaml in the data volume from the ConfigMap on startup. When false, the file is only created if it does not already exist. |
| zigbee2mqtt.service             | object | `{"port":8080,"type":"ClusterIP"}`                                        | Service configuration for the Zigbee2MQTT HTTP API / frontend.                                                                                                    |
| zigbee2mqtt.service.port        | int    | `8080`                                                                    | Service port for the HTTP API / frontend.                                                                                                                         |
| zigbee2mqtt.service.type        | string | `"ClusterIP"`                                                             | Service type.                                                                                                                                                     |
| zigbee2mqtt.timezone            | string | `"Europe/Berlin"`                                                         | Timezone for the container (TZ environment variable).                                                                                                             |
| zigbee2mqtt.zigbee_device       | string | `"/dev/ttyUSB0"`                                                          | Path to the Zigbee adapter device on the node.                                                                                                                    |

---

Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
