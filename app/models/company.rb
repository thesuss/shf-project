class Company < ApplicationRecord

  include HasSwedishOrganization

  validates_presence_of :company_number
  validates_length_of :company_number, is: 10
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]
  validate :swedish_organisationsnummer

  has_and_belongs_to_many :business_categories

end
