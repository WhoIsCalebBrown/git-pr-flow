#!/usr/bin/env bash
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
OWNER=${PRFLOW_OWNER:-WhoIsCalebBrown}
DATA=${XDG_DATA_HOME:-$HOME/.local/share}/git-pr-flow
CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/git-pr-flow
CONFIG=$CONFIG_DIR/gitconfig
BIN=$HOME/.local/bin

install -d "$DATA/hooks" "$CONFIG_DIR" "$BIN"
install -m 755 "$HERE/hooks/pre-push" "$DATA/hooks/pre-push"
install -m 755 "$HERE/bin/git-pr-flow" "$DATA/git-pr-flow"
ln -sfn "$DATA/git-pr-flow" "$BIN/git-pr-flow"

if [[ -e $CONFIG ]]; then
  cp "$CONFIG" "$CONFIG.backup.$(date +%s)"
fi

{
  echo '[core]'
  echo "  hooksPath = $DATA/hooks"
  echo '[prflow]'
  echo "  owner = $OWNER"
  echo '  excludeRepo = hehehehehe'
  echo '  excludeRepo = neetcode-submissions'
} >"$CONFIG"

add_include() {
  local condition key
  condition=$1
  key="includeIf.$condition.path"
  git config --global --get-all "$key" 2>/dev/null | grep -Fx "$CONFIG" >/dev/null || git config --global --add "$key" "$CONFIG"
}
add_include "hasconfig:remote.*.url:git@github.com:$OWNER/**"
add_include "hasconfig:remote.*.url:ssh://git@github.com/$OWNER/**"
add_include "hasconfig:remote.*.url:https://github.com/$OWNER/**"
add_include "hasconfig:remote.*.url:http://github.com/$OWNER/**"

echo "Git PR Flow installed for GitHub remotes owned by $OWNER."
echo "Run 'git pr-flow status' inside a repository to inspect it."
