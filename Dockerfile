FROM ruby:2.7.5-alpine3.13
MAINTAINER crime apps team

# fail early and print all commands
RUN set -ex

# build dependencies:
# - virtual: create virtual package for later deletion
# - build-base for alpine fundamentals
# - postgresql-dev for pg/activerecord gems
# - postgresql-client for pg_dump, as we need to use sql schema_format
# - tzdata for timezone data
# - git for installing gems referred to use a git:// uri
#
RUN apk --no-cache add --virtual build-dependencies \
                    build-base \
                    postgresql-dev \
                    postgresql-client \
                    tzdata \
                    git

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

# create app directory in conventional, existing dir /usr/src
RUN mkdir -p /usr/src/app && mkdir -p /usr/src/app/tmp/pids
WORKDIR /usr/src/app

######################
# DEPENDENCIES START #
######################

COPY Gemfile* ./

RUN gem install bundler:2.2.28
RUN bundle config set --local deployment 'true' without 'development:test' && bundle install --jobs 4

####################
# DEPENDENCIES END #
####################

# expect and set ping environment variables
ARG COMMIT_ID
ENV COMMIT_ID=${COMMIT_ID}
ARG BUILD_DATE
ENV BUILD_DATE=${BUILD_DATE}
ARG BUILD_TAG
ENV BUILD_TAG=${BUILD_TAG}
ARG APP_BRANCH
ENV APP_BRANCH=${APP_BRANCH}

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
EXPOSE 3000

COPY . .

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup app config log tmp db coverage spec

USER 1000
CMD "./docker/run"
