ARG RUBY_VERSION=3.0.1
FROM ruby:${RUBY_VERSION}-alpine AS quails-app

WORKDIR /app
COPY . /app

ENV RAILS_ENV=production DOCKER_ENV=1 RAILS_LOG_TO_STDOUT=1
ENV BUNDLE_WITHOUT=development:test:webkit BUNDLE_FROZEN=1
RUN apk update && \
    apk add --no-cache tzdata postgresql-libs imagemagick && \
	apk add --no-cache --virtual .build-depends build-base postgresql-dev  && \
    bundle install && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf /root/src /tmp/* /usr/share/man /var/cache/apk/* && \
    apk --purge del .build-depends

#ARG NODE_VERSION=14
#RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
#RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
#RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
#RUN apt-get update && apt-get install -y nodejs yarn
ARG SECRET_KEY_BASE
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}
RUN test -n "${SECRET_KEY_BASE}" || (echo "SECRET_KEY_BASE should be set" && exit 1) && \
    apk --no-cache add nodejs yarn && \
    yarn install --check-files && \
    bin/rake assets:precompile && \
    yarn cache clean && \
    apk del yarn
# Cannot remove nodejs because some useless gems need it.

ARG PORT=3000

EXPOSE ${PORT}
ENV PORT=${PORT}

CMD ["./docker-entrypoint.sh"]
