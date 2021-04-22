# chglog

[![Current Tag](https://img.shields.io/github/v/tag/dronehippie/chglog?sort=semver)](https://github.com/dronehippie/chglog) [![Build Status](http://drone.webhippie.de/api/badges/dronehippie/chglog/status.svg)](http://drone.webhippie.de/api/badges/dronehippie/chglog) [![Join the Matrix chat at https://matrix.to/#/#webhippie:matrix.org](https://img.shields.io/badge/matrix-%23webhippie-7bc9a4.svg)](https://matrix.to/#/#webhippie:matrix.org) [![Docker Size](https://img.shields.io/docker/image-size/dronehippie/chglog/latest)](https://hub.docker.com/r/dronehippie/chglog) [![Docker Pulls](https://img.shields.io/docker/pulls/dronehippie/chglog)](https://hub.docker.com/r/dronehippie/chglog) [![Go Reference](https://pkg.go.dev/badge/github.com/dronehippie/chglog.svg)](https://pkg.go.dev/github.com/dronehippie/chglog) [![Go Report Card](https://goreportcard.com/badge/github.com/dronehippie/chglog)](https://goreportcard.com/report/github.com/dronehippie/chglog) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/537dffe8966d41b287e043ef8586fd3d)](https://www.codacy.com/gh/dronehippie/chglog/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=dronehippie/chglog&amp;utm_campaign=Badge_Grade)

Drone plugin to generate conventional commit changelogs. For the usage information and a listing of the available options please take a look at the [documentation](https://dronehippie.github.io/chglog/).

## Build

Build the binary with the following command:

```console
export GOOS=linux
export GOARCH=amd64

make build
```

## Docker

Build the image with the following command:

```console
docker build \
  --label org.opencontainers.image.source=https://github.com/dronehippie/chglog \
  --label org.opencontainers.image.revision=$(git rev-parse --short HEAD) \
  --label org.opencontainers.image.created=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
  --file docker/Dockerfile.amd64 --tag dronehippie/chglog .
```

## Usage

```console
docker run --rm \
  -e PLUGIN_DUMMY="dummy" \
  -v $(pwd):$(pwd) \
  -w $(pwd) \
  dronehippie/chglog
```

## Security

If you find a security issue please contact [thomas@webhippie.de](mailto:thomas@webhippie.de) first.

## Contributing

Fork -> Patch -> Push -> Pull Request

## Authors

-   [Thomas Boerger](https://github.com/tboerger)

## License

Apache-2.0

## Copyright

```console
Copyright (c) 2021 Thomas Boerger <thomas@webhippie.de>
```
