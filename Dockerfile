FROM alpine as cloner

# Use the main branch by default
ARG HEAD_REF=main

WORKDIR /repository

# Install Git and clone repository
RUN apk add --no-cache git
RUN git clone https://github.com/packwiz/packwiz.git .
RUN git reset --hard ${HEAD_REF}

# Build the binary
FROM golang:1.19 as build

WORKDIR /workspace

# Copy the Go Modules manifests
COPY --from=cloner /repository/go.mod /repository/go.sum ./

# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY --from=cloner /repository/ ./

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o packwiz main.go

# Move binary into final image
FROM alpine as app

WORKDIR /workspace

# Make sure bash is available for next steps
RUN apk add --no-cache bash

COPY --chmod=755 --from=build /workspace/packwiz /usr/local/bin/
COPY --chmod=755 ./scripts/* /

ENTRYPOINT [ "/entrypoint" ]
