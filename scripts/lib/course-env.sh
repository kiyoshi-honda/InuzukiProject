#!/usr/bin/env bash
set -euo pipefail

for command_name in java gradle gh; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "エラー: ${command_name} が見つかりません。PortableGit Bashを起動し直してください。" >&2
    exit 1
  fi
done
