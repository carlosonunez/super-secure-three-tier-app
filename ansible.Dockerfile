FROM alpine:3.19
RUN apk update --no-cache
RUN apk add ansible openssh git
ENTRYPOINT [ "ansible-playbook" ]
