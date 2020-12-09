FROM kdb32

RUN mkdir -p /home/impala
WORKDIR /home/qenv
ADD . /home/qenv
CMD ["q", "server.q"]
