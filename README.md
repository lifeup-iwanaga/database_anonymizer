# DatabaseAnonymizer

[![Gem Version](https://badge.fury.io/rb/database_anonymizer.svg)](https://badge.fury.io/rb/database_anonymizer)

A database anonymizer for Rails 4+

## Installation

Put this line in your Gemfile:

```ruby
gem 'database_anonymizer'
```

Then bundle:

```sh
$ bundle
```

Create `config/database_anonymizer/whitelist.yml` by:

```sh
$ bin/rails generate database_anonymizer:install
```

Then, only string or text type column table structures are created.

## Usage

See below sample `config/database_anonymizer/whitelist.yml` file.

```yml
'User':
# name:
  email:
    anonymized_by: User.anonymize_email
# address:
# tel:
  remarks:
    anonymized_by: nil
# comment:
```

### Asteriskize
if a column is commented out,
the column will be replaced by asterisks.

Default asterisks size is 8.

If `validate_length_of` is present, the number of asterisks size may not be 8.
For details, see the method `asterisk_length` at `lib/database_anonymizer/metamorphosis.rb`.

### Anonymize
If a column needs a specific anonymizer,
remove `#`, and add `anonymized_by: Model.anonymize_method`.
You have to define your own anonymize method.

### Do Nothing
If a column don't need to be asteriskized or anonymized,
remove `#`, and add `anonymized_by: nil`.

### Run rake task

Finally, run below rake task:

```sh
$ RAILS_ENV=TARGET_ENV bin/rake database_anonymizer:execute
```

## Specification
If `RAILS_ENV` is production,`bin/rake database_anonymizer:execute` fails.

## Contributing

1. Fork it ( https://github.com/blp1526/database_anonymizer/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request
