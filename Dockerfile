FROM openjdk:17

WORKDIR /app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Corrige permissão do mvnw
RUN chmod +x mvnw

RUN ./mvnw package -DskipTests

ARG JAR_FILE=target/*.jar

CMD java -jar target/*.jar
