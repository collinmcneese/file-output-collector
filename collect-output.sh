#!/usr/bin/env bash
set -eo pipefail

file="${INPUT_FILE}"

# Missing files fail unless fail_on_missing is "false" or "no" (case-insensitive).
fail_on_missing=$(printf '%s' "${INPUT_FAIL_ON_MISSING}" | tr '[:upper:]' '[:lower:]')

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
elif [[ "${fail_on_missing}" == "false" || "${fail_on_missing}" == "no" ]]; then
  echo "File ${file} does not exist, but fail_on_missing is disabled" >> "$GITHUB_STEP_SUMMARY"
else
  echo "File ${file} does not exist" >> "$GITHUB_STEP_SUMMARY"
  exit 1
fi
