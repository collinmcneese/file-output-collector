#!/usr/bin/env bash
set -euo pipefail

action_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/file-output-collector.XXXXXX")
cleanup() {
  rm -f "$test_dir/value.txt" "$test_dir/empty.txt" \
    "$test_dir/nested/value.txt" "$test_dir/output" \
    "$test_dir/summary" "$test_dir/injected"
  rmdir "$test_dir/nested" "$test_dir"
}
trap cleanup EXIT

cd "$test_dir"
mkdir nested
printf 'collected value\n' > value.txt
printf 'nested value\n' > nested/value.txt
touch empty.txt
export GITHUB_OUTPUT="$test_dir/output"
export GITHUB_STEP_SUMMARY="$test_dir/summary"

check() {
  local name="$1" file="$2" fail_on_missing="$3"
  local expected_status="$4" expected_output="$5"
  local status=0 log
  : > "$GITHUB_OUTPUT"
  : > "$GITHUB_STEP_SUMMARY"
  log=$(INPUT_FILE="$file" INPUT_FAIL_ON_MISSING="$fail_on_missing" \
    bash "$action_dir/collect-output.sh" 2>&1) || status=$?

  if [[ "$status" != "$expected_status" || "$(cat "$GITHUB_OUTPUT")" != "$expected_output" ]]; then
    printf 'FAIL: %s (expected status %s, got %s)\n%s\n' \
      "$name" "$expected_status" "$status" "$log" >&2
    cat "$GITHUB_OUTPUT" "$GITHUB_STEP_SUMMARY" >&2
    exit 1
  fi
  printf 'PASS: %s\n' "$name"
}

check 'relative file' value.txt '' 0 'output=collected value'
check 'nested file' nested/value.txt '' 0 'output=nested value'
check 'absolute file' "$test_dir/value.txt" '' 0 'output=collected value'
check 'empty file' empty.txt '' 0 'output='
check 'missing file fails by default' missing.txt '' 1 ''
check 'missing file fails with true' missing.txt true 1 ''
check 'missing file allowed with false' missing.txt false 0 ''
check 'missing file allowed with no' missing.txt no 0 ''
check 'missing file allowed with FALSE' missing.txt FALSE 0 ''
check 'missing file fails with other value' missing.txt maybe 1 ''
check 'directory' nested '' 1 ''
check 'spaces' 'invalid name.txt' '' 1 ''
check 'wildcard' '*.txt' '' 1 ''
check 'newline' $'invalid\nname.txt' '' 1 ''
check 'shell syntax remains literal' '$(touch injected)' '' 1 ''

if [[ -e injected ]]; then
  echo 'FAIL: File input was executed as shell code' >&2
  exit 1
fi
