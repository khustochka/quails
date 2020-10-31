# frozen_string_literal: true

desc "Init application. Copy necessary configuration files"
multitask init: ["config/database.yml"]

file "config/database.yml" do
  system "erb config/database.sample.yml > config/database.yml"
end
