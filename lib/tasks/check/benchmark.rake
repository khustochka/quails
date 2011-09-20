desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'


    require 'yaml_db'
    local_opts = YAML.load_file('config/local.yml')

    dirname = File.join(local_opts['repo'], 'seed')

    n = 1
    Benchmark.bmbm do |x|

      x.report('old') { n.times {
        SerializationHelper::Base.new(YamlDb::Helper).load_from_dir dirname
      } }

      x.report('new') { n.times {

        Dir.entries(dirname).each do |filename|
          if filename =~ /^\./
            next
          end
          raw = YAML.load(File.new(File.join(dirname, filename), "r")).to_a[0]
          table, data = *raw

          quoted_table_name = ActiveRecord::Base.connection.quote_table_name(table)

          ActiveRecord::Base.connection.execute("DELETE FROM #{quoted_table_name}")

          records = data['records']
          column_names = data['columns']
          columns = column_names.map{|cn| ActiveRecord::Base.connection.columns(table).detect{|c| c.name == cn}}

          quoted_column_names = column_names.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }.join(',')

          records.each_slice(1000) do |bunch|
            quoted_values = bunch.map {|rec| "(#{rec.zip(columns).map{|c| ActiveRecord::Base.connection.quote(c.first, c.last)}.join(',')})"}.join(',')
            ActiveRecord::Base.connection.execute("INSERT INTO #{quoted_table_name} (#{quoted_column_names}) VALUES #{quoted_values}")
          end

          ActiveRecord::Base.connection.reset_pk_sequence!(table)
        end
      } }

    end
  end
end