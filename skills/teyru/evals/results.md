# Skill eval results

Ran 2026-11-22 with OMP 19.1.0 and model `moff/deepseek/deepseek-v4.1-flash`,
one run per task per arm. Twelve tasks, two arms, 24 runs, on a machine also
running this session.

A run passes when `grade.sh` copies the task's checks into the working folder
and `teyru test` passes there. The agent never sees `checks/` or `solution/`.

| Arm | Passed | Share |
| --- | --- | --- |
| With the skill | 12 of 12 | 100% |
| Without the skill | 12 of 12 | 100% |

No difference. Both arms solved every task, so this run puts no number on what
the skill is worth.

## Method

- `run-eval.sh` copies `tasks/<name>/starter/` into a fresh work directory.
  The skill arm also gets `.omp/skills/teyru/SKILL.md` there and runs with
  `--skills=teyru`; the other arm runs with `--no-skills`.
- Both arms get the same prompt (`tasks/<name>/PROMPT.md`) and the same tools
  (`read`, `write`, `edit`, `bash`, `glob`, `grep`), with `--no-context-files`
  and `--no-rules`, and a ten-minute cap.
- `teyru` is built from this repository's current `main` and put on `PATH`
  for both arms.
- `verify-tasks.sh` proves each starter fails and each solution passes before
  any model runs: 12 tasks, 0 problems.
- `check-examples.py` builds every `teyru` fence in `SKILL.md`: 16 of 16
  behave as tagged.

## Limits

- Twelve tasks and one run per arm is a coarse measurement; a 12-point gap
  would be needed before this design could see one.
- The tasks are single-file bug fixes whose expected behaviour the prompt
  states. A capable model can recover from each one by building and reading
  the diagnostic, so the skill's advantage — not needing the compiler to
  explain the language — has nowhere to show. Tasks that require several
  rules at once, or a design the compiler accepts but grades fail, are what
  this eval needs next.
- The prompts name the API to keep, so neither arm had to design an interface.
- No timing or token comparison was recorded; the runs were sequential and
  the log sizes were not measured consistently.
