#!/bin/bash

gem install solargraph

bin/setup

RAILS_ENV=test bin/rails db:prepare
