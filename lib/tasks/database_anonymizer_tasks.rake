require 'database_anonymizer/metamorphosis'

namespace :database_anonymizer do
  desc 'anonymize records'
  task execute: :environment do
    ActiveRecord::Migration.say_with_time 'database_anonymizer:execute start...' do
      DatabaseAnonymizer::Metamorphosis.prepare_for_rake
      DatabaseAnonymizer::Metamorphosis.execute
      puts 'database_anonymizer:execute finished!'
      puts 'total time'
    end
  end
end
