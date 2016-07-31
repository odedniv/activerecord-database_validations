# ActiveRecord::DatabaseValidations [![Gem Version](https://badge.fury.io/rb/activerecord-database_validations.svg)](http://badge.fury.io/rb/activerecord-database_validations)

An ActiveRecord extension that lets you use your database validations.

* Converts `ActiveRecord::StatementInvalid` related to database validations on
  `ActiveRecord::Base#save` into a validation error.
* Quickly add pre-save validations according to your database validations.

Currently supports mysql and postgresql. Feel free to [help support
more](#extend-database-support).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-database_validations'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-database_validations

## Usage

This extension is included into `ActiveRecord::Base` automatically, so all you
need to do is use it.


### Pre-save validation

```ruby
# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  username        :string           not null
#  group_id        :integer
#  inviter_id      :integer
#
# Indexes
#
#  index_boards_on_group_id_and_username (group_id,username) UNIQUE
#
# Foreign Keys
#
#  add_foreign_key "users", "users", column: "inviter_id"
#

class User < ActiveRecord::Base
  validates_database
  # This is an alias to (which can be used separately):
  # validates_database_not_null
  # validates_database_unique
  # validates_database_foreign_key
end

# validates_database_not_null
u = User.new
u.valid?
=> false
u.errors.messages
=> { :username => ["can't be blank"] }

# validates_database_unique
u1 = User.new(group_id: 5, username: "somename")
u1.save
=> true
u2 = User.new(group_id: 5, username: "somename")
u2.save
=> false
u2.errors.messages
=> { :username => ["has already been taken"] }

# validates_database_foreign_key
u1 = User.new(username: "anothername", inviter_id: -1)
u1.save
=> false
u1.errors.messages
=> { inviter_id: ["is not included in the list"] }
```

As mentioned above you can use a specific validation type, and any of these
`validates_database*` methods can also receive the `:message` option (and
sometimes other validation options depending on the back-end used to preform
the actual validation).

### On-save validation

You don't really have to do anything but specify the right validations in your
schema (or migrations). On knows database validation errors
`ActiveRecord::Base#save` will return false, `ActiveRecord::Base#save!` will
raise an `ActiveRecord::RecordInvalid`, and `ActiveRecord::Base#errors` will
show the error on the specific field.

### On-save vs pre-save validations

* Pre-save does not handle race conditions (`::validates_database_unique` and
  `::validates_database_foreign_key`). This is the actual reason behind using
  database validations. So between the time the check was made and the time the
  record was saved:
  * There could be an extra record that would make the new record fail the
    unique validation.
  * The referenced record could have been deleted that would make the foreign
    key validation fail.
* On-save only happens if the application validations succeeded. This means you
  will not see the error on the failing field (in `ActiveRecord::Base#errors`).
  That said, it will also only show one error, so if two database validations
  failed only one field will show an error.
* Pre-save does an extra query for `::validates_database_unique` and
  `::validates_database_foreign_key`, so if time is of the essence let the
  on-save validation catch the error, otherwise it's best to add
  the full `::validates_database` to your model.

## Notes

* You do not have any control over on-save validations, the logic is applied if
  you want it or not on every ActiveRecord::Base. If you can think of a reason
  why it shouldn't, please file an
  [issue](https://github.com/odedniv/activerecord-database_validations/issues).
* When the unique index is on multiple columns mysql and postgresql (and maybe
  others) do not fail if any of the columns is nil. With this in mind, the
  error is added on the last column of the index.

## Development

To run the tests you must have a user and a database set up in the supported databases.

As MySQL root:

```sql
CREATE USER 'gemtester'@'localhost';
CREATE DATABASE activerecord_database_validations_test;
GRANT ALL ON `activerecord_database_validations_test`.* TO 'gemtester'@'localhost';
```

As Postgresql root:

```sql
CREATE USER gemtester;
CREATE DATABASE activerecord_database_validations_test;
GRANT ALL PRIVILEGES ON DATABASE activerecord_database_validations_test TO gemtester;
```

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

1. Fork it (https://github.com/odedniv/activerecord-database_validations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Extend database support

This consists of 3 simple steps:

1. Add an adapter gem as a development dependency in
   `activerecord-database_validations.gemspec`.
2. Add adapter configuration to `spec/db/adapters.rb`.
3. Add new patterns for error matching in
   `lib/activerecord/database_validations/rescues.rb`.

Of course make sure `rspec` doesn't fail, and create a new Pull Request!
