FROM golang:1.22.1 AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

WORKDIR /workspace
COPY . .

RUN make -n prometheus-plex-exporter GOOS=${TARGETOS} GOARCH=${TARGETARCH} BINARY=./bin/prometheus-plex-exporter
RUN make prometheus-plex-exporter GOOS=${TARGETOS} GOARCH=${TARGETARCH} BINARY=./bin/prometheus-plex-exporter

FROM alpine:3.19 as certs
RUN apk --update add ca-certificates

FROM --platform=${TARGETPLATFORM:-linux/amd64} scratch
WORKDIR /app/
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /workspace/bin/prometheus-plex-exporter /prometheus-plex-exporter
USER 65534
ENTRYPOINT ["/prometheus-plex-exporter"]

