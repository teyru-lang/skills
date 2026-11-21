# Teyru skills

Agent skills for [Teyru](https://github.com/teyru-lang/Teyru), the compiled
language with Java's shape and native output.

| Skill | What it covers |
|---|---|
| [`teyru`](skills/teyru/SKILL.md) | The `teyru` toolchain loop, the diagnostics agents keep hitting, and where the standard library differs from the JDK. |

## Install

The skill is a single directory with a `SKILL.md`. Any agent that loads a skill
from a directory can use it.

OMP: link or copy the skill into a directory OMP reads. The repository already
has `.omp/skills/teyru` pointing at `skills/teyru`, so running `omp` from this
repository loads it. For every project:

```sh
mkdir -p ~/.omp/agent/skills
ln -s "$PWD/skills/teyru" ~/.omp/agent/skills/teyru
```

Or set `skills.customDirectories` to the `skills/` directory.

Claude Code:

```
/plugin marketplace add teyru-lang/skills
/plugin install teyru@teyru
```

Or copy `skills/teyru/` into `<project>/.claude/skills/` (project scope) or
`~/.claude/skills/` (user scope).

The skill assumes `teyru` is on `PATH`:

```sh
go install github.com/teyru-lang/Teyru/cmd/teyru@latest
teyru version
```

## Evals

`skills/teyru/evals/` holds the checks for this skill:

- `check-examples.py` builds every `teyru` fence in `SKILL.md`; a fence tagged
  `teyru error TY-...` must fail with that code. No model call.
- `tasks/` holds twelve small Teyru packages. Each has a `starter/` that fails, a
  `solution/` that passes, a `checks/` test file, and a `PROMPT.md`.
- `verify-tasks.sh` proves every starter fails and every solution passes.
- `grade.sh` copies the checks into a work directory and runs `teyru test`.
- `run-eval.sh` runs an A/B eval with OMP: one arm with the skill, one without.

```sh
python3 skills/teyru/evals/check-examples.py "$(command -v teyru)" skills/teyru/SKILL.md
sh skills/teyru/evals/verify-tasks.sh "$(command -v teyru)"
sh skills/teyru/evals/run-eval.sh            # TEYRU, MODEL, TASKS, JOBS env vars
```

Results of the last run are in
[`skills/teyru/evals/results.md`](skills/teyru/evals/results.md).

## License

GPL-2.0, see [LICENSE](LICENSE).
