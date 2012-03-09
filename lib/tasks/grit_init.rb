require 'grit'

Grit::Git.git_binary ||= ENV['PATH'].split(";").
    map { |p| File.join(p, 'git.exe') }.
    find { |p| File.exist?(p) }