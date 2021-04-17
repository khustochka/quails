ARG RUBY_VERSION=3.0.1
FROM ruby:${RUBY_VERSION} AS quails-source

WORKDIR /app

COPY . /app

ENV RAILS_ENV=production
RUN bundle config set --local without development:test:webkit
RUN bundle config set --local frozen 1
RUN bundle install
RUN rm -rf /usr/local/bundle/cache

FROM quails-source AS quails-app

ARG NODE_VERSION=14
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y nodejs yarn

RUN yarn install --check-files
RUN yarn cache clean
RUN bin/rake assets:precompile

ARG PORT=3000

EXPOSE ${PORT}
ENV PORT=${PORT}

CMD ["./.docker/entrypoint.sh"]
