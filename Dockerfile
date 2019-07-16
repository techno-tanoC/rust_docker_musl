FROM ubuntu:18.04 as builder
WORKDIR /app
RUN apt update && \
    apt install -y --no-install-recommends curl ca-certificates

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain stable-x86_64-unknown-linux-gnu

ENV PATH=/root/.cargo/bin:$PATH
RUN rustup target add x86_64-unknown-linux-musl --toolchain stable-x86_64-unknown-linux-gnu
RUN apt install -y --no-install-recommends musl-tools build-essential libssl-dev pkg-config

COPY Cargo.toml .
COPY Cargo.lock .
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release --target x86_64-unknown-linux-musl

COPY . .
RUN cargo build --release --target x86_64-unknown-linux-musl

FROM alpine

RUN apk add --update ca-certificates
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/static_link /
