#!/usr/bin/env bash
# Prove the skill works as a tap, without touching the Hermes you actually use.
#
# Three things have to hold, and they fail for different reasons:
#
#   1. Hermes reads it. The frontmatter parses and the skill is called `kyte`,
#      which is the name people will type. Checked by mounting this repo's
#      skills/ as an external directory in a throwaway HERMES_HOME.
#   2. The install gate lets it through. A skill from a repository like ours is
#      `community`, and for community even a `caution` verdict blocks — `--force`
#      does not help. So the text itself has to scan clean. The classic way to
#      fail is an install line that pipes a download into a shell: that is one
#      `critical` finding, and one is enough. The install steps here name the
#      documentation instead.
#
# Step 1 needs the `hermes` command. Step 2 needs the Hermes sources, which the
# normal install puts in ~/.hermes/hermes-agent; HERMES_AGENT_DIR overrides it,
# and without them the step says so instead of pretending to pass.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
sandbox="$(mktemp -d)"
trap 'rm -rf "$sandbox"' EXIT
mkdir -p "$sandbox/home" "$sandbox/fakehome"

printf 'skills:\n  external_dirs:\n    - %s\n' "$here/skills" > "$sandbox/home/config.yaml"

echo "── Hermes reads the skill, under the name people type"
# The table is drawn for a terminal, so colour escapes sit right against the
# name: strip them before looking, or `kyte` is never its own word.
env HOME="$sandbox/fakehome" HERMES_HOME="$sandbox/home" PATH="$PATH" \
  hermes skills list > "$sandbox/list.out" 2>&1 || true
sed -E 's/\x1b\[[0-9;]*m//g' "$sandbox/list.out" | grep -Eq '[^a-z-]kyte[^a-z-]' \
  || { echo "FAIL: kyte not in the skill list"; sed -n '1,40p' "$sandbox/list.out"; exit 1; }

echo "── the community install gate lets it through"
agent_dir="${HERMES_AGENT_DIR:-$HOME/.hermes/hermes-agent}"
if [ ! -f "$agent_dir/tools/skills_guard.py" ]; then
  echo "SKIP: no Hermes sources at $agent_dir (set HERMES_AGENT_DIR)"
  exit 0
fi
python="$agent_dir/venv/bin/python"
[ -x "$python" ] || python="$(command -v python3)"
cat > "$sandbox/scan.py" <<'PY'
import sys
from pathlib import Path
sys.path.insert(0, sys.argv[1])
from tools.skills_guard import INSTALL_POLICY, VERDICT_INDEX, scan_skill

result = scan_skill(Path(sys.argv[2]), source="Pirol-ai/kyte-hermes")
print(f"   trust {result.trust_level}, verdict {result.verdict}")
for finding in result.findings:
    print(f"   [{finding.severity}] {finding.pattern_id} "
          f"{finding.file}:{finding.line} — {finding.description}")
policy = INSTALL_POLICY[result.trust_level][VERDICT_INDEX[result.verdict]]
print(f"   install {policy}")
sys.exit(0 if policy == "allow" else 1)
PY
"$python" -I "$sandbox/scan.py" "$agent_dir" "$here/skills/kyte" \
  || { echo "FAIL: the gate would block this skill"; exit 1; }

echo "── the skill and the catalog entry point at the same data folder"
# Two halves that disagree send the person to sign in for a folder the server
# never opens, and the symptom is a workspace that stays empty.
# Either half may write the home as `~` or as `${HOME}`; what has to match is the
# rest of the path, so both are read with that prefix taken off.
without_home() { printf '%s\n' "$1" | sed -E 's|^(~\|\$\{HOME\})||'; }
skill_folder="$(grep -o 'kyte login --db [^ ]*' "$here/skills/kyte/SKILL.md" | awk '{print $4}')"
manifest_folder="$(grep -o '[~$][{A-Za-z}]*/\.kyte/[a-z]*' "$here/optional-mcps/kyte/manifest.yaml" | head -1)"
[ -n "$skill_folder" ] && [ -n "$manifest_folder" ] \
  || { echo "FAIL: no data folder found (skill '$skill_folder', manifest '$manifest_folder')"; exit 1; }
[ "$(without_home "$skill_folder")" = "$(without_home "$manifest_folder")" ] \
  || { echo "FAIL: skill says $skill_folder, manifest says $manifest_folder"; exit 1; }
echo "   both: $skill_folder"

echo "── the line in the README installs it"
# The identifier, not the name: `hermes skills install kyte` answers "No exact
# match", because search is index-first and the index does not carry GitHub.
# A second sandbox, so the external_dirs mount above cannot stand in for the
# download. No token needed; the repository is public.
if [ "${KYTE_SKIP_NETWORK:-}" = "1" ]; then
  echo "   SKIP: KYTE_SKIP_NETWORK=1"
else
  mkdir -p "$sandbox/net/home" "$sandbox/net/fakehome"
  printf 'y\n' | env HOME="$sandbox/net/fakehome" HERMES_HOME="$sandbox/net/home" PATH="$PATH" \
    hermes skills install Pirol-ai/kyte-hermes/skills/kyte > "$sandbox/install.out" 2>&1 || true
  grep -q 'Installed: kyte' "$sandbox/install.out" \
    || { echo "FAIL: the README's install line did not install"; \
         sed -E 's/\x1b\[[0-9;]*m//g' "$sandbox/install.out" | tail -20; exit 1; }
  sed -E 's/\x1b\[[0-9;]*m//g' "$sandbox/install.out" | grep -E 'Verdict|Decision' | sed 's/^/   /'
fi

echo
echo "✓ the skill is read, scans clean, and installs from GitHub"
