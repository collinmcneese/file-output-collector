# File Output Collector GitHub Action

Composite GitHub Action that reads a single-line text file and exposes its
contents as a step output for use by later steps in the same job.

## Uses

Pass a value written by a script or build step to later steps through
`steps.<id>.outputs.output`. Trailing newlines are removed.

## Flags

| Input | Required | Description |
| ----- | -------- | ----------- |
| `file` | Yes | File path containing only letters, digits, `_`, `.`, `/`, and `-`. Directories are rejected. |
| `fail_on_missing` | No | Any non-empty value, including `'false'`, fails if the file is missing. Omit to allow missing files. |

## Example

```yaml
- name: Checkout repository
  uses: actions/checkout@v7

- name: Collect file output
  id: collect
  uses: collinmcneese/file-output-collector@v1
  with:
    file: result.txt
    fail_on_missing: 'true'

- name: Use file output
  shell: bash
  env:
    FILE_OUTPUT: ${{ steps.collect.outputs.output }}
  run: printf '%s\n' "$FILE_OUTPUT"
```
