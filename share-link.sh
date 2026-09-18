#!/usr/bin/env bash
# Print (and copy to clipboard) the share link for a poll.
#
#   ./share-link.sh FOLDER      e.g. ./share-link.sh annex94-dk-2026-fall
#   ./share-link.sh             pick from a list of polls
#
# Reads owner/repo from config.txt and the token from token.txt.
set -euo pipefail
cd "$(dirname "$0")"

field() { awk -v f="[$1]" '$0==f{getline; print; exit}' config.txt | tr -d '[:space:]'; }

folder="${1:-}"
if [[ -z "$folder" ]]; then
  mapfile -t polls < <(find . -mindepth 2 -maxdepth 2 -name config.txt ! -path './template/*' \
                       -printf '%h\n' | sed 's|^\./||' | sort)
  [[ ${#polls[@]} -gt 0 ]] || { echo "No polls found." >&2; exit 1; }
  PS3="Poll number: "
  select folder in "${polls[@]}"; do [[ -n "$folder" ]] && break; done
fi
folder="${folder%/}"

[[ -f "$folder/config.txt" ]] || { echo "No poll folder '$folder' (missing $folder/config.txt)." >&2; exit 1; }
[[ -f token.txt ]] || { echo "token.txt not found — see README 'Store the token locally'." >&2; exit 1; }

owner="$(field owner)"
repo="$(field repo)"
token="$(tr -d '[:space:]' < token.txt)"
[[ -n "$owner" && -n "$repo" && -n "$token" ]] || { echo "owner/repo in config.txt or token.txt is empty." >&2; exit 1; }

# Same encoding as setup.html (encodeURIComponent).
token_enc="$(python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$token")"
link="https://${owner}.github.io/${repo}/${folder}/#t=${token_enc}"

echo "$link"
echo "Results: https://${owner}.github.io/${repo}/${folder}/results.html" >&2

if command -v wl-copy >/dev/null && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  printf '%s' "$link" | wl-copy && echo "✓ Share link copied to clipboard" >&2
elif command -v xclip >/dev/null && [[ -n "${DISPLAY:-}" ]]; then
  printf '%s' "$link" | xclip -selection clipboard && echo "✓ Share link copied to clipboard" >&2
fi
