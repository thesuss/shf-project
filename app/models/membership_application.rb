class MembershipApplication < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :business_categories
  validates_presence_of :first_name,
                        :last_name,
                        :company_number,
                        :contact_email,
                        :status
  validates_length_of :company_number, is: 10
  validates_format_of :contact_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]

end
