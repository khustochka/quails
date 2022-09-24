ARG RUBY_VERSION=3.1.2
ARG PG_MAJOR=14
FROM ruby:${RUBY_VERSION} AS quails-base

RUN gem update --system

WORKDIR /app
COPY . /app

ENV RAILS_ENV=production DOCKER_ENV=1 RAILS_LOG_TO_STDOUT=1
ENV BUNDLE_WITHOUT=development:test BUNDLE_FROZEN=1
RUN \
    # apt-get update && \
    # apt-get upgrade -y && \
    # apt-get install libpq-dev imagemagick && \
	# apk add --no-cache --virtual .build-depends build-base postgresql${PG_MAJOR}-dev  && \
    bundle install && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf /usr/local/bundle/bundler/gems/*/.git && \
    find /usr/local/bundle/gems/ -name '*.c' -delete && \
    find /usr/local/bundle/gems/ -name '*.o' -delete && \
    rm -rf /root/src /tmp/* /usr/share/man /var/cache/apt/*

ARG GIT_COMMIT=unspecified
LABEL org.opencontainers.image.revision=$GIT_COMMIT
ENV GIT_REVISION=$GIT_COMMIT

RUN echo $GIT_COMMIT > REVISION


FROM quails-base AS builder

# SECRET_KEY_BASE is required to load the env (rake), but does not affect the asset compilation output.
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
    curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarnkey.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y nodejs yarn && \
    bin/yarn install --check-files --frozen-lockfile && \
    SECRET_KEY_BASE=1 bin/rake assets:precompile && \
    apt-get purge -y yarn nodejs

FROM quails-base AS quails-app

COPY --from=builder /app/public/assets /app/public/assets
COPY --from=builder /app/public/packs /app/public/packs

ENV PORT=3000
EXPOSE ${PORT}

CMD ["/bin/sh"]
