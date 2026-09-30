# Maintenance

Status: pilot; merges and releases require maintainer review. CI baseline: Helm 3.19 and the Kubernetes version supplied by the pinned kind action. Broader Kubernetes compatibility is not yet claimed.

## Verify

Run `helm lint charts/zigbee2mqtt`, `helm template test charts/zigbee2mqtt`, and `helm package charts/zigbee2mqtt --destination dist`. For consumer tests, create a disposable kind cluster named `maintenance`, export its kubeconfig, and run `scripts/smoke.sh dist/zigbee2mqtt-*.tgz`. The script refuses contexts outside the `kind-maintenance` prefix and cleans up its test namespace.

Require **Chart consumer tests** on `master`. Tests run for PRs, default-branch pushes, weekly, and before releases. Renovate runs weekly with automatic merging disabled.

The smoke test uses the real Zigbee2MQTT image in its supported forced-onboarding mode and mounts `/dev/null` in place of a radio. It verifies image startup, configuration initialization, HTTP service wiring, persistence provisioning, and chart upgrade. It does **not** verify radio communication or MQTT messaging. A hardware-backed check with a real adapter remains required before claiming those behaviors are covered.

## Release

Prepare a PR with the chart version and git-cliff changelog; obtain approval and merge after required checks pass. Create an immutable `vX.Y.Z` tag on that commit matching `Chart.yaml`. The release workflow reruns consumer tests, downloads the exact tested package, verifies tag/version agreement and default-branch ancestry, publishes it, compares the downloaded release asset, and waits for the Helm registry update.

Publishing is tag-triggered; the previous manual dispatch path is removed to prevent publishing an unverified branch as a release. Do not run the legacy `just release` script during the pilot: it pushes directly and bypasses the review flow. Use the version/changelog PR followed by an approved tag instead.
