#!/bin/sh
# Run the skill eval with OMP, one arm with the skill and one without.
# Usage: sh run-eval.sh
# Environment:
#   TEYRU   compiler to grade with (default: teyru on PATH)
#   MODEL   model for both arms (default: moff/deepseek/deepseek-v4.1-flash)
#   TASKS   task names, space separated (default: every task)
#   RUNS    runs per task per arm (default: 1)
#   OUT     result directory (default: evals/results/<timestamp>)
set -u
teyru=${TEYRU:-$(command -v teyru)}
model=${MODEL:-moff/deepseek/deepseek-v4.1-flash}
runs=${RUNS:-1}
here=$(cd "$(dirname "$0")" && pwd)
out=${OUT:-$here/results/$(date +%Y%m%d-%H%M%S)}
tasks=${TASKS:-$(for d in "$here"/tasks/*/; do basename "$d"; done)}

mkdir -p "$out"
: > "$out/results.tsv"
teyru_dir=$(dirname "$(command -v "$teyru")")

for name in $tasks; do
  taskdir="$here/tasks/$name"
  for arm in skill no-skill; do
    for run in $(seq 1 "$runs"); do
      work="$out/$name-$arm-$run"
      rm -rf "$work"
      mkdir -p "$work"
      cp -R "$taskdir/starter/." "$work/"
      cp "$taskdir/PROMPT.md" "$work/TASK.md"
      if [ "$arm" = skill ]; then
        mkdir -p "$work/.omp/skills/teyru"
        cp "$here/../SKILL.md" "$work/.omp/skills/teyru/SKILL.md"
        skills_arg=--skills=teyru
      else
        skills_arg=--no-skills
      fi
      (
        cd "$work" &&
          PATH="$teyru_dir:$PATH" omp -p --model "$model" \
            --auto-approve --no-context-files --no-rules \
            --tools=read,write,edit,bash,glob,grep \
            --max-time 10m \
            "$(cat "$taskdir/PROMPT.md")" > agent.log 2>&1
      )
      if sh "$here/grade.sh" "$teyru" "$taskdir" "$work" > "$work/grade.log" 2>&1; then
        verdict=pass
      else
        verdict=fail
      fi
      printf '%s\t%s\t%s\t%s\n' "$name" "$arm" "$run" "$verdict" >> "$out/results.tsv"
      printf '%s %s run %s: %s\n' "$name" "$arm" "$run" "$verdict"
    done
  done
done

echo
for arm in skill no-skill; do
  passed=$(awk -F'\t' -v a="$arm" '$2 == a && $4 == "pass"' "$out/results.tsv" | wc -l)
  total=$(awk -F'\t' -v a="$arm" '$2 == a' "$out/results.tsv" | wc -l)
  echo "$arm: $passed of $total"
done
echo "results: $out/results.tsv"
