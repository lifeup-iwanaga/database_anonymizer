class User < ActiveRecord::Base
  validates :name, length: { minimum: 2 }
  validates :address, length: { maximum: 7 }

  def self.anonymize_email
    find_each do |user|
      user.update!(email: "#{user.id}@example.com")
    end
  end
end
