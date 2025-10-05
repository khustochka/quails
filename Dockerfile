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

ARG RUBY_VERSION=3.4.6
ARG VARIANT=slim-bookworm
FROM ruby:${RUBY_VERSION}-${VARIANT} AS base

ARG NODE_VERSION=22.19.0
ARG YARN_VERSION=1.22.19
# ARG BUNDLER_VERSION=2.3.25

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

ARG BUNDLE_WITHOUT=development:test
ARG BUNDLE_PATH=vendor/bundle
ENV BUNDLE_PATH=${BUNDLE_PATH}
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT}

RUN mkdir /app
WORKDIR /app

RUN gem update --system --no-document 
RUN bundle config set deployment true
# gem install -N bundler -v ${BUNDLER_VERSION}

#######################################################################

# install packages only needed at build time

FROM base AS build_deps

ARG BUILD_PACKAGES="git build-essential libpq-dev wget curl gzip xz-utils libsqlite3-dev libssl-dev libyaml-dev"
ENV BUILD_PACKAGES=${BUILD_PACKAGES}

RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y ${BUILD_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

#######################################################################

# install gems

FROM build_deps AS gems

# Create this directory because it is is not created when the rubygems version is the latest
RUN mkdir -p /usr/local/bundle

COPY Gemfile* ./
RUN bundle install && rm -rf vendor/bundle/ruby/*/cache

# Remove unnecessary musl build
RUN rm -rf /app/vendor/bundle/ruby/3.4.0/gems/libdatadog-*-linux/vendor/libdatadog-*/*-linux-musl/
RUN rm -rf /app/vendor/bundle/ruby/3.4.0/gems/libdatadog-*-linux/vendor/libdatadog-*/*-linux/libdatadog-*-unknown-linux-gnu/LICENSE-3rdparty.yml

#######################################################################

# install node modules and build assets

FROM gems AS assets

RUN  --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install --no-install-recommends -y  nodejs \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN npm install --global yarn    

COPY package*json ./
COPY yarn.* ./
RUN yarn install --check-files --frozen-lockfile --production

COPY . .

# The following enable assets to precompile on the build server. 
ENV SECRET_KEY_BASE=1
ENV NODE_ENV=production

ARG BUILD_COMMAND="bin/rails assets:precompile"
RUN ${BUILD_COMMAND} && rm -rf /app/tmp/cache/assets

#######################################################################

# install deployment packages

FROM base

# Labels 
ARG GIT_REVISION=unspecified
ARG GIT_REPOSITORY_URL=unspecified
LABEL org.opencontainers.image.title="quails"
LABEL org.opencontainers.image.revision=$GIT_REVISION
LABEL org.opencontainers.image.source=$GIT_REPOSITORY_URL

ENV GIT_REVISION=${GIT_REVISION}
ENV GIT_REPOSITORY_URL=${GIT_REPOSITORY_URL}
ENV DD_TAGS="git.repository_url:${GIT_REPOSITORY_URL},git.commit.sha:${GIT_REVISION}"

# ARG DEPLOY_PACKAGES="postgresql-client file vim curl gzip bzip2 htop net-tools bind9-dnsutils"
ARG DEPLOY_PACKAGES="libvips42 libjpeg62-turbo-dev postgresql-client file curl gzip bzip2 net-tools netcat-openbsd bind9-dnsutils procps libjemalloc2"
# ENV DEPLOY_PACKAGES=${DEPLOY_PACKAGES}

RUN set -x \
    && groupadd --system --gid 101 quails \
    && useradd --system --gid quails --no-create-home --home /nonexistent --comment "quails user" --shell /bin/false --uid 101 quails
    
RUN --mount=type=cache,id=prod-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=prod-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    ${DEPLOY_PACKAGES} \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV LD_PRELOAD="libjemalloc.so.2"
ENV MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true,stats_print:false"
ENV RUBY_YJIT_ENABLE="1"

# copy with installed gems (in vendor folder)
COPY --from=gems /app/vendor/bundle /app/vendor/bundle
# commented out after switch from fullstaq. Explore if this is needed.
# COPY --from=gems /usr/local/bin/ruby /usr/local/bin/ruby
# COPY --from=gems /usr/local/bundle /usr/local/bundle

# copy precompiled assets
COPY --from=assets /app/public/assets /app/public/assets

# Install supercronic (disabled)

# Latest releases available at https://github.com/aptible/supercronic/releases
# ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
#     SUPERCRONIC=supercronic-linux-amd64 \
#     SUPERCRONIC_SHA1SUM=cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b

# RUN curl -fsSLO "$SUPERCRONIC_URL" \
#  && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
#  && chmod +x "$SUPERCRONIC" \
#  && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
#  && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

#######################################################################

# Deploy your application
COPY . .

# # Adjust binstubs to run on Linux and set current working directory
# # This seems unnecessary
# # RUN chmod +x /app/bin/* && \
# #     sed -i 's/ruby.exe/ruby/' /app/bin/* && \
# #     sed -i '/^#!/aDir.chdir File.expand_path("..", __dir__)' /app/bin/*


RUN mkdir -p /app/public_static

RUN chown -R 101:101 /app/storage
RUN chown -R 101:101 /app/tmp
RUN chown -R 101:101 /app/public
RUN chown -R 101:101 /app/public_static

VOLUME ["/app/storage"]
VOLUME ["/app/tmp"]
VOLUME ["/app/public_static"]

# Adopted from bitnami/nginx image 
# Left for compatibility
RUN chmod -R g+rwX /app/tmp   
# RUN chmod g+rwX /app/tmp/pids
RUN chmod -R g+rwX /app/storage
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

USER 101

ENV PORT=3000
# Port is not exposed, and the command is not `rails server`, because this image can be used
# for background job workers etc

CMD ["/bin/bash"]
