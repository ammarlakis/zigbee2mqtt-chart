# Version bump helper for the Zigbee2MQTT chart

# Usage:
#   just bump            # defaults to patch
#   just bump patch
#   just bump minor
#   just bump major

bump type='patch':
    ./scripts/bump-version.sh {{type}}
