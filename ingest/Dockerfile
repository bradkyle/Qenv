FROM thorad/kdb32
RUN mkdir -p /home/ingest
RUN mkdir -p /home/ingest/data
WORKDIR /home/ingest
ADD . /home/ingest
CMD ["q", "ingest.q"]
