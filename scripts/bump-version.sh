#!/usr/bin/env bash
set -euo pipefail

BUMP_TYPE="${1:-patch}"
CHART_FILE="charts/zigbee2mqtt/Chart.yaml"

if [[ ! -f "${CHART_FILE}" ]]; then
  echo "Chart file not found: ${CHART_FILE}" >&2
  exit 1
fi

current_version=$(grep '^version:' "${CHART_FILE}" | awk '{print $2}')
if [[ -z "${current_version}" ]]; then
  echo "Could not determine current version from ${CHART_FILE}" >&2
  exit 1
fi

IFS='.' read -r major minor patch <<< "${current_version}"

case "${BUMP_TYPE}" in
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  patch)
    patch=$((patch + 1))
    ;;
  *)
    echo "Unknown bump type: ${BUMP_TYPE} (expected: major, minor, patch)" >&2
    exit 1
    ;;
esac

new_version="${major}.${minor}.${patch}"

tag="v${new_version}"

if git rev-parse "${tag}" >/dev/null 2>&1; then
  echo "Tag ${tag} already exists" >&2
  exit 1
fi

echo "Current version: ${current_version}"
echo "New version: ${new_version} (${BUMP_TYPE})"

echo "Updating ${CHART_FILE}..."
sed -i.bak "s/^version: .*/version: ${new_version}/" "${CHART_FILE}"
rm -f "${CHART_FILE}.bak"

git add "${CHART_FILE}"

git commit -m "chore: bump chart version to ${new_version}" || {
  echo "Nothing to commit; aborting" >&2
  exit 1
}


echo "Creating tag ${tag} on HEAD..."
git tag "${tag}"

echo "Pushing commit and tag to origin..."
git push origin HEAD
git push origin "${tag}"

echo "Done. Pushed ${tag}."
