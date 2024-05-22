#!/bin/bash

gem install ruby-lsp foreman --no-document

bin/setup

RAILS_ENV=test bin/rails db:prepare
