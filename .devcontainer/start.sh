#!/bin/bash

gem install solargraph --no-document

bin/setup

RAILS_ENV=test bin/rails db:prepare
