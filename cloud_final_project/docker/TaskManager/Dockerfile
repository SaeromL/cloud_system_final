# Use an OpenJDK image
FROM openjdk:17-jdk-slim

# Add the application's JAR file to the container
ADD target/TaskManager-0.0.1-SNAPSHOT.jar app.jar

# Expose port 80 to allow external access
EXPOSE 80

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
