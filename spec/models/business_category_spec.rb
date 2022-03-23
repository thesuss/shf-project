require 'rails_helper'

RSpec.describe BusinessCategory, type: :model do

  let(:cat1) do
    cat = create(:business_category, name: 'cat1')
    cat.children.create(name: 'cat1_subcat1')
    cat.children.create(name: 'cat1_subcat2')
    cat.children.create(name: 'cat1_subcat3')
    cat
  end

  let(:cat2) do
    cat = create(:business_category, name: 'cat2')
    cat.children.create(name: 'cat2_subcat1')
    cat.children.create(name: 'cat2_subcat2')
    cat.children.create(name: 'cat2_subcat3')
    cat
  end

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:business_category)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description }
  end

  describe 'Associations' do
    it { is_expected.to have_many(:companies).through(:shf_applications) }
    it { is_expected.to have_and_belong_to_many(:shf_applications) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe '.category_and_subcategory_names' do

    it 'returns all categories with subcategories adjacent to parent category' do
      cat1
      cat2
      expected = [cat1] + cat1.children.order(:name) + [cat2] + cat2.children.order(:name)
      expect(BusinessCategory.category_and_subcategory_names).to eq expected
    end
  end

  describe '#full_ancestry_name' do

    it 'returns category name as-is' do
      expect(cat1.full_ancestry_name).to eq cat1.name
    end

    it 'returns subcategory name with preface including category name' do
      subcategory = cat1.children.first
      expect(subcategory.full_ancestry_name).to eq cat1.name +
                                            BusinessCategory::PARENT_AND_CHILD_NAME_SEPARATOR +
                                            subcategory.name
    end
  end
end
