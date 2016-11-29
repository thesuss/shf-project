class BusinessCategory < ApplicationRecord
  validates_presence_of :name
  has_and_belongs_to_many :membership_applications
end
