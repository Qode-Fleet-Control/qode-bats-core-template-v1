#!/usr/bin/env bats
# Tests for src/strings.sh. Run: bats test   (or `docker compose run --rm app`)

bats_require_minimum_version 1.5.0

setup() {
  load 'test_helper/common-setup'
  _common_setup
}

@test "str_trim strips leading and trailing whitespace" {
  run str_trim $'  \t hello world \n '
  assert_success
  assert_output "hello world"
}

@test "str_trim leaves an already-trimmed string alone" {
  run str_trim "abc"
  assert_output "abc"
}

@test "str_slugify lowercases and joins words with dashes" {
  run str_slugify "Hello, World!  From   Bats"
  assert_success
  assert_output "hello-world-from-bats"
}

@test "str_slugify of only punctuation is empty" {
  run str_slugify "!!!"
  assert_output ""
}

@test "semver_compare orders numerically, not lexically" {
  run semver_compare 1.2.0 1.10.0
  assert_output "-1"
  run semver_compare 2.0.0 1.99.99
  assert_output "1"
  run semver_compare 3.4.5 3.4.5
  assert_output "0"
}

@test "semver_compare rejects a non-version" {
  run --separate-stderr semver_compare 1.2 1.2.3
  assert_failure 2
  assert_output ""
  [[ $stderr == *"not a MAJOR.MINOR.PATCH version"* ]]
}
