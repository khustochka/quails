# syntax = docker/dockerfile:experimental

# Dockerfile used to build a deployable image for a Rails application.
# Adjust as required.
#
# Common adjustments you may need to make over time:
#  * Modify version numbers for Ruby, Bundler, and other products.
#  * Add library packages needed at build time for your gems, node modules.
#  * Add deployment packages needed by your application
#  * Add (often fake) secrets needed to compile your assets

#######################################################################

# Learn more about the chosen Ruby stack, Fullstaq Ruby, here:
#   https://github.com/evilmartians/fullstaq-ruby-docker.
#
# We recommend using the highest patch level for better security and
# performance.

ARG RUBY_VERSION=3.3.0
ARG VARIANT=jemalloc-bookworm-slim
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-${VARIANT} as base

ARG NODE_VERSION=18.17.0
ARG YARN_VERSION=1.22.19
# ARG BUNDLER_VERSION=2.3.25

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ARG BUNDLE_WITHOUT=development:test
ARG BUNDLE_PATH=vendor/bundle
ENV BUNDLE_PATH ${BUNDLE_PATH}
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}

RUN mkdir /app
WORKDIR /app
RUN mkdir -p tmp/pids

ARG GIT_REVISION=unspecified
LABEL org.opencontainers.image.revision=$GIT_REVISION
ENV GIT_REVISION ${GIT_REVISION}

#######################################################################

# install packages only needed at build time

FROM base as build_deps

ARG BUILD_PACKAGES="git build-essential libpq-dev wget curl gzip xz-utils libsqlite3-dev libssl-dev libyaml-dev"
ENV BUILD_PACKAGES ${BUILD_PACKAGES}

RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y ${BUILD_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

#######################################################################

# install gems

FROM build_deps as gems

# Create this directory because it is is not created when the rubygems version is the latest
RUN mkdir -p /usr/local/bundle

RUN gem update --system --no-document 
    # gem install -N bundler -v ${BUNDLER_VERSION}

COPY Gemfile* ./
RUN bundle install && rm -rf vendor/bundle/ruby/*/cache

#######################################################################

# install node modules and build assets

FROM gems as assets

RUN curl https://get.volta.sh | bash
ENV VOLTA_HOME /root/.volta
ENV PATH $VOLTA_HOME/bin:/usr/local/bin:$PATH
RUN volta install node@${NODE_VERSION} yarn@${YARN_VERSION}

COPY package*json ./
COPY yarn.* ./
RUN yarn install --check-files --frozen-lockfile

COPY . .

# The following enable assets to precompile on the build server. 
ENV SECRET_KEY_BASE=1
ENV NODE_ENV=production
# ENV AWS_ACCESS_KEY_ID=1
# ENV AWS_SECRET_ACCESS_KEY=1

ARG BUILD_COMMAND="bin/rails assets:precompile"
RUN ${BUILD_COMMAND} && rm -rf /app/tmp/cache/assets

#######################################################################

# install deployment packages

FROM base

# ARG DEPLOY_PACKAGES="postgresql-client file vim curl gzip bzip2 htop net-tools bind9-dnsutils"
ARG DEPLOY_PACKAGES="imagemagick postgresql-client file curl gzip bzip2 net-tools bind9-dnsutils procps"
# ENV DEPLOY_PACKAGES=${DEPLOY_PACKAGES}

RUN --mount=type=cache,id=prod-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=prod-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    ${DEPLOY_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# copy installed gems
COPY --from=gems /app /app
COPY --from=gems /usr/lib/fullstaq-ruby/versions /usr/lib/fullstaq-ruby/versions
COPY --from=gems /usr/local/bundle /usr/local/bundle

# copy precompiled assets
COPY --from=assets /app/public/assets /app/public/assets

#######################################################################

# Deploy your application
COPY . .

# Adjust binstubs to run on Linux and set current working directory
RUN chmod +x /app/bin/* && \
    sed -i 's/ruby.exe/ruby/' /app/bin/* && \
    sed -i '/^#!/aDir.chdir File.expand_path("..", __dir__)' /app/bin/*

ENV PORT 3000
# Port is not exposed, and the command is not `rails server`, because this image can be used
# for resque queues and cron jobs

CMD ["/bin/bash"]
