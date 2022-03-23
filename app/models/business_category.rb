class BusinessCategory < ApplicationRecord
  has_ancestry

  PARENT_AND_CHILD_NAME_SEPARATOR = ' >> '

  validates :name, presence: true

  has_and_belongs_to_many :shf_applications
  has_many :companies, through: :shf_applications

  def self.category_and_subcategory_names
    categories = []

    roots.order(:name).each do |category|
      categories << category
      categories += category.children.order(:name)
    end

    categories
  end

  def full_ancestry_name
    return name if is_root?

    parent.name + PARENT_AND_CHILD_NAME_SEPARATOR + name
  end

end
