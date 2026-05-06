FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY user-service/pom.xml user-service/
COPY product-service/pom.xml product-service/
COPY feedback-service/pom.xml feedback-service/
COPY api-gateway/pom.xml api-gateway/
COPY feedback-service/src feedback-service/src
RUN mvn package -pl feedback-service -am -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/feedback-service/target/feedback-service-*.jar app.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "app.jar"]
