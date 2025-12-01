#!/usr/bin/env bash
# Pure functions only — no IO.
# Haskell-style naming, small reusable functions.

# maybe_read_file :: Path -> Maybe(String)
pure_maybe_read_file() {
  local file="$1"

  if [[ -f "$file" ]]; then
    cat "$file"
    return 0
  else
    # Nothing
    return 1
  fi
}

# pure_exclude_to_flags :: String -> [flags]
pure_exclude_to_flags() {
  # Input: raw lines
  # Output: each line mapped to "--exclude=<line>"
  local line
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue
    printf -- "--exclude=%s\n" "$line"
  done
}

# pure_exclude_from_file :: path -> [flags]
pure_exclude_from_file() {
  local file="$1"

  pure_maybe_read_file "$file" \
    | pure_exclude_to_flags
}

