FROM alpine:3.12

RUN apk add --no-cache git
RUN apk add --no-cache bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
