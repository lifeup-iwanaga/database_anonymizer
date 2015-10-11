module DatabaseAnonymizer
  class Metamorphosis
    DEFAULT_ASTERISK_LENGTH = 8

    attr_reader :model

    def self.prepare_for_rake
      Rails.application.eager_load!
      ActiveRecord::Base.clear_cache!
    end

    def self.whitelist_path
      File.join(Rails.root, 'config', 'database_anonymizer', 'whitelist.yml')
    end

    def self.whitelist
      YAML.load_file(whitelist_path).respond_to?(:deep_symbolize_keys) ? YAML.load_file(whitelist_path).deep_symbolize_keys : {}
    end

    def self.table_existing_active_record_inheritors
      ActiveRecord::Base.descendants.reject do |d|
        !d.superclass.eql?(ActiveRecord::Base) || d.eql?(ActiveRecord::SchemaMigration) || !d.table_exists?
      end
    end

    def self.targets
      table_existing_active_record_inheritors.map { |model| new(model) }
    end

    def self.execute
      asteriskize
      anonymize
    end

    def self.asteriskize
      case ActiveRecord::Base.configurations[Rails.env]['adapter']
      when 'mysql2'
        targets.each(&:mysql_asteriskize)
      else
        targets.each(&:general_asteriskize)
      end
    end

    def self.anonymize
      fail DangerousRailsEnvError if Rails.env == 'production'
      whitelist.keys.each do |model_name|
        whitelist[model_name].each do |column, details|
          anonymize_log(model_name, column) { eval(details[:anonymized_by]) }
        end
      end
    end

    def self.anonymize_log(model_name, column)
      ActiveRecord::Migration.say_with_time "anonymize for #{model_name}##{column} start..." do
        yield
        puts "-- anonymize for #{model_name}##{column} completed!"
      end
    end

    def initialize(model)
      @model = model
    end

    def string_or_text_column_names
      model.columns.select { |column| [:string, :text].include?(column.type) }.map { |c| c.name.to_sym }
    end

    def unwhitelist_column_names
      string_or_text_column_names.select { |column_name| self.class.whitelist[model.to_s.to_sym].try!(:[], column_name).nil? }
    end

    def length_validator(column_name)
      model.validators_on(column_name).find { |validator| validator.class.eql?(ActiveModel::Validations::LengthValidator) }
    end

    def asterisk_length(column_length_validator)
      length = DEFAULT_ASTERISK_LENGTH
      return length unless column_length_validator
      length = column_length_validator.options[:minimum] if column_length_validator.options[:minimum]
      if column_length_validator.options[:maximum] && length > column_length_validator.options[:maximum]
        length = column_length_validator.options[:maximum]
      end
      length
    end

    def mysql_update_query(column_name)
      # NOTE: If a column name is same as MySQL reserved words, backquote is needed.
      "UPDATE #{model.table_name} SET `#{column_name}`='#{'*' * asterisk_length(length_validator(column_name))}' WHERE `#{column_name}` LIKE '%_%'"
    end

    def mysql_asteriskize
      fail DangerousRailsEnvError if Rails.env == 'production'
      unwhitelist_column_names.each do |column_name|
        ActiveRecord::Base.connection.execute(mysql_update_query(column_name))
      end
    end

    def general_asteriskize
      fail DangerousRailsEnvError if Rails.env == 'production'
      model.unscoped.find_each { |instance| instance.update!(asteriskize_params(instance)) }
    end

    private

      def asteriskize_params(instance)
        unwhitelist_column_names.each_with_object({}) do |column_name, obj|
          obj[column_name] = ('*' * asterisk_length(length_validator(column_name))) if instance.__send__(column_name)
        end
      end
  end
end

class DangerousRailsEnvError < StandardError; end
