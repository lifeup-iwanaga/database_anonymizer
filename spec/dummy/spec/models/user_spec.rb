require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.anonymize_email' do
    let(:user) { create(:user).tap { User.anonymize_email }.reload }
    it { expect(user.email).to eq("#{user.id}@example.com") }
  end
end
