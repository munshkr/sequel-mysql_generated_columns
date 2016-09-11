# sequel-mysql_generated_columns [![Build Status](https://travis-ci.org/munshkr/sequel-mysql_generated_columns.svg?branch=master)](https://travis-ci.org/munshkr/sequel-mysql_generated_columns)

Sequel extension that adds support for MySQL generated columns (added first on
MySQL 5.7.5).

When enabled, it allows passing an SQL expression with the option `:as` to
`#column` and `#add_column` methods, inside `DB#create_table` and
`DB#alter_table` blocks.

## Example

When used in a `create_table` block:

```ruby
create_table(:triangles) do
  integer :a
  integer :b
  integer :c, :as => :sqrt.sql_function(:a*:a + :b*:b)
end
```
This will generate the following SQL statement:

```sql
CREATE TABLE `triangles` (
  `a` integer,
  `b` integer,
  `c` integer AS (sqrt(((`a` * `a`) + (`b` * `b`))))
)
```

In this example, after creating a table with a single JSON column, the next
`alter_table` block:

```ruby
create_table(:docs) do
  json :doc
end

alter_table(:docs) do
  add_column :id, Integer, :as => :json_extract.sql_function(:doc, '$.id'),
                           :stored => true,
                           :primary_key => true
end
```

will add a stored generated column with a primary key over the JSON object
property `id` in from the JSON document stored in column `doc`:

```sql
CREATE TABLE `documents` (`doc` json)
ALTER TABLE `documents` ADD COLUMN `id` integer AS (json_extract(`doc`, '$.id')) STORED PRIMARY KEY
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sequel-mysql_generated_columns'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sequel-mysql_generated_columns


## Usage

To enable extension, call `DB.extension :mysql_generated_columns`.

Use `#column` or `#add_column` with an extra options `:as => expr` where `expr`
is an SQL expression object or a string literal.

Possible options:

* `:stored`: Whether generated column will be STORED or VIRTUAL. By default it
  omits the STORED keyword, so this means generated column will be virtual.

* `:unique`: Whether to add a unique constraint or not. By default it omits the
  UNIQUE KEY keyword.

* `:null`: Allow or disallow null values. By default it omits keyword, meaning
  it falls back to database default.

* `:primary_key`: Whether column has a primary key or not. By default it omits
  the keyword PRIMARY KEY.

* `:index`: Whether to create an index after adding column or not.


## Development

After checking out the repo, install `bundler` with `gem install bundler`, and
run `bundle install` to install dependencies. Then, run `rake test` to run the
tests.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).


## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/munshkr/sequel-mysql_generated_columns.


## License

MIT License

Copyright (c) 2016 Damián Silvani

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
