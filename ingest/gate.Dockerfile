FROM thorad/kdb32
RUN mkdir -p /gate
RUN mkdir -p /gate/config
WORKDIR /gate
ADD gateway.q .
CMD q gateway.q 
