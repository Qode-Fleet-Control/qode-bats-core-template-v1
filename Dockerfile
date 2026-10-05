# Built by .github/workflows/deploy.yml (context ., file Dockerfile) and pushed
# to Artifact Registry.
#
# A job image, not a server: FROM the official bats-core image (bats/bats), which ships
# bats plus the bats-support / bats-assert / bats-file libraries on BATS_LIB_PATH. Its
# entrypoint is `bats`; the default command runs the suite in test/ and exits 0 when it
# passes.

FROM bats/bats:1.13.0
ARG BUILD_ID=""
ENV BUILD_ID=$BUILD_ID
RUN adduser -D -u 10001 app
WORKDIR /code
COPY --chown=app:app . .
USER app
CMD ["--print-output-on-failure", "test"]
