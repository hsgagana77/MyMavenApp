# ===== STAGE 1: Build the WAR with Maven =====
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml and download dependencies first (for caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source and build WAR
COPY src ./src
RUN mvn clean package -DskipTests

# ===== STAGE 2: Deploy WAR to Tomcat =====
FROM tomcat:9.0-jdk17
WORKDIR /usr/local/tomcat

# Remove default Tomcat webapps
RUN rm -rf webapps/*

# Copy WAR file from Maven build and rename it to ROOT.war
COPY --from=build /app/target/*.war webapps/ROOT.war

# Expose the Tomcat port (default 8080)
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
