#!/usr/bin/env bash
set -euo pipefail

CHART_FILE="charts/zigbee2mqtt/Chart.yaml"

if [[ ! -f "${CHART_FILE}" ]]; then
  echo "Chart file not found: ${CHART_FILE}" >&2
  exit 1
fi

raw_version="$(git cliff --bumped-version)"
if [[ -z "${raw_version}" ]]; then
  echo "Could not determine next version from git-cliff" >&2
  exit 1
fi

if [[ "${raw_version}" == v* ]]; then
  tag="${raw_version}"
  new_version="${raw_version#v}"
else
  new_version="${raw_version}"
  tag="v${raw_version}"
fi

if git rev-parse "${tag}" >/dev/null 2>&1; then
  echo "Tag ${tag} already exists" >&2
  exit 1
fi

echo "Next version from commits: ${new_version}"
echo "Creating release ${tag}"

echo "Updating ${CHART_FILE}..."
sed -i.bak "s/^version: .*/version: ${new_version}/" "${CHART_FILE}"
rm -f "${CHART_FILE}.bak"

echo "Regenerating Helm docs..."
helm-docs

echo "Formatting README..."
prettier charts/zigbee2mqtt/README.md -w

echo "Updating CHANGELOG.md with git-cliff..."
git cliff --unreleased --tag "${tag}" --prepend CHANGELOG.md

git add "${CHART_FILE}" CHANGELOG.md charts/zigbee2mqtt/README.md

 git commit --no-verify -m "chore: prepare for ${new_version} @ignore" || {
  echo "Nothing to commit; aborting" >&2
  exit 1
}

 echo "Creating tag ${tag} on HEAD..."
 git tag "${tag}"

 echo "Pushing commit and tag to origin..."
 git push origin HEAD
 git push origin "${tag}"

 echo "Done. Released ${tag}."
