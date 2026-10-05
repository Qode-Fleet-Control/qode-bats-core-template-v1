# Bats-core template

Provisioned from [`Qode-Fleet-Control/fleet-template-v1`](https://github.com/Qode-Fleet-Control/fleet-template-v1) — the fleet
lifecycle contract (`bin/`, `fleet.conf`, `compose.yaml`, deploy workflows) with a
Bats-core starter laid on top. **A job, not a service**: the image's default command runs the
check and exits 0 on success; nothing listens on `$PORT`.

## What it is

A small bash library and its [bats-core](https://github.com/bats-core/bats-core) tests,
in the layout the bats-core tutorial teaches:

| path | what |
|---|---|
| `src/strings.sh` | the library: `str_trim`, `str_slugify`, `semver_compare` |
| `test/strings.bats` | its tests (bats-assert: `assert_output`, `assert_failure`, `run --separate-stderr`) |
| `test/test_helper/common-setup.bash` | shared setup: loads bats-support / bats-assert, sources the library |
| `scripts/install.sh` | local install of bats-core + helpers into `./.bats` |

The helper libraries are loaded with `bats_load_library`, so they are found on
`BATS_LIB_PATH` — `/usr/lib/bats` in the official image, `./.bats` locally.

## Run it

**With docker** (what the fleet does):

    docker compose build
    docker compose run --rm app                     # the whole suite; exit 0 = pass
    docker compose run --rm app --filter slugify test

**Without docker** (needs bash, curl, tar):

    sh scripts/install.sh                            # = fleet.conf INSTALL_CMD
    BATS_LIB_PATH="$PWD/.bats" .bats/bats-core/bin/bats test

## Origin

    hand-written (bats-core ships no project generator) — the bats-core tutorial layout
    (src/, test/, test/test_helper/common-setup.bash)

Runtime: the official image `bats/bats:1.13.0` (bats-core 1.13.0 with bats-support and
bats-assert bundled). Local: bats-core v1.13.0, bats-support v0.3.0, bats-assert v2.2.4
from their GitHub release tarballs.

## Deviations from stock output, and why

- **No git submodules for the helpers.** The tutorial vendors bats-support/bats-assert as
  submodules under `test/test_helper/`; this template loads them with
  `bats_load_library` instead, so the official image's bundled copies are used in docker
  and `scripts/install.sh` fetches the same releases locally — nothing vendored in git.
- `bats_require_minimum_version 1.5.0` is declared because the tests use `run` flags.
## Verified

2026-10-05, Docker 29.8.2: `docker compose build` then `docker compose run --rm app` —
`1..6`, all six tests `ok`, exit 0. Locally (bash 5.2): `sh scripts/install.sh` then
`BATS_LIB_PATH=$PWD/.bats .bats/bats-core/bin/bats test` — 6/6 ok.


## Fleet lifecycle

`fleet.conf` drives every script in `bin/` (see `docs/fleet-lifecycle.md`). On the fleet
the docker runtime runs `DOCKER_BUILD_CMD` (`docker compose build`) and, because this is
a job and not a service, stops there: `DOCKER_START_CMD` is empty, the same as
`START_CMD`. Run the job itself with `docker compose run --rm app`.

    ./bin/run                    # docker runtime: builds the image, then stops (no server)
    docker compose run --rm app  # runs the job; exit code 0 = pass
    FLEET_RUNTIME=process ./bin/run   # no docker: runs INSTALL_CMD, then stops at start

`bin/run` ends with the template's own "no START_CMD" message — that is intentional.

## Serving over HTTP

Fleet apps are served at the root of their own hostname
(`https://<hash>.<FLEET_APP_DOMAIN>/`). **This repo has no HTTP surface**: `PORT`,
`HEALTH_PATH` and `START_CMD` are empty and `compose.yaml` publishes nothing. If you add
an HTTP endpoint, listen on `0.0.0.0:$PORT` (read at runtime), serve at `/`, set `PORT`,
`HEALTH_PATH`, `START_CMD` and `DOCKER_START_CMD='docker compose up --remove-orphans'`
in `fleet.conf`, and publish `"${PORT:-N}:${PORT:-N}"` in `compose.yaml`.

`compose.yaml` passes the fleet's variables (`DATABASE_URL`, `REDIS_URL`, `S3_*`,
`SMTP_*` …) through to the container without values; this template reads none of them.
