FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY user-service/pom.xml user-service/
COPY product-service/pom.xml product-service/
COPY feedback-service/pom.xml feedback-service/
COPY api-gateway/pom.xml api-gateway/
COPY product-service/src product-service/src
RUN mvn package -pl product-service -am -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/product-service/target/product-service-*.war app.war
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.war"]
