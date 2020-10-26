FROM ruby:2.7.2-alpine
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
# Env vars needed for dependency install and asset precompilation
ARG BUNDLE_DEPLOYMENT
ENV BUNDLE_DEPLOYMENT ${BUNDLE_DEPLOYMENT:-true}
ARG BUNDLE_WITHOUT
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT:-'development test'}

COPY Gemfile* ./


RUN gem install bundler:2.1.4 -N \
&& bundle install --path=vendor/bundle

####################
# DEPENDENCIES END #
####################

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
EXPOSE 3000

COPY . .

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup app config log tmp db coverage spec

USER 1000
CMD "./docker/run"
