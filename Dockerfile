FROM kdb32

COPY . .
EXPOSE 5000
CMD q server.q -p 5000
  
