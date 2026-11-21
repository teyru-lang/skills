#!/bin/sh
# Grade one finished eval task.
# Usage: sh grade.sh TEYRU TASK_DIR WORK_DIR
#   TASK_DIR is a folder under tasks/. WORK_DIR is the package the agent edited.
# The task's checks are copied into WORK_DIR, then `teyru test` runs them.
# `teyru test` compiles the package too, so a compile error fails the grade.
# Exit code 0 when every check passes, 1 otherwise.
set -u
if [ "$#" -ne 3 ]; then
  echo "usage: sh grade.sh TEYRU TASK_DIR WORK_DIR" >&2
  exit 2
fi
teyru=$1
task=$2
work=$3
cp "$task"/checks/* "$work"/
"$teyru" test "$work"
