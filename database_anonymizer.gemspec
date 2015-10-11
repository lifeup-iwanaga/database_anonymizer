$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'database_anonymizer/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'database_anonymizer'
  s.version     = DatabaseAnonymizer::VERSION
  s.authors     = ['Shingo Kawamura']
  s.email       = ['blp1526@gmail.com']
  s.homepage    = 'https://github.com/blp1526/database_anonymizer'
  s.summary     = 'A database anonymizer for Rails 4+'
  s.description = 'A database anonymizer for Rails 4+'
  s.license     = 'MIT'

  s.files = Dir['{lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_development_dependency 'rails', '>= 4.0.0'
  s.add_development_dependency 'mysql2', '< 0.4'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
end
