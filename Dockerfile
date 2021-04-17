ARG RUBY_VERSION=3.0.1
FROM ruby:${RUBY_VERSION} AS quails-app

WORKDIR /app

COPY . /app

RUN bundle config set --local without development:test:webkit
RUN bundle config set --local frozen 1
RUN bundle install
RUN rm -rf /usr/local/bundle/cache

ARG NODE_VERSION=14
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y nodejs yarn

RUN yarn install --check-files
RUN yarn cache clean

ENV RAILS_ENV=production
RUN bin/rake assets:precompile

ARG PORT=3000

EXPOSE ${PORT}
ENV PORT=${PORT}

CMD ["puma", "-C", "config/puma.rb"]
