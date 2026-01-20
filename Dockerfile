# Multi-stage build for Java Maven application
FROM maven:3.9-eclipse-temurin-11 AS builder

WORKDIR /app

# Copy pom.xml and download dependencies (layer caching)
COPY pom.xml .
RUN mvn dependency:resolve

# Copy source code
COPY src ./src

# Build application
RUN mvn clean package -DskipTests

# Final stage - runtime image
FROM eclipse-temurin:11-jre-alpine

WORKDIR /app

# Install curl for health checks
RUN apk add --no-cache curl

# Copy JAR from builder
COPY --from=builder /app/target/simple-app-*.jar app.jar

# Add build metadata
ARG BUILD_NUMBER=unknown
ARG GIT_COMMIT=unknown
LABEL build.number="${BUILD_NUMBER}" \
      git.commit="${GIT_COMMIT}" \
      maintainer="DevOps Team"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Expose port (adjust if your app uses different port)
EXPOSE 8080

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
CMD ["--server.port=8080"]
