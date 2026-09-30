#!/usr/bin/env bash
set -euo pipefail
# Prepare a reviewable release branch. Tagging and publication are separate approvals.
chart="charts/zigbee2mqtt"
open_pr=false
if [[ "${1:-}" == --pr ]]; then open_pr=true; shift; fi
if (($#)); then echo 'Usage: scripts/release.sh [--pr] (optional RELEASE_VERSION=X.Y.Z)' >&2; exit 1; fi
if [[ "${RELEASE_PUSH:-false}" != false ]]; then
  echo 'RELEASE_PUSH is retired. Use --pr to open a draft; publication requires an approved tag.' >&2; exit 1
fi
for tool in git git-cliff helm helm-docs prettier; do command -v "$tool" >/dev/null; done
if "$open_pr"; then command -v gh >/dev/null; fi
test -z "$(git status --porcelain)" || { echo 'Start from a clean worktree.' >&2; exit 1; }
test "$(git branch --show-current)" = master || { echo 'Check out master before preparing a release.' >&2; exit 1; }
git fetch origin master --tags
test "$(git rev-parse HEAD)" = "$(git rev-parse origin/master)" || { echo 'Update master to origin/master first.' >&2; exit 1; }
raw_version="${RELEASE_VERSION:-$(git cliff --bumped-version)}"
new_version="${raw_version#v}"
[[ "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]] || { echo 'Expected a semantic version.' >&2; exit 1; }
tag="v$new_version"
if git rev-parse --verify "refs/tags/$tag" >/dev/null 2>&1; then echo "Tag $tag already exists." >&2; exit 1; fi
branch="release/$tag"
git switch -c "$branch"
sed -i.bak "s/^version: .*/version: $new_version/" "$chart/Chart.yaml"
rm "$chart/Chart.yaml.bak"
helm-docs
prettier README.md "$chart/README.md" --write
git cliff --unreleased --tag "$tag" --prepend CHANGELOG.md
helm lint "$chart"
helm template release-check "$chart" >/dev/null
git add "$chart/Chart.yaml" "$chart/README.md" README.md CHANGELOG.md
git commit -m "chore: prepare release $new_version"
if "$open_pr"; then
  body_file="$(mktemp)"
  trap 'rm -f "$body_file"' EXIT
  cat > "$body_file" <<BODY
Prepare chart release $new_version with git-cliff notes and regenerated chart documentation.

Local Helm lint and rendering pass. Required consumer CI must pass before review and merge. After approval, create immutable tag $tag on the merged master commit; the release workflow verifies and publishes its tested artifact.

This PR creates no tag and publishes no release.
BODY
  git push -u origin "$branch"
  gh pr create --draft --base master --head "$branch" --title "chore: prepare release $new_version" --body-file "$body_file"
else
  echo "Prepared $branch locally. Review the diff, push this branch and open a PR against master."
fi
echo "No release tag was created. After review and merge, obtain approval before tagging $tag."
