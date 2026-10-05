# Shared setup, loaded by every test file's setup() — the layout the bats-core tutorial
# teaches (test/test_helper/common-setup.bash). The helper libraries are found on
# BATS_LIB_PATH: /usr/lib/bats in the bats/bats image, ./.bats locally (scripts/install.sh).
_common_setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." >/dev/null 2>&1 && pwd)"
  # shellcheck source=../../src/strings.sh
  source "$PROJECT_ROOT/src/strings.sh"
}
