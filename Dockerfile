##########################
## Builder Container
##########################
FROM golang:1.14.6-alpine3.12 as builder

WORKDIR /go/src/github.com/line-bot

COPY . .

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

RUN go build -o app main.go


##########################
## Application Container
##########################
FROM alpine

RUN apk add --no-cache ca-certificates

COPY --from=builder /go/src/github.com/line-bot/app /app

ENTRYPOINT ["/app"]
