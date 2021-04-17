#!/bin/sh

# If migration fails create the DB
bin/rake db:migrate || bin/rake db:setup && puma -C config/puma.rb
