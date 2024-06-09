FROM eclipse-temurin:17-jre-alpine

COPY target/dev-app-1-0.0.1-SNAPSHOT.jar /app/dev-app-1-0.0.1-SNAPSHOT.jar

EXPOSE 8080

CMD ["java", "-jar", "/app/dev-app-1-0.0.1-SNAPSHOT.jar"]