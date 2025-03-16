# Use openjdk image to build the application
FROM openjdk:21 as builder

# Set the working directory and copy the application code
WORKDIR /usr/src/myapp
COPY . .

# Build the application with Maven
RUN ./mvnw clean package

# Now we will use the official Tomcat image to deploy the WAR file
FROM tomcat:9.0

# Remove the default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the builder stage to the Tomcat webapps directory
COPY --from=builder /usr/src/myapp/target/jpetstore.war /usr/local/tomcat/webapps/

# Expose port 8080 for the Tomcat container
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
