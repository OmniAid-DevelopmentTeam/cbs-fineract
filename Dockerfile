FROM eclipse-temurin:21-jdk AS builder

WORKDIR /app

COPY gradlew settings.gradle* build.gradle* gradle.properties ./
COPY gradle ./gradle
RUN chmod +x gradlew

COPY . .

RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew --no-daemon -x test --build-cache --parallel :fineract-provider:bootJar

FROM eclipse-temurin:21-jre

WORKDIR /app
COPY --from=builder /app/fineract-provider/build/libs/fineract-provider*.jar ./fineract-provider.jar
EXPOSE 8080

ENTRYPOINT exec sh -c "java $JAVA_TOOL_OPTIONS -Dloader.path=. -jar fineract-provider.jar"