#!/usr/bin/env bash
set -euo pipefail

OWNER=${PRFLOW_OWNER:-WhoIsCalebBrown}
CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}/git-pr-flow/gitconfig

for condition in \
  "hasconfig:remote.*.url:git@github.com:$OWNER/**" \
  "hasconfig:remote.*.url:ssh://git@github.com/$OWNER/**" \
  "hasconfig:remote.*.url:https://github.com/$OWNER/**" \
  "hasconfig:remote.*.url:http://github.com/$OWNER/**"; do
  git config --global --unset-all "includeIf.$condition.path" "$CONFIG" 2>/dev/null || true
done

rm -f "$HOME/.local/bin/git-pr-flow"
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/git-pr-flow" "${XDG_CONFIG_HOME:-$HOME/.config}/git-pr-flow"
echo "Git PR Flow removed. Repository commits and branches were not changed."
