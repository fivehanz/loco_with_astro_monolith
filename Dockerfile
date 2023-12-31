# docker image with two build step and a nginx runner
ARG RUST_VERSION=1.74.1
ARG BUN_VERSION=1.0.20

# only 3000 for now
ARG PORT=3000

ARG RUST_BUILD_IMAGE=rust:${RUST_VERSION}-slim-bookworm
ARG BUN_BUILDER_IMAGE=oven/bun:${BUN_VERSION}-slim
ARG RUNNER_IMAGE=debian:bookworm-slim



### backend build stage
FROM ${RUST_BUILD_IMAGE} as rust-builder

# build loco app
WORKDIR /app
COPY . .

RUN apt-get update && apt-get install -y make
RUN make build-backend



### frontend build stage
FROM ${BUN_BUILDER_IMAGE} as bun-builder

# build frontend app
WORKDIR /app
COPY ./frontend .
COPY ./Makefile .

RUN bun i --production \
    --verbose \
    --frozen-lockfile

RUN bun --bun run build



### server runner
FROM ${RUNNER_IMAGE} as runner

ENV PORT ${PORT}
EXPOSE $PORT

WORKDIR /app

COPY ./config/production.yaml ./config/production.yaml
COPY --from=rust-builder /app/target/release/app ./app
COPY --from=bun-builder /app/dist /app/frontend/dist


# CMD [ "./app", "start", "--server-and-worker" ]
CMD [ "./app", "start", "-e", "production", "--server-and-worker" ]
