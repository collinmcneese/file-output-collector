#!/usr/bin/env bash
set -eo pipefail

file="${INPUT_FILE}"

# Wildcards, spaces and newlines are not supported.
echo "Checking file name pattern for ${file}"
if [[ "${file}" =~ [^a-zA-Z0-9_./-] ]]; then
  echo "File ${file} contains invalid characters" >> "$GITHUB_STEP_SUMMARY"
  exit 1
fi

echo "Checking file type for ${file}"
if [[ -d "${file}" ]]; then
  echo "File ${file} is a directory" >> "$GITHUB_STEP_SUMMARY"
  exit 1
fi

echo "Checking file exists for ${file}"
if [[ -f "${file}" ]]; then
  echo "output=$(cat "${file}")" >> "$GITHUB_OUTPUT"
# Any non-empty fail_on_missing value fails the step, including "false".
elif [[ -n "${INPUT_FAIL_ON_MISSING}" ]]; then
  echo "File ${file} does not exist" >> "$GITHUB_STEP_SUMMARY"
  exit 1
else
  echo "File ${file} does not exist, but fail_on_missing is not set" >> "$GITHUB_STEP_SUMMARY"
fi
