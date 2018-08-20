### Stage 1: Build
FROM golang:1.9.4 as builder
ENV GOPATH /go
WORKDIR $GOPATH/src/github.com/andrew-dinunzio/watch-examples/testlist
RUN curl https://glide.sh/get | sh
ADD glide.yaml .
ADD glide.lock .
ADD ./ .
RUN glide up -v
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o $GOPATH/bin/testlist .

### Stage 2: Main
FROM scratch
ENV GOPATH /go
EXPOSE 8000
WORKDIR $GOPATH/bin
COPY --from=builder $GOPATH/bin $GOPATH/bin
CMD ["./testlist"]
