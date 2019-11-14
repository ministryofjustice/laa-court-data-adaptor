FROM ruby:2.6.3-alpine
MAINTAINER crime apps team

# fail early and print all commands
RUN set -ex

# build dependencies:
# - virtual: create virtual package for later deletion
# - build-base for alpine fundamentals
# - postgresql-dev for pg/activerecord gems
# - tzdata for timezone data
# - git for installing gems referred to use a git:// uri
#
RUN apk --no-cache add --virtual build-dependencies \
                    build-base \
                    postgresql-dev \
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

COPY Gemfile* ./

RUN gem install bundler -v 2.0.2 \
&& bundle install --deployment --without development test

####################
# DEPENDENCIES END #
####################

ENV RAILS_ENV production
ENV NODE_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
EXPOSE 3000

COPY . .

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup app config log tmp db

USER 1000
CMD "./docker/run"
