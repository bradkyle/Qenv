FROM thorad/kdb32:latest

COPY . .
EXPOSE 5000
CMD server.q
  
