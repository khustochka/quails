# frozen_string_literal: true

module Seeds
  class Table
    def initialize(name)
      @table_name = name
      @quoted_table_name = ActiveRecord::Base.connection.quote_table_name(name)
    end

    def cleanup
      ActiveRecord::Base.connection.execute("DELETE FROM #@quoted_table_name")
    end

    def fill(column_names, records)
      columns = column_names.map { |cn| ActiveRecord::Base.connection.columns(@table_name).detect { |c| c.name == cn } }

      quoted_column_names = column_names.map { |column| ActiveRecord::Base.connection.quote_column_name(column) }.join(",")

      records.each_slice(1000) do |bunch|
        quoted_values = bunch.map { |rec| "(#{rec.map { |v| ActiveRecord::Base.connection.quote(v) }.join(",")})" }.join(",")
        ActiveRecord::Base.connection.execute("INSERT INTO #@quoted_table_name (#{quoted_column_names}) VALUES #{quoted_values}")
      end
    end

    def dump(io)
      column_names = table_column_names
      klass = @table_name.singularize.camelize.constantize
      records = ActiveRecord::Base.connection.select_rows(klass.order(:id).to_sql)

      io.write("\n")
      io.write({ @table_name => { "columns" => column_names, "records" => records } }.to_yaml)
    end

    def reset_pk_sequence!
      if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
        ActiveRecord::Base.connection.reset_pk_sequence!(@table_name)
      end
    end

    private

    def table_column_names
      ActiveRecord::Base.connection.columns(@table_name).map { |c| c.name }
    end
  end
end
