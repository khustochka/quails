module BunchDB
  class Table
    def initialize(name)
      @table_name = name
      @quoted_table_name = ActiveRecord::Base.connection.quote_table_name(name)
    end

    def cleanup
      ActiveRecord::Base.connection.execute("DELETE FROM #{@quoted_table_name}")
    end

    def fill(column_names, records)
      columns = column_names.map { |cn| ActiveRecord::Base.connection.columns(@table_name).detect { |c| c.name == cn } }

      quoted_column_names = column_names.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }.join(',')

      records.each_slice(1000) do |bunch|
        quoted_values = bunch.map { |rec| "(#{rec.zip(columns).map { |c| ActiveRecord::Base.connection.quote(c.first, c.last) }.join(',')})" }.join(',')
        ActiveRecord::Base.connection.execute("INSERT INTO #{@quoted_table_name} (#{quoted_column_names}) VALUES #{quoted_values}")
      end
    end

    def reset_pk_sequence!
      ActiveRecord::Base.connection.reset_pk_sequence!(@table_name)
    end
  end
end