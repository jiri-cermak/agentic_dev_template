#!/usr/bin/env bash
#
# Canonical history-index integrity check. Projects adopt this logic as their
# own ops/index_check.sh (templates/checks is the canonical copy).
#
# For a state doc with a dated log (CONTEXT_HISTORY.md, the migrated layout):
#   1. every dated entry        ## YYYY-MM-DD <title>   heading in the log
#      must have a matching row in the index block,
#   2. every index row must point at a dated heading that exists, and
#   3. no dated heading may be empty (## <date> with no body).
#
# Each finding is printed one per line with a stable prefix:
#     MISSING ROW:    <heading>     a dated heading has no index row
#     STALE ROW:      <index row>   an index row points at no dated heading
#     EMPTY HEADING:  <heading>     a dated heading has no body
# plus a summary line, and the script exits non-zero if any finding is raised.
#
# Index block: the contiguous lines from the first heading whose title contains
# "index" (e.g. "## History index") up to the first dated heading; an index row
# is any such line carrying a YYYY-MM-DD token. If no index block is found, every
# dated heading is treated as a missing row (conservative, and true of a doc
# built this way). Dated-entry bodies are lines between a dated heading and the
# next heading (any level) or end of file; a heading is empty if that slice is
# blank-only or absent.
#
# Degrades safely: if no CONTEXT_HISTORY.md is present, prints
#     no dated log — skipped
# and exits 0. Never mutates the tree; a single read of one file.

set -u

history="CONTEXT_HISTORY.md"

if [ ! -f "$history" ]; then
  echo "no dated log — skipped"
  exit 0
fi

# Dated heading -> line numbers + full text.
# Each element: "<lineno>:<full heading>".
mapfile -t heads < <(grep -nE '^## +[0-9]{4}-[0-9]{2}-[0-9]{2}( |$)' "$history")

# Index rows: lines carrying a YYYY-MM-DD token inside the index block, with
# the row's source line kept for STALE reporting.
idx_rows=""
idx_seen=0

# First dated-heading line number, else EOF+1.
first_head=$(( $(wc -l < "$history") + 1 ))
if [ "${#heads[@]}" -gt 0 ]; then
  h="${heads[0]}"; first_head=$(( ${h%%:*} ))
fi
# First index-heading line number if any.
idx_ln=$(grep -nE '^#+.*[Ii]ndex' "$history" | head -1 | cut -d: -f1)

if [ -n "$idx_ln" ]; then
  # Region: lines after the index heading, up to first dated heading.
  start=$((idx_ln + 1)); end=$((first_head - 1))
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      # Keep one row per date token; a row may hold several dates.
      rest="$line"
      while [[ "$rest" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; do
        idx_rows="$idx_rows|${BASH_REMATCH[1]}~$line"
        rest="${rest#*"${BASH_REMATCH[1]}"}"
        rest="${rest:2}"
      done
    fi
  done < <(sed -n "${start},${end}p" "$history")
  idx_seen=1
fi

# Exit code tally.
findings=0

# --- MISSING ROW: a dated heading with no matching index row. ---
for h in "${heads[@]}"; do
  heading="${h#*:}"
  date="${heading#*## }"; date="${date%% *}"
  if [ "$idx_seen" -eq 0 ] || [[ ! "$idx_rows" == *"|${date}~"* ]]; then
    echo "MISSING ROW: $heading"
    findings=$((findings + 1))
  fi
done

# --- STALE ROW: an index row pointing at no dated heading. ---
if [ "$idx_seen" -eq 1 ]; then
  IFS='|' read -r -a rows <<< "$idx_rows"
  for r in "${rows[@]:1}"; do
    [ -z "$r" ] && continue
    date="${r%%~*}"; row="${r#*~}"
    if ! grep -qE '^## +'"$date"'( |$)' "$history"; then
      echo "STALE ROW: $row"
      findings=$((findings + 1))
    fi
  done
fi

# --- EMPTY HEADING: a dated heading with no body (blank-only slice). ---
n=${#heads[@]}
for i in "${!heads[@]}"; do
  h="${heads[$i]}"
  ln=$(( ${h%%:*} )); heading="${h#*:}"
  if [ "$i" -lt $((n - 1)) ]; then
    nh="${heads[$((i + 1))]}"; nxt=$(( ${nh%%:*} ))
  else
    nxt=$(( $(wc -l < "$history") + 1 ))
  fi
  slice="$(sed -n "$((ln + 1)),$((nxt - 1))p" "$history")"
  if [ -z "$slice" ] || ! grep -qE '^[^#[:space:]]' <<< "$slice"; then
    echo "EMPTY HEADING: $heading"
    findings=$((findings + 1))
  fi
done

echo "index check: ${#heads[@]} dated heading(s), $([ "$idx_seen" -eq 1 ] && echo "index present" || echo "no index block"), $findings finding(s)."
exit "$findings"
