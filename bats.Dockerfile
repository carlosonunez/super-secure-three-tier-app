FROM alpine:3.19
RUN apk update --no-cache
RUN apk add bats jq curl aws-cli kubectl ncurses openssh netcat-openbsd docker-cli
ENTRYPOINT [ "bats", "-p", "-r", "--print-output-on-failure"]
