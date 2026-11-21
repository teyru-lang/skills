#!/bin/sh
# Build the plugin copy that the eval runs against, without the answers.
# Usage: sh prepare-eval.sh DEST
# Run the eval on DEST: the agent under test cannot read solution/ or checks/,
# because DEST has neither.
set -eu
if [ "$#" -ne 1 ]; then
  echo "usage: sh prepare-eval.sh DEST" >&2
  exit 2
fi
dest=$1
root=$(cd "$(dirname "$0")/../../.." && pwd)
rm -rf "$dest"
mkdir -p "$dest/skills/teyru" "$dest/.claude-plugin"
cp "$root/.claude-plugin/marketplace.json" "$dest/.claude-plugin/"
cp "$root/skills/teyru/SKILL.md" "$dest/skills/teyru/"
cp -R "$root/skills/teyru/evals" "$dest/skills/teyru/evals"
rm -rf "$dest"/skills/teyru/evals/results
rm -rf "$dest"/skills/teyru/evals/tasks/*/checks
for solution in "$dest"/skills/teyru/evals/tasks/*/solution; do
  rm -rf "$solution"
done
