#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/bin"
cat >"$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ ${1:-} == repo && ${2:-} == view ]]; then
  printf '%s\t%s\n' "${FAKE_FORK:-false}" main
elif [[ ${1:-} == pr && ${2:-} == create ]]; then
  echo "https://github.com/WhoIsCalebBrown/demo/pull/1"
else
  echo "unexpected gh invocation: $*" >&2
  exit 2
fi
EOF
chmod +x "$TMP/bin/gh"

git init --bare -q "$TMP/remote.git"
git init -q -b main "$TMP/work"
git -C "$TMP/work" config user.name Test
git -C "$TMP/work" config user.email test@example.com
git -C "$TMP/work" config prflow.owner WhoIsCalebBrown
git -C "$TMP/work" remote add origin "$TMP/remote.git"

echo base >"$TMP/work/file.txt"
git -C "$TMP/work" add file.txt
git -C "$TMP/work" commit -qm base
git -C "$TMP/work" push --no-verify -u origin main >/dev/null

echo work >>"$TMP/work/file.txt"
git -C "$TMP/work" commit -qam 'Add useful work'
local_oid=$(git -C "$TMP/work" rev-parse HEAD)
remote_oid=$(git -C "$TMP/work" rev-parse origin/main)

set +e
(
  cd "$TMP/work"
  printf 'refs/heads/main %s refs/heads/main %s\n' "$local_oid" "$remote_oid" |
    PATH="$TMP/bin:$PATH" "$ROOT/hooks/pre-push" origin git@github.com:WhoIsCalebBrown/demo.git
) >"$TMP/stdout" 2>"$TMP/stderr"
status=$?
set -e

[[ $status == 1 ]]
current=$(git -C "$TMP/work" branch --show-current)
[[ $current == work/*add-useful-work ]]
[[ $(git -C "$TMP/work" rev-parse main) == "$remote_oid" ]]
[[ $(git --git-dir="$TMP/remote.git" rev-parse "$current") == "$local_oid" ]]
grep -q 'created draft PR' "$TMP/stderr"

# A non-personal remote passes through without moving anything.
git -C "$TMP/work" switch -q main
before=$(git -C "$TMP/work" branch --show-current)
(
  cd "$TMP/work"
  printf 'refs/heads/main %s refs/heads/main %s\n' "$remote_oid" "$remote_oid" |
    PATH="$TMP/bin:$PATH" "$ROOT/hooks/pre-push" origin git@github.com:some-company/demo.git
)
[[ $(git -C "$TMP/work" branch --show-current) == "$before" ]]

echo "pre-push integration test passed"
