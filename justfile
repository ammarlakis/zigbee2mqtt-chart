# Version bump helper for the Zigbee2MQTT chart

# Usage:
#   just bump            # defaults to patch
#   just bump patch
#   just bump minor
#   just bump major

bump type='patch':
    helm-docs
    prettier charts/zigbee2mqtt/README.md -w
    git add charts/zigbee2mqtt/README.md
    ./scripts/bump-version.sh {{type}}
