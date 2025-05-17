ARG RUBY_VERSION=3.4.4
ARG VARIANT=slim-bookworm
FROM ruby:${RUBY_VERSION}-${VARIANT} AS base

# Install Rails
# RUN su vscode -c "gem install rails webdrivers"
# RUN su vscode -c "/usr/local/rvm/bin/rvm fix-permissions"

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains 
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git ssh \
    # for system tests
    firefox-esr \
    build-essential libpq-dev wget curl gzip ragel \
    xz-utils libsqlite3-dev libssl-dev libyaml-dev \ 
    # deploy packages
    libvips42 postgresql-client file bzip2 net-tools bind9-dnsutils procps


# [Optional] Uncomment this line to install additional gems.
# RUN su vscode -c "gem install <your-gem-names-here>"

# RUN gem install solargraph

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

ARG NODE_VERSION=22.15.1
ARG YARN_VERSION=1.22.19

RUN  --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
     --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install --no-install-recommends -y  nodejs \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN npm install --global yarn  

# Setup Firefox to do system testing.
# RUN add-apt-repository ppa:mozillateam/ppa
# RUN echo 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' | sudo tee /etc/apt/preferences.d/mozilla-firefox
# RUN apt update
# RUN apt -y install firefox
