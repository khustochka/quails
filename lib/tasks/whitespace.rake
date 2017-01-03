# See https://gist.github.com/NARKOZ/1179915
namespace :whitespace do

  EXCLUDE = "-e '.git/' -e '.idea/' -e 'public/' -e 'db/seed' -e 'vendor/' -e '.png' -e 'log/' -e 'tmp/' -e 'coverage'"

  desc 'Removes trailing whitespace'
  task :cleanup do
    sh %{for f in `find . -type f | grep -v #{EXCLUDE}`;
          do sed -i 's/[ \t]*$//' $f; echo -n .;
        done}
  end
  desc 'Converts hard-tabs into two-space soft-tabs'
  task :retab do
    sh %{for f in `find . -type f | grep -v #{EXCLUDE}`;
          do sed -i 's/\t/  /g' $f; echo -n .;
        done}
  end
  desc 'Remove consecutive blank lines'
  task :scrub_gratuitous_newlines do
    sh %{for f in `find . -type f | grep -v #{EXCLUDE}`;
          do sed -i '/./,/^$/!d' $f; echo -n .;
        done }
  end

  desc 'Add newline to file end'
  task :newline do
    sh %{for f in `find . -type f | grep -v #{EXCLUDE}`;
          do sed -i -e '$a\\' $f; echo -n .;
        done}
  end

end
