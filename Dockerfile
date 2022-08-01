ARG RUBY_VERSION=3.1.2
ARG PG_MAJOR=14
FROM ruby:${RUBY_VERSION}-alpine AS quails-base

RUN gem update --system

WORKDIR /app
COPY . /app

ENV RAILS_ENV=production DOCKER_ENV=1 RAILS_LOG_TO_STDOUT=1
ENV BUNDLE_WITHOUT=development:test BUNDLE_FROZEN=1
RUN apk update && \
    apk add --no-cache tzdata postgresql-libs imagemagick && \
	apk add --no-cache --virtual .build-depends build-base postgresql${PG_MAJOR}-dev  && \
    bundle install && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf /usr/local/bundle/bundler/gems/*/.git && \
    find /usr/local/bundle/gems/ -name '*.c' -delete && \
    find /usr/local/bundle/gems/ -name '*.o' -delete && \
    rm -rf /root/src /tmp/* /usr/share/man /var/cache/apk/* && \
    apk --purge del .build-depends

ARG GIT_COMMIT=unspecified
LABEL org.opencontainers.image.revision=$GIT_COMMIT
ENV GIT_REVISION=$GIT_COMMIT

RUN echo $GIT_COMMIT > REVISION


FROM quails-base AS builder

# SECRET_KEY_BASE is required to load the env (rake), but does not affect the asset compilation output.
RUN apk --no-cache add nodejs yarn && \
    bin/yarn install --check-files --frozen-lockfile && \
    SECRET_KEY_BASE=1 bin/rake assets:precompile && \
    apk --purge del yarn nodejs

FROM quails-base AS quails-app

COPY --from=builder /app/public/assets /app/public/assets
COPY --from=builder /app/public/packs /app/public/packs

ENV PORT=3000
EXPOSE ${PORT}

CMD ["/bin/sh"]
