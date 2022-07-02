# frozen_string_literal: true

# See https://gist.github.com/NARKOZ/1179915
# requires GNU sed
namespace :whitespace do
  EXCLUDE = [".git",  ".idea", "./public", "./db/seed", "./vendor", "./log", "./tmp", "./coverage", "node_modules"]
  EXCLUDE_STR = EXCLUDE.map {|p| "grep -v #{p} "}.join("| ")

  task :detect_sed do
    # MacOS has BSD version by default, GNU can be installed with brew install gnu-sed as 'gsed'
    # TODO: detect
    @sed = "gsed"
  end

  desc "Removes trailing whitespace"
  task cleanup: :detect_sed do
    sh %{for f in `find . -type f | #{EXCLUDE_STR} | egrep ".(rb|js|haml|html|css|sass)"`;
          do #{@sed} -i 's/[ \t]*$//' $f;
        done}, { verbose: false }
    puts "Task cleanup done"
  end

  desc "Converts hard-tabs into two-space soft-tabs"
  task retab: :detect_sed do
    sh %{for f in `find . -type f | #{EXCLUDE_STR} | egrep ".(rb|js|haml|html|css|sass)"`;
          do #{@sed} -i 's/\t/  /g' $f;
        done}, { verbose: false }
    puts "Task retab done"
  end

  desc "Remove consecutive blank lines"
  task scrub_gratuitous_newlines: :detect_sed do
    sh %{for f in `find . -type f | #{EXCLUDE_STR} | egrep ".(rb|js|haml|html|css|sass)"`;
          do #{@sed} -i '/./,/^$/!d' $f;
        done}, { verbose: false }
    puts "Task scrub_gratuitous_newlines done"
  end

  desc "Add newline to file end"
  task newline: :detect_sed do
    sh %{for f in `find . -type f | #{EXCLUDE_STR} | egrep ".(rb|js|haml|html|css|sass)"`;
          do #{@sed} -i -e '$a\\' $f;
        done}, { verbose: false }
    puts "Task newline done"
  end
end
