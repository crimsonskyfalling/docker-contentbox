FROM ortussolutions/commandbox:4.5.0

# Labels
LABEL version="@version@"
LABEL maintainer "Jon Clausen <jclausen@ortussolutions.com>"
LABEL maintainer "Luis Majano <lmajano@ortussolutions.com>"
LABEL repository "https://github.com/Ortus-Solutions/docker-contentbox"

# Incoming Secrets/Vars From Build Process
ARG CI_BUILD_NUMBER=1
ARG CI_BUILD_URL=testmode

# Copy over our app resources
COPY ./resources/app/ ${BUILD_DIR}/contentbox-app

# Copy over build scripts
COPY ./build/contentbox-dependencies.sh ${BUILD_DIR}/
COPY ./build/contentbox-cleanup.sh ${BUILD_DIR}/
COPY ./build/contentbox-run.sh ${BUILD_DIR}/

# Make them executable just in case.
RUN chmod +x ${BUILD_DIR}/*.sh

# Install ContentBox and Dependencies
RUN ${BUILD_DIR}/contentbox-dependencies.sh

# ContentBox Run
CMD ${BUILD_DIR}/contentbox-run.sh

# Cleanup
RUN ${BUILD_DIR}/contentbox-cleanup.sh

# Healthcheck environment variables
ENV HEALTHCHECK_URI "http://127.0.0.1:${PORT}/index.cfm"

# Our healthcheck interval doesn't allow dynamic intervals - Default is 20s intervals with 15 retries
HEALTHCHECK --interval=30s --timeout=60s --retries=5 CMD curl --fail ${HEALTHCHECK_URI} || exit 1