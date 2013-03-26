#require "quails/env"
#
#if Rails.env.production?
#  $announcement = <<-CDATA
#    Это тестовая версия сайта. Оставленные здесь комментарии будут удалены!
#    Оставить пожелания и сообщения об ошибках можно
#    <a href="http://birdwatch.org.ua/2013/03/new-site/">на старом сайте</a>.
#  CDATA
#end

begin
  $revision, $commit = `git log -n 1 --format="%H%n%n%B"`.split("\n\n", 2)
rescue
end
