FROM golang:1.24-alpine AS build_deps

RUN apk add --no-cache git

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod .
COPY go.sum .

RUN go clean -modcache
RUN go mod download
RUN go mod tidy

FROM build_deps AS build

COPY . .

#RUN CGO_ENABLED=0 go build -o webhook -ldflags '-w -extldflags "-static"' .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o webhook main.go


FROM alpine:3.15

RUN apk add --no-cache ca-certificates

COPY --from=build /workspace/webhook /usr/local/bin/webhook

ENTRYPOINT ["webhook"]
