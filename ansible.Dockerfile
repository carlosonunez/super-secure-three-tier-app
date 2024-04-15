FROM alpine:3.19
RUN apk update --no-cache
RUN apk add ansible openssh git py3-pip aws-cli kubectl docker-cli helm
RUN pip3 install kubernetes --break-system-packages
ENTRYPOINT [ "ansible-playbook" ]
