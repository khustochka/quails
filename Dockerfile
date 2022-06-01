ARG RUBY_VERSION=3.1.2
FROM ruby:${RUBY_VERSION}-alpine AS quails-base

WORKDIR /app
COPY . /app

ENV RAILS_ENV=production DOCKER_ENV=1 RAILS_LOG_TO_STDOUT=1
ENV BUNDLE_WITHOUT=development:test:webkit BUNDLE_FROZEN=1
RUN apk update && \
    apk add --no-cache tzdata postgresql-libs imagemagick && \
	apk add --no-cache --virtual .build-depends build-base postgresql-dev  && \
    bundle install && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf /usr/local/bundle/bundler/gems/*/.git && \
    find /usr/local/bundle/gems/ -name '*.c' -delete && \
    find /usr/local/bundle/gems/ -name '*.o' -delete && \
    rm -rf /root/src /tmp/* /usr/share/man /var/cache/apk/* && \
    apk --purge del .build-depends
RUN apk --no-cache add nodejs


FROM quails-base AS builder

ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}
RUN test -n "${SECRET_KEY_BASE}" || (echo "SECRET_KEY_BASE should be set" && exit 1) && \
    apk --no-cache add yarn && \
    yarn install --check-files && \
    bin/rake assets:precompile
# Cannot remove nodejs because some useless gems need it.

FROM quails-base

COPY --from=builder /app/public/assets /app/public/assets
COPY --from=builder /app/public/packs /app/public/packs

ENV PORT=3000
EXPOSE ${PORT}

CMD ["./docker-entrypoint.sh"]
