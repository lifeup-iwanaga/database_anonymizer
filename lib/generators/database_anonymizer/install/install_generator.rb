require 'database_anonymizer/metamorphosis'

class DatabaseAnonymizer::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def copy_initializer_file
    template 'whitelist.yml.erb', File.join('config', 'database_anonymizer', 'whitelist.yml')
  end
end
