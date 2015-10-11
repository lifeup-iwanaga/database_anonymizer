require 'rails_helper'
require 'database_anonymizer/metamorphosis'

RSpec.describe DatabaseAnonymizer::Metamorphosis do
  describe '.whitelist_path' do
    subject { DatabaseAnonymizer::Metamorphosis.whitelist_path }
    it { is_expected.to eq(File.join(Rails.root, 'config', 'database_anonymizer', 'whitelist.yml')) }
  end

  describe '.whitelist' do
    context 'when whitelist.yml is present' do
      before do
        path = File.join(Rails.root, 'config', 'database_anonymizer', 'whitelist.present.yml')
        allow(DatabaseAnonymizer::Metamorphosis).to receive(:whitelist_path).and_return(path)
      end
      subject { DatabaseAnonymizer::Metamorphosis.whitelist }
      it { is_expected.to eq(YAML.load_file(DatabaseAnonymizer::Metamorphosis.whitelist_path).deep_symbolize_keys) }
    end

    context 'when whitelist.yml is empty' do
      before do
        path = File.join(Rails.root, 'config', 'database_anonymizer', 'whitelist.empty.yml')
        allow(DatabaseAnonymizer::Metamorphosis).to receive(:whitelist_path).and_return(path)
      end
      subject { DatabaseAnonymizer::Metamorphosis.whitelist }
      it { is_expected.to eq({}) }
    end
  end

  describe '.table_existing_active_record_inheritors' do
    subject { DatabaseAnonymizer::Metamorphosis.table_existing_active_record_inheritors }
    it { is_expected.to eq([User]) }
  end

  describe '.targets' do
    let(:targets) { DatabaseAnonymizer::Metamorphosis.targets }
    it { expect(targets.class).to eq(Array) }
    it { expect(targets.exclude?(ActiveRecord::SchemaMigration)).to eq(true) }
  end

  context do
    before do
      whitelist_test = YAML.load_file(File.join(Rails.root, 'config', 'database_anonymizer', 'whitelist.present.yml')).deep_symbolize_keys
      allow(DatabaseAnonymizer::Metamorphosis).to receive(:whitelist).and_return(whitelist_test)
    end

    describe '.execute' do
      let(:user) do
        create(:user, tel: nil).tap do |user|
          DatabaseAnonymizer::Metamorphosis.execute
          user.reload
        end
      end
      it { expect(user.name).to eq('**') }
      it { expect(user.email).to eq("#{user.id}@example.com") }
      it { expect(user.address).to eq('*******') }
      it { expect(user.tel).to eq(nil) }
      it { expect(user.height).to eq(180) }
      it { expect(user.weight).to eq(70) }
      it { expect(user.remarks).to eq('Jo is a real nowhere man.') }
      it { expect(user.comment).to eq('********') }
    end

    describe '.initialize' do
      subject { DatabaseAnonymizer::Metamorphosis.new(User) }
      it { is_expected.to respond_to(:model) }
    end

    describe '#string_or_text_column_names' do
      subject { DatabaseAnonymizer::Metamorphosis.new(User).string_or_text_column_names }
      it { is_expected.to contain_exactly(:name, :email, :address, :tel, :remarks, :comment) }
    end

    describe '#unwhitelist_column_names' do
      subject { DatabaseAnonymizer::Metamorphosis.new(User).unwhitelist_column_names }
      it { is_expected.to contain_exactly(:name, :address, :tel, :comment) }
    end

    describe 'length_validator' do
      context 'when length_validator is not present' do
        let(:result) { DatabaseAnonymizer::Metamorphosis.new(User).length_validator(:tel) }
        it { expect(result).to eq(nil) }
      end

      context 'when length_validator is present' do
        let(:result) { DatabaseAnonymizer::Metamorphosis.new(User).length_validator(:name) }
        it { expect(result).not_to eq(nil) }
        it { expect(result.class).to eq(ActiveModel::Validations::LengthValidator) }
      end
    end

    describe '#asterisck_length' do
      let(:user) { DatabaseAnonymizer::Metamorphosis.new(User) }
      context 'when LengthValidator is not present' do
        it { expect(user.asterisk_length(user.length_validator(:tel))).to eq(DatabaseAnonymizer::Metamorphosis::DEFAULT_ASTERISK_LENGTH) }
      end

      context 'when LengthValidator minimum is present && maximum is not present' do
        it { expect(user.asterisk_length(user.length_validator(:name))).to eq(user.length_validator(:name).options[:minimum]) }
      end

      context 'when LengthValidator maximum is present && length > maximum' do
        it { expect(user.asterisk_length(user.length_validator(:address))).to eq(user.length_validator(:address).options[:maximum]) }
      end
    end

    describe '#mysql_update_query' do
      subject { DatabaseAnonymizer::Metamorphosis.new(User).mysql_update_query(:name) }
      it { is_expected.to eq("UPDATE users SET `name`='**' WHERE `name` LIKE '%_%'") }
    end

    describe '#mysql_asteriskize' do
      context 'given Rails.env == "production"' do
        before { allow(Rails).to receive(:env).and_return('production') }
        it { expect { DatabaseAnonymizer::Metamorphosis.new(User).mysql_asteriskize }.to raise_error(DangerousRailsEnvError) }
      end
      context 'given Rails.env != "production"' do
        let(:user) do
          create(:user, tel: nil).tap do |user|
            DatabaseAnonymizer::Metamorphosis.new(User).mysql_asteriskize
            user.reload
          end
        end
        it { expect(user.name).to eq('**') }
        it { expect(user.email).to eq('jo@example.com') }
        it { expect(user.address).to eq('*******') }
        it { expect(user.tel).to eq(nil) }
        it { expect(user.height).to eq(180) }
        it { expect(user.weight).to eq(70) }
        it { expect(user.remarks).to eq('Jo is a real nowhere man.') }
        it { expect(user.comment).to eq('********') }
      end
    end

    describe '#general_asteriskize' do
      context 'given Rails.env == "production"' do
        before { allow(Rails).to receive(:env).and_return('production') }
        it { expect { DatabaseAnonymizer::Metamorphosis.new(User).mysql_asteriskize }.to raise_error(DangerousRailsEnvError) }
      end

      context 'given Rails.env != "production"' do
        let(:user) do
          user = create(:user, tel: nil)
          DatabaseAnonymizer::Metamorphosis.new(User).general_asteriskize
          user.reload
        end
        it { expect(user.name).to eq('**') }
        it { expect(user.email).to eq('jo@example.com') }
        it { expect(user.address).to eq('*******') }
        it { expect(user.tel).to eq(nil) }
        it { expect(user.height).to eq(180) }
        it { expect(user.weight).to eq(70) }
        it { expect(user.remarks).to eq('Jo is a real nowhere man.') }
        it { expect(user.comment).to eq('********') }
      end
    end
  end
end
