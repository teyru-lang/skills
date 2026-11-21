"""Check the Teyru examples in a markdown file against a built teyru compiler.

Usage: python3 check-examples.py TEYRU FILE.md

A fence tagged `teyru` must build. A fence tagged `teyru error TY-XXX-NNNN`
must fail to build with that diagnostic code. A fence with neither tag is not
checked.

Exit code 0 when every example behaves as tagged.
"""

import re
import subprocess
import sys
import tempfile
from pathlib import Path

FENCE = re.compile(
    r"^```teyru(?: error (TY-[A-Z]+-\d{4}))?\n(.*?)^```$", re.S | re.M
)

STUB = """
class SkillExampleEntry {
  public static void main(String[] args) {
  }
}
"""


def example_source(body):
    if "static void main(" in body:
        return body
    return body + STUB


def check(teyru, source, expected_code):
    with tempfile.TemporaryDirectory() as folder:
        path = Path(folder) / "example.teyru"
        path.write_text(example_source(source))
        result = subprocess.run(
            [teyru, "build", "-O0", "-o", str(Path(folder) / "out"), str(path)],
            capture_output=True,
            text=True,
        )
    output = result.stdout + result.stderr
    if expected_code is None:
        return result.returncode == 0, output
    codes = re.findall(r"error\[(TY-[A-Z]+-\d{4})\]", output)
    return expected_code in codes, "codes: " + ", ".join(codes or ["<none>"])


def main():
    if len(sys.argv) != 3:
        print("usage: python3 check-examples.py TEYRU FILE.md", file=sys.stderr)
        return 2
    teyru, markdown = sys.argv[1], Path(sys.argv[2])
    text = markdown.read_text()
    checked = failed = 0
    for index, match in enumerate(FENCE.finditer(text), start=1):
        code, body = match.group(1), match.group(2)
        ok, detail = check(teyru, body, code)
        checked += 1
        label = code or "build"
        if ok:
            print(f"ok   example {index} ({label})")
        else:
            failed += 1
            print(f"FAIL example {index} ({label})")
            print(detail.strip())
    print(f"{checked - failed}/{checked} examples pass")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
