#
# Docker image build script for Soundstorm
#

# Use latest Ruby
FROM ruby:2.5.3

# Install system dependencies
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -y build-essential libpq-dev nodejs yarn

# Set the $RAILS_ENV externally, defaults to "development"
ARG RAILS_ENV="development"

# Set the $RAILS_MASTER_KEY externally for opening the credentials file
ARG RAILS_MASTER_KEY

# Set up environment
ENV BUNDLE_PATH=/gems \
    BUNDLE_BIN=/gems/bin \
    APP_PATH=/srv \
    PATH=/usr/local/bundle/bin:/srv/bin:/gems/bin:$PATH

# Copy in application code
RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH
COPY . $APP_PATH

# Install application dependencies.
RUN  [ $RAILS_ENV == "production" ] && \
      ./bin/bundle --path=/gems --quiet && \
      ./bin/yarn --module-path=/node_modules --silent
ENTRYPOINT ["sh", "bin/entrypoint.sh"]
