require 'spec_helper'

Sequel.extension :core_extensions

describe 'Sequel::Mysql::GeneratedColumns' do
  before do
    @db = Sequel.mock
    @db.extension :mysql_generated_columns
  end

  describe 'DB#create_table' do
    it 'should accept generated column definitions' do
      @db.create_table(:triangles) do
        integer :a
        integer :b
        integer :c, :as => :sqrt.sql_function(:a + :b)
      end
      @db.sqls.must_equal [
        'CREATE TABLE triangles (a integer, b integer, c integer AS (sqrt((a + b))))'
      ]
    end

    describe '#generated_column' do
      it 'should accept a :stored boolean option' do
        @db.create_table(:nums) do
          integer :a
          integer :a2, :as => :a * 2, :stored => true
        end
        @db.sqls.must_equal [
          'CREATE TABLE nums (a integer, a2 integer AS ((a * 2)) STORED)'
        ]
      end

      it 'should accept a :unique boolean option' do
        @db.create_table(:nums) do
          integer :a
          integer :a2, :as => :a * 2, :unique => true
        end
        @db.sqls.must_equal [
          'CREATE TABLE nums (a integer, a2 integer AS ((a * 2)) UNIQUE)'
        ]
      end

      it 'should accept a :null boolean option' do
        @db.create_table(:nums) do
          integer :a
          integer :a2, :as => :a * 2, :null => false
          integer :a3, :as => :a * 3, :null => true
        end
        @db.sqls.must_equal [
          'CREATE TABLE nums (a integer, a2 integer AS ((a * 2)) NOT NULL, a3 integer AS ((a * 3)) NULL)'
        ]
      end

      it 'should accept a :primary_key boolean option' do
        @db.create_table(:nums) do
          integer :a
          integer :a2, :as => :a * 2, :primary_key => true
        end
        @db.sqls.must_equal [
          'CREATE TABLE nums (a integer, a2 integer AS ((a * 2)) PRIMARY KEY)'
        ]
      end

      it 'should accept an :index option, and create an index over the generated column' do
        @db.create_table(:nums) do
          integer :a
          integer :a2, :as => :a * 2, :index => true
        end
        @db.sqls.must_equal [
          'CREATE TABLE nums (a integer, a2 integer AS ((a * 2)))',
          'CREATE INDEX nums_a2_index ON nums (a2)'
        ]
      end
    end
  end

  describe 'DB#alter_table' do
    before do
      @db.create_table(:nums) do
        integer :a
      end
    end

    it 'should accept generated column definitions' do
      @db.alter_table(:nums) do
        add_column :a2, :integer, :as => :a * 2
      end
      @db.sqls.must_equal [
        'CREATE TABLE nums (a integer)',
        'ALTER TABLE nums ADD COLUMN a2 integer AS ((a * 2))'
      ]
    end

    describe '#add_generated_column' do
      it 'should accept the same options that #generated_column does' do
        @db.alter_table(:nums) do
          add_column :a2, :integer, :as => :a * 2, :stored => true, :index => true, :primary_key => true, :null => false, :unique => true
        end
        @db.sqls.must_equal [
          'CREATE TABLE nums (a integer)',
          'ALTER TABLE nums ADD COLUMN a2 integer AS ((a * 2)) STORED UNIQUE NOT NULL PRIMARY KEY'
        ]
      end
    end
  end
end
