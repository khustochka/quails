class ChangeWikiTagBraces < ActiveRecord::Migration[4.2]
  def up
    ActiveRecord::Base.connection.execute("UPDATE posts SET text = regexp_replace(text, '\\[([^\\]]*)\\]', '{{\\1}}', 'g')")
    ActiveRecord::Base.connection.execute("UPDATE images SET description = regexp_replace(description, '\\[([^\\]]*)\\]', '{{\\1}}', 'g')")
    ActiveRecord::Base.connection.execute("UPDATE comments SET text = regexp_replace(text, '\\[([^\\]]*)\\]', '{{\\1}}', 'g')")
  end

  def down
  end
end
