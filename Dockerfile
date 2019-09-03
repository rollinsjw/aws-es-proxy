FROM golang:1.9-alpine

WORKDIR /go/src/github.com/abutaha/aws-es-proxy
COPY . .

RUN apk add --update bash curl git && \
    rm /var/cache/apk/*
RUN apk add --update make
RUN apk --no-cache --no-progress add --virtual build-deps build-base linux-pam-dev
RUN git clone https://github.com/Masterminds/glide ${GOPATH}/src/github.com/Masterminds/glide && \
    cd ${GOPATH}/src/github.com/Masterminds/glide && \
    make build && \
    go install
RUN apk add --no-cache su-exec
RUN  cd /go/src/github.com/abutaha/aws-es-proxy && \
     glide install 

RUN CGO_ENABLED=0 && GOOS=linux && go build -o aws-es-proxy


FROM alpine:3.7
LABEL name="aws-es-proxy" \
      version="latest"

RUN apk --no-cache add ca-certificates
WORKDIR /home/
COPY --from=0 /go/src/github.com/abutaha/aws-es-proxy/aws-es-proxy /usr/local/bin/

ENV PORT_NUM 9200
EXPOSE ${PORT_NUM}

ENTRYPOINT ["aws-es-proxy"] 
CMD ["-h"]
