ARG RUBY_VERSION=3.0.1
FROM ruby:${RUBY_VERSION}-alpine AS quails-source

WORKDIR /app
COPY . /app

ENV RAILS_ENV=production DOCKER_ENV=1 BUNDLE_WITHOUT=development:test:webkit BUNDLE_FROZEN=1
RUN apk update && \
    apk add --no-cache tzdata postgresql-libs imagemagick && \
	apk add --no-cache --virtual .build-depends build-base postgresql-dev  && \
    bundle install && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf /root/src /tmp/* /usr/share/man /var/cache/apk/* && \
    apk --purge del .build-depends

FROM quails-source AS quails-resque

ARG QUEUE_PREFIX=quails_production

ENV COUNT=1
ENV INTERVAL=5
ENV QUEUE=${QUEUE_PREFIX}_default,${QUEUE_PREFIX}_*

# Some gems require JS runtime
RUN apk add --no-cache nodejs

CMD ["bin/rake", "resque:workers"]
