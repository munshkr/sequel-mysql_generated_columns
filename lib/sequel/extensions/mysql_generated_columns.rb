module Sequel
  module Mysql
    module GeneratedColumns
      # The order of column modifiers to use when defining a column.
      GENERATED_COLUMN_DEFINITION_ORDER = [:stored, :unique, :null, :primary_key]
      STORED = ' STORED'.freeze
      UNIQUE = ' UNIQUE'.freeze
      NULL = ' NULL'.freeze
      NOT_NULL = ' NOT NULL'.freeze
      PRIMARY_KEY = ' PRIMARY KEY'.freeze

      # Modify column definition generator method to support generated columns
      def column_definition_sql(column)
        if expr = column[:as]
          sql = String.new
          sql << "#{quote_identifier(column[:name])} #{type_literal(column)}"
          sql << " AS (#{literal(expr)})"
          generated_column_definition_order.each{|m| send(:"generated_column_definition_#{m}_sql", sql, column)}
          sql
        else
          super
        end
      end

      # The order of the generated column definition, as an array of symbols.
      def generated_column_definition_order
        GENERATED_COLUMN_DEFINITION_ORDER
      end

      # Add stored SQL fragment to column creation SQL.
      def generated_column_definition_stored_sql(sql, column)
        sql << STORED if column[:stored]
      end

      # Add unique SQL fragment to column creation SQL.
      def generated_column_definition_unique_sql(sql, column)
        sql << UNIQUE if column[:unique]
      end

      # Add null SQL fragment to column creation SQL.
      def generated_column_definition_null_sql(sql, column)
        null = column.fetch(:null, column[:allow_null])
        sql << NOT_NULL if null == false
        sql << NULL if null == true
      end

      # Add unique SQL fragment to column creation SQL.
      def generated_column_definition_primary_key_sql(sql, column)
        sql << PRIMARY_KEY if column[:primary_key]
      end
    end
  end

  Database.register_extension(:mysql_generated_columns, Mysql::GeneratedColumns)
end
