#!/usr/bin/env bash
# strings.sh — a small bash library: source it, then call its functions.
#
#   source src/strings.sh
#   str_trim "  hi  "            # -> hi
#   str_slugify "Hello, World!"  # -> hello-world
#   semver_compare 1.2.0 1.10.0  # -> -1   (prints -1, 0 or 1)

# str_trim STRING — strip leading and trailing whitespace
str_trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s\n' "$s"
}

# str_slugify STRING — lowercase, runs of non-alphanumerics become one "-", no edge dashes
str_slugify() {
  local s
  s=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
  printf '%s\n' "$s"
}

# semver_compare A B — print -1, 0 or 1 as A <, =, > B (MAJOR.MINOR.PATCH, numeric parts).
# Returns 2 and writes to stderr when either argument is not a version.
semver_compare() {
  local re='^[0-9]+\.[0-9]+\.[0-9]+$' a b i
  if [[ ! $1 =~ $re || ! $2 =~ $re ]]; then
    echo "semver_compare: not a MAJOR.MINOR.PATCH version: '$1' '$2'" >&2
    return 2
  fi
  IFS=. read -r -a a <<<"$1"
  IFS=. read -r -a b <<<"$2"
  for i in 0 1 2; do
    if ((10#${a[i]} < 10#${b[i]})); then echo -1; return 0; fi
    if ((10#${a[i]} > 10#${b[i]})); then echo 1; return 0; fi
  done
  echo 0
}
