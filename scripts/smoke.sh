#!/usr/bin/env bash
set -euo pipefail
# Always target the explicitly named disposable cluster, never the user's default.
context="${TEST_KUBE_CONTEXT:-kind-maintenance}"
if [[ "$context" != kind-maintenance* ]]; then
  echo "Refusing non-disposable Kubernetes context: $context" >&2; exit 1
fi
export KUBECONFIG="${KUBECONFIG:?Set KUBECONFIG to the disposable cluster config}"
chart="${1:?Usage: scripts/smoke.sh packaged-chart.tgz}"
namespace="maintenance-smoke"
forward_pid=''
cleanup() {
  status=$?
  if ((status != 0)); then
    kubectl --context "$context" -n "$namespace" get pods,events || true
    kubectl --context "$context" -n "$namespace" logs -l app.kubernetes.io/instance=maintenance-smoke --all-containers --tail=100 || true
  fi
  if [[ -n "$forward_pid" ]]; then kill "$forward_pid" 2>/dev/null || true; wait "$forward_pid" 2>/dev/null || true; fi
  helm --kube-context "$context" -n "$namespace" uninstall maintenance-smoke --wait --timeout 1m >/dev/null 2>&1 || true
  kubectl --context "$context" delete namespace "$namespace" --wait=false >/dev/null 2>&1 || true
  exit "$status"
}
trap cleanup EXIT
helm --kube-context "$context" upgrade --install maintenance-smoke "$chart" \
  --namespace "$namespace" --create-namespace -f ci/smoke-values.yaml --wait --timeout 5m
kubectl --context "$context" -n "$namespace" rollout status statefulset/maintenance-smoke --timeout=120s
kubectl --context "$context" -n "$namespace" port-forward service/maintenance-smoke 18080:8080 > /tmp/maintenance-port-forward.log 2>&1 &
forward_pid=$!
curl --fail --silent --show-error --retry 20 --retry-delay 2 --retry-connrefused --max-time 10 http://127.0.0.1:18080/ > /tmp/maintenance-http.html
grep -qi 'zigbee2mqtt' /tmp/maintenance-http.html
kill "$forward_pid"; wait "$forward_pid" 2>/dev/null || true; forward_pid=''
# Reinstall with real persistence; kind supplies its standard storage provisioner.
helm --kube-context "$context" -n "$namespace" uninstall maintenance-smoke --wait
helm --kube-context "$context" upgrade --install maintenance-smoke "$chart" \
  --namespace "$namespace" -f ci/smoke-values.yaml --set zigbee2mqtt.persistence.enabled=true --wait --timeout 5m
kubectl --context "$context" -n "$namespace" rollout status statefulset/maintenance-smoke --timeout=120s
kubectl --context "$context" -n "$namespace" exec statefulset/maintenance-smoke -c app -- sh -c 'echo preserved > /app/data/.maintenance-smoke'
# Reapply the packaged chart to exercise the upgrade path without changing images.
helm --kube-context "$context" upgrade maintenance-smoke "$chart" \
  --namespace "$namespace" -f ci/smoke-values.yaml --set zigbee2mqtt.persistence.enabled=true --wait --timeout 5m
kubectl --context "$context" -n "$namespace" rollout restart statefulset/maintenance-smoke
kubectl --context "$context" -n "$namespace" rollout status statefulset/maintenance-smoke --timeout=180s
test "$(kubectl --context "$context" -n "$namespace" exec statefulset/maintenance-smoke -c app -- cat /app/data/.maintenance-smoke)" = preserved
