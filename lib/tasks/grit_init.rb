require 'grit'

# Necessary on Windows in order to find git binary
Grit::Git.git_binary ||= ENV['PATH'].split(";").
    map { |p| File.join(p, 'git.exe') }.
    find { |p| File.exist?(p) }