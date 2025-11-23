# Commit-driven release helper
# Usage:
#   just release

release:
    helm-docs
    prettier charts/zigbee2mqtt/README.md -w
    git add charts/zigbee2mqtt/README.md
    ./scripts/release.sh
