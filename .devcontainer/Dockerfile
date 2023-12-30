ARG RUBY_VERSION=3.2.2
ARG VARIANT=jemalloc-bookworm-slim
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-${VARIANT}

# Install Rails
# RUN su vscode -c "gem install rails webdrivers"
# RUN su vscode -c "/usr/local/rvm/bin/rvm fix-permissions"

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains 
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git ssh \
    # to install firefox
    software-properties-common python3-launchpadlib \
    build-essential libpq-dev wget curl gzip \
    xz-utils libsqlite3-dev libssl-dev libyaml-dev

# [Optional] Uncomment this line to install additional gems.
# RUN su vscode -c "gem install <your-gem-names-here>"

# RUN gem install solargraph

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1

ARG NODE_VERSION=18.17.0
ARG YARN_VERSION=1.22.19
RUN curl https://get.volta.sh | bash
ENV VOLTA_HOME /root/.volta
ENV PATH $VOLTA_HOME/bin:/usr/local/bin:$PATH
RUN volta install node@${NODE_VERSION} yarn@${YARN_VERSION}

# Setup Firefox to do system testing.
# RUN add-apt-repository ppa:mozillateam/ppa
# RUN echo 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' | sudo tee /etc/apt/preferences.d/mozilla-firefox
# RUN apt update
# RUN apt -y install firefox
