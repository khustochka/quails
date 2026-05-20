# syntax = docker/dockerfile:experimental

# Dockerfile used to build a deployable image for a Rails application.
#
# Toolchain and OS packages live in prebuilt images:
#   public.ecr.aws/m7x1i1o0/quails-base   - ruby + runtime packages
#   public.ecr.aws/m7x1i1o0/quails-build  - quails-base + build toolchain + node + yarn
# Built from https://github.com/khustochka/vk-build-images
# To bump Ruby/Node, rebuild those images and update the tags below.

#######################################################################

ARG BASE_IMAGE=public.ecr.aws/m7x1i1o0/quails-base:ruby4.0.4-20260520-200944
ARG BUILD_IMAGE=public.ecr.aws/m7x1i1o0/quails-build:ruby4.0.4-node24.11.0-20260520-200944

#######################################################################

FROM ${BASE_IMAGE} AS base

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

RUN bundle config set deployment true

#######################################################################

# Shared setup for build-time stages: toolchain image + app env/workdir/bundle config.

FROM ${BUILD_IMAGE} AS build_base

ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV}

ARG BUNDLE_WITHOUT=development:test
ARG BUNDLE_PATH=vendor/bundle
ENV BUNDLE_PATH=${BUNDLE_PATH}
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT}

RUN mkdir /app
WORKDIR /app

RUN bundle config set deployment true

#######################################################################

# install gems

FROM build_base AS gems

# Create this directory because it is is not created when the rubygems version is the latest
RUN mkdir -p /usr/local/bundle

COPY Gemfile* ./
RUN bundle install && rm -rf vendor/bundle/ruby/*/cache

# Remove unnecessary musl build
RUN rm -rf /app/vendor/bundle/ruby/4.0.0/gems/libdatadog-*-linux/vendor/libdatadog-*/*-linux-musl/
RUN rm -rf /app/vendor/bundle/ruby/4.0.0/gems/libdatadog-*-linux/vendor/libdatadog-*/*-linux/libdatadog-*-unknown-linux-gnu/LICENSE-3rdparty.yml

#######################################################################

# install node modules and build assets

FROM gems AS assets

COPY package*json ./
COPY yarn.* ./
RUN yarn install --check-files --frozen-lockfile --production

COPY . .

# The following enable assets to precompile on the build server.
ENV SECRET_KEY_BASE=1
ENV NODE_ENV=production

ARG BUILD_COMMAND="bin/rails assets:precompile"
RUN ${BUILD_COMMAND} && rm -rf /app/tmp/cache/assets

RUN rm -rf /app/vendor/bundle/ruby/4.0.0/gems/tailwindcss-ruby-*/exe/*/tailwindcss

#######################################################################

# Deployable image

FROM base

# Labels
ARG GIT_REVISION=unspecified
ARG GIT_REPOSITORY_URL=unspecified
LABEL org.opencontainers.image.title="quails"
LABEL org.opencontainers.image.revision=$GIT_REVISION
LABEL org.opencontainers.image.source=$GIT_REPOSITORY_URL

ENV GIT_REVISION=${GIT_REVISION}
ENV GIT_REPOSITORY_URL=${GIT_REPOSITORY_URL}
# ENV DD_CONTAINER_LABELS_AS_TAGS='{"org.opencontainers.image.source":"git.repository_url","org.opencontainers.image.revision":"git.commit.sha"}'
# Datadog expects repo URL without protocol.
ENV DD_TAGS="git.repository_url:github.com/khustochka/quails git.commit.sha:${GIT_REVISION}"

RUN set -x \
    && groupadd --system --gid 101 quails \
    && useradd --system --gid quails --no-create-home --home /nonexistent --comment "quails user" --shell /bin/false --uid 101 quails

ENV LD_PRELOAD="libjemalloc.so.2"
ENV MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true,stats_print:false"
ENV RUBY_YJIT_ENABLE="1"

# copy with installed gems (in vendor folder). use assets image, since it does not have
# the heavy tailwindcss executable
COPY --from=assets /app/vendor/bundle /app/vendor/bundle
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
