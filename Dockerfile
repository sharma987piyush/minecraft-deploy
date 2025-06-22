FROM eclipse-temurin:21-jre 

WORKDIR /server

COPY server.jar /server/
COPY eula.txt /server/

EXPOSE 25565

CMD ["java", "-Xmx6G", "-Xms2G", "-jar", "server.jar", "nogui"]
