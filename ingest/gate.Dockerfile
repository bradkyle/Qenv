FROM thorad/kdb32
RUN mkdir -p /gate
WORKDIR /gate
RUN ls /gate
ADD gateway.q /gate
RUN ls
RUN ls /gate
CMD q gateway.q
