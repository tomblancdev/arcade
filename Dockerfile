# L'Arcade — the doorman: one static binary, nothing else in the image.
FROM --platform=$BUILDPLATFORM golang:1.24-alpine AS build
ARG TARGETOS TARGETARCH VERSION=dev
WORKDIR /src
COPY go.mod ./
COPY . .
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w -X main.version=$VERSION" -o /out/arcade ./cmd/arcade

FROM scratch
LABEL org.opencontainers.image.source="https://github.com/tomblancdev/arcade" \
      org.opencontainers.image.description="L'Arcade — the doorman of a home games platform: knock to wake, the play page, the Moonlight relay" \
      org.opencontainers.image.licenses="MIT"
COPY --from=build /out/arcade /arcade
VOLUME ["/data"]
USER 65532:65532
EXPOSE 8080
ENV ARCADE_CONFIG=/etc/arcade/config.yaml ARCADE_DATA_DIR=/data
ENTRYPOINT ["/arcade"]
