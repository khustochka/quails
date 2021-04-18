ARG RUBY_VERSION=3.0.1
FROM ruby:${RUBY_VERSION}-alpine AS quails-source

WORKDIR /app
COPY . /app

ENV RAILS_ENV=production DOCKER_ENV=1 BUNDLE_WITHOUT=development:test:webkit BUNDLE_FROZEN=1
RUN apk update && \
    apk add --no-cache tzdata postgresql-libs && \
	apk add --no-cache --virtual .build-depends build-base postgresql-dev  && \
    bundle install && \
    rm -rf /usr/local/bundle/cache && \
    rm -rf /root/src /tmp/* /usr/share/man /var/cache/apk/* && \
    apk --purge del .build-depends

FROM quails-source AS quails-app

#ARG NODE_VERSION=14
#RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
#RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
#RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
#RUN apt-get update && apt-get install -y nodejs yarn
RUN apk --no-cache add nodejs yarn && \
    yarn install --check-files && \
    bin/rake assets:precompile && \
    yarn cache clean && \
    apk del yarn
# Cannot remove nodejs because some useless gems need it.

ARG PORT=3000

EXPOSE ${PORT}
ENV PORT=${PORT}

CMD ["./docker-entrypoint.sh"]
