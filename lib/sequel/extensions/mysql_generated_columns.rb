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

      # Additional methods for the create_table generator to support constraint validations.
      module CreateTableGeneratorMethods
        def generated_column(name, type, expr, opts={})
          index_opts = opts.delete(:index)
          columns << {:name => name, :type => type, :expr => expr, :gen => true}.merge!(opts)
          if index_opts
            index(name, index_opts.is_a?(Hash) ? index_opts : {})
          end
        end
      end

      # Additional methods for the alter_table generator to support constraint validations,
      # used to give it a more similar API to the create_table generator.
      module AlterTableGeneratorMethods
        include CreateTableGeneratorMethods

        # Add a generated column with the given name, type, and opts to the DDL for the table.
        #
        #   add_generated_column(:name, String, Sequel.function(:sum, :a, :b)) # ADD COLUMN name varchar(255) AS (SUM(a, b))
        def add_generated_column(name, type, expr, opts={})
          @operations << {:op => :add_column, :name => name, :type => type, :expr => expr, :gen => true}.merge!(opts)
        end
      end

      # Modify the default create_table generator to include
      # the generated columns methods.
      def create_table_generator(&block)
        super do
          extend CreateTableGeneratorMethods
          @generated_columns = []
          instance_eval(&block) if block
        end
      end

      # Modify the default alter_table generator to include
      # the generated columns methods.
      def alter_table_generator(&block)
        super do
          extend AlterTableGeneratorMethods
          instance_eval(&block) if block
        end
      end

      # Modify column definition generator method to support generated columns
      def column_definition_sql(column)
        if column[:gen]
          sql = String.new
          sql << "#{quote_identifier(column[:name])} #{type_literal(column)}"
          sql << " AS (#{literal(column[:expr])})"
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
