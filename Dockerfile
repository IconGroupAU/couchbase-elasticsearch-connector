# Builds an image from the output of the `gradle install` command.
# To build from a pre-built connector distribution, see Dockerfile.download

# Use Red Hat Universal Base Image (UBI) for compatibility with OpenShift
FROM registry.access.redhat.com/ubi8/openjdk-8:latest

ARG CBES_HOME=/opt/couchbase-elasticsearch-connector

# Switch to root to install Git
USER root
RUN microdnf install -y git && microdnf clean all

# Switch back to the original user
USER jboss

COPY --chown=jboss:root . .
# Ensure is a git repo as Gradle requires it
# This is useful for docker-compose git build contexts where the .git directory is not copied
RUN git config --global user.name "jboss"
RUN git config --global user.email "jboss@example.com"
RUN git init && git add . && git commit -m "Commit to appease Gradle"
RUN ./gradlew installDist

# Set owner to jboss to appease the base image.
RUN cp -r build/install/couchbase-elasticsearch-connector $CBES_HOME
VOLUME [ "$CBES_HOME/config", "$CBES_HOME/secrets" ]

ENV PATH="$CBES_HOME/bin:$PATH"
WORKDIR $CBES_HOME

EXPOSE 31415

ENTRYPOINT [ "cbes" ]