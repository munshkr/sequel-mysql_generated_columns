# sequel-mysql_generated_columns [![Build Status](https://travis-ci.org/munshkr/sequel-mysql_generated_columns.svg?branch=master)](https://travis-ci.org/munshkr/sequel-mysql_generated_columns)

Sequel extension that adds support for MySQL generated columns (added first on
MySQL 5.7.5).

When enabled, use `#generated_column` method on `DB#create_table` blocks, and
`#add_generated_column` method on `DB#alter_table` blocks.

## Example

```ruby
create_table(:triangles) do
  Integer :a
  Integer :b
  generated_column :c, Integer, :sqrt.sql_function(:a*:a + :b*:b)
end
```

```sql
CREATE TABLE `triangles` (
  `a` integer,
  `b` integer,
  `c` integer AS (sqrt(((`a` * `a`) + (`b` * `b`))))
)
```

```ruby
create_table(:docs) do
  json :doc
end

alter_table(:docs) do
  add_generated_column :id, Integer, :json_extract.sql_function(:doc, '$.id'), primary_key: true, stored: true
end
```

```sql
CREATE TABLE `documents` (`doc` json)
ALTER TABLE `documents` ADD COLUMN `name` integer AS (json_extract(`doc`, '$.id')) STORED PRIMARY KEY
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

Use `#generated_column(name, type, expression, opts)` or
`#add_generated_column(name, type, expression, opts)` on `create_table` and
`alter_table` blocks respectively.

Possible options:

* `:stored`: Whether generated column will be STORED or VIRTUAL. By default it
  omits the STORED keyword, so this means generated column will be a virtual
  column.

* `:unique`: Whether to add a unique constraint or not. By default it omits the
  UNIQUE KEY keyword.

* `:null`: Allow null values or not. By default it omits keyword, meaning it
  falls back to database default.

* `:primary_key`: If column has a primary key or not. By default it omits the
  keyword PRIMARY KEY.

* `:index`: Whether to create an index after adding column or not. Same
  arguments as `:index` option in conventional `#add_column`.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

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
